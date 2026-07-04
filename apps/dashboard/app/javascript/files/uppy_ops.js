import Uppy from '@uppy/core'
import BasePlugin from '@uppy/core/lib/BasePlugin'
import Dashboard from '@uppy/dashboard'
import XHRUpload from '@uppy/xhr-upload'
import _ from 'lodash';
import {CONTENTID, EVENTNAME as DATATABLE_EVENTNAME} from './data_table.js';
import { maxFileSize, csrfToken, uppyLocale } from '../config.js';
import { fileOps } from './file_ops.js';

let uppy = null;

jQuery(function() {

  class EmptyDirCreator extends BasePlugin {
    constructor (uppy, opts){
      super(uppy, opts)
      this.id = this.opts.id || 'EmptyDirUploaderCatcher';
      this.type = 'acquirer';

      this.empty_dirs = [];
      this.last_entries = [];

      this.handleRootDrop = this.handleRootDrop.bind(this);
      this.createEmptyDirs = this.createEmptyDirs.bind(this);

      this.uppy = uppy;
    }



    handleRootDrop (e) {
      // from https://github.com/transloadit/uppy/blob/7ce58beeb620df3df0640cb369f5d71e3d3f751f/packages/%40uppy/utils/src/getDroppedFiles/index.js
      if (e.dataTransfer.items && e.dataTransfer.items[0] && 'webkitGetAsEntry' in e.dataTransfer.items[0]) {
        // toArray https://github.com/transloadit/uppy/blob/7ce58beeb620df3df0640cb369f5d71e3d3f751f/packages/%40uppy/utils/src/toArray.js#L4
        let items = Array.prototype.slice.call(e.dataTransfer.items || [], 0);
        let entries = items.map(i => i.webkitGetAsEntry()).filter(i => i);

        return Promise.all(entries.map(i => getEmptyDirs(i))).then((dirs) => {
          this.empty_dirs = this.empty_dirs.concat(_.flattenDeep(dirs));

        });
      }
      //else we don't have access to directory information
    }

    createEmptyDirs (ids) {
      if(! this.uppy.getState().error){ // avoid creating empty dirs if error occurred during upload

        //TODO: error checking and reporting
        return Promise.all(this.empty_dirs.map((d) => {
          // "fullPath" should actually be the path relative to the current directory
          let filename = _.trimStart(d.fullPath, '/');
          let encoded = filename.split('/').map(encodeURIComponent).join('/');

          return fetch(`${history.state.currentDirectoryUrl}/${encoded}?dir=true`, {method: 'put', headers: { 'X-CSRF-Token': csrfToken() }})
          //TODO: parse json response verify if there was an error creating directory and handle error

        })).then(() => this.empty_dirs = []);
      }
    }

    mount(target, plugin) {
      return true
    }

    unmount() {
      return true
    }
  
    install () {
      this.uppy.addPostProcessor(this.createEmptyDirs);
    }

    uninstall () {
      this.uppy.removePostProcessor(this.createEmptyDirs);
    }
  }

  uppy = new Uppy({
    restrictions: {
      maxFileSize: maxFileSize(),
    },
    onBeforeUpload: updateEndpoint,
    locale: uppyLocale(),
  });
  
  uppy.use(EmptyDirCreator);

  uppy.use(Dashboard, {
    trigger: '#upload-btn',
    fileManagerSelectionType: 'both',
    disableThumbnailGenerator: true,
    showLinkToFileUploadResult: false,
    closeModalOnClickOutside: true,
    closeAfterFinish: true,
    allowMultipleUploads: false,
    onRequestCloseModal: () => closeAndResetUppyModal(uppy),
    note: 'Empty directories will be included in the upload only when a directory upload is initiated via drag and drop. This is because the File and Directory Entries API is available only on a drop event, not during an input change event.'
  });

  uppy.use(XHRUpload, {
    withCredentials: true,
    fieldName: 'file',
    limit: 1,
    headers: { 'X-CSRF-Token': csrfToken() },
    timeout: 128 * 1000,
  });

  uppy.on('file-added', (file) => {
    uppy.setFileMeta(file.id, { parent: history.state.currentDirectory });
    if(file.meta.relativePath == null && file.data.webkitRelativePath){
      uppy.setFileMeta(file.id, { relativePath: file.data.webkitRelativePath });
    }
    checkUpload(file);
  });

  uppy.on('file-removed', (file) => {
    if(window.overwriteFiles.delete(file.id) && window.overwriteFiles.size === 0) {
      removeOverwriteButton();
    }
    waitForElement(`.uppy-Dashboard-Item-name[title="${file.meta.name}"]`, true).then(_title => {
      window.overwriteFiles.forEach(id => { markOverwrite(uppy.getFile(id)) });
      updateUppyCount();
    })
  })

  uppy.on('complete', (result) => {
    if(result.successful.length > 0){
      result.successful.forEach(handleUploadSuccess);
      reloadTable();
    }
  });

  // https://stackoverflow.com/questions/6756583/prevent-browser-from-loading-a-drag-and-dropped-file
  window.addEventListener("dragover",function(e){
    e = e || event;
    e.preventDefault();
  },false);
  
  window.addEventListener("drop",function(e){
    e = e || event;
    e.preventDefault();
  },false);

  $('#directory-contents').on('drop', function(e){
    this.classList.remove('dragover');
    // Prevent default behavior (Prevent file from being opened)

    // pass drop event to uppy dashboard
    uppy.getPlugin('Dashboard').openModal().then(() => uppy.getPlugin('Dashboard').handleDrop(e.originalEvent))
  });

  $('#directory-contents').on('dragover', function(e){
    this.classList.add('dragover');

    // Prevent default behavior (Prevent file from being opened)
    e.preventDefault();

    // specifies what feedback will be shown to the user by setting the dropEffect attribute of the DataTransfer associated with the event
    // too bad we can't show an indicator (no dragstart/end when dragging from OS to browser)
    e.originalEvent.dataTransfer.dropEffect = 'copy';
  });

  $('#directory-contents').on('dragleave', function(e){
    this.classList.remove('dragover');
  });

  window.overwriteFiles = new Set;
});

function closeAndResetUppyModal(uppy){
  uppy.getPlugin('Dashboard').closeModal();
  uppy.getFiles().forEach(file => {
    uppy.removeFile(file.id);
  });
}

function getEmptyDirs(entry){
  return new Promise((resolve) => {
    if(entry.isFile){
      resolve([]);
    }
    else{
      // getFilesAndDirectoriesFromDirectory has no return value, so turn this into a promise
      let getFilesAndDirectoriesFromDirectory = (entry.createReader(), [], function(error){ console.error(error)}, {
        onSuccess: (entries) => {
          if(entries.length == 0){
            // this is an empty directory
            resolve([entry]);
          }
          else{
            Promise.all(entries.map(e => getEmptyDirs(e))).then((dirs) => resolve(_.flattenDeep(dirs)));
          }
        }
      })
    }
  });
}

function updateEndpoint() {
  uppy.getPlugin('XHRUpload').setOptions({
    endpoint: history.state.currentFilesUploadPath,
  });
}

function reloadTable() {
  $(CONTENTID).trigger(DATATABLE_EVENTNAME.reloadTable,{});
}

// Uploads may return the status of a transfer for remote uploads.
function handleUploadSuccess(result) {
  // These extra checks might not be needed.
  const body = result?.response?.body;
  if (!body || !(typeof body === "object" && !Array.isArray(body) && body !== null)) {
    return;
  }
  if (Object.keys(body).length > 0 && !body.completed) {
    fileOps.reportTransfer(body);
  }
}

async function checkUpload(file) {
  const meta = file.meta;
  const relPath = meta.relativePath || meta.name;
  if (checkOverwrite(relPath)) {
    if (meta.relativePath == null) {
      // then file was uploaded directly, and conflict is confirmed
      markOverwrite(file);
    } else {
      // file was uploaded as part of a folder, and we have to check if its a true conflict
      const isOverwrite = await investigateOverwrite(relPath);
      if(isOverwrite){
        markOverwrite(file);
      }
    }
  }
  // After new file appears, ensure earlier ones are marked
  waitForElement(`.uppy-Dashboard-Item-name[title="${file.meta.name}"]`).then(title => {
    window.overwriteFiles.forEach(id => { markOverwrite(uppy.getFile(id)) });
    updateUppyCount();
  })
}

function safeUpload() {
  window.overwriteFiles.forEach(id => { uppy.removeFile(id); })
  window.overwriteFiles.clear();
  uppy.upload();
}

function checkOverwrite(relativePath) {
  const overwritePath = relativePath.split('/')[0];
  return history.state.currentFilenames.includes(overwritePath);
}

async function investigateOverwrite(path) {
  const directory = path.slice(0, path.lastIndexOf('/'));
  const url = `${history.state.currentDirectoryUrl}/${directory}`;
  const response = await fetch(url, { headers: { 'Accept': 'application/json' }});
  const data = await response.json();

  const targetFile = path.slice(path.lastIndexOf('/') + 1);
  return Array.from(data.files).map(file => file.name).includes(targetFile);
}


function markOverwrite(file) {
  window.overwriteFiles.add(file.id);
  const name = file.meta.name;
  waitForElement(`.uppy-Dashboard-Item-name[title="${name}"]`).then(title => {
    const wrapper = title.closest('.uppy-Dashboard-Item');
    wrapper.classList.add('bg-danger', 'rounded', 'p-2');
    addOverwriteButton();
  });
}

const safeBtnId = 'safe-upload-btn';
const uploadBtnSelector = '.uppy-StatusBar-actions .uppy-StatusBar-actionBtn--upload';

function addOverwriteButton() {
  if(document.getElementById(safeBtnId) !== null) {
    return
  }

  const uploadBtn = document.querySelector(uploadBtnSelector);
  const safeBtn = uploadBtn.cloneNode();
  safeBtn.id = safeBtnId;
  safeBtn.textContent = 'Upload New Files';
  safeBtn.addEventListener('click', safeUpload);
  uploadBtn.classList.add('mx-3', 'uppy-StatusBar-actionBtn--upload-danger');
  uploadBtn.textContent = 'Upload and Overwrite';

  const warning = document.createElement('span');
  warning.classList.add('text-danger', 'lh-base')
  warning.textContent = 'Duplicate files identified. Uploading these files will overwrite existing content.'
  
  const actionsWrapper = document.querySelector('div.uppy-StatusBar-actions');
  actionsWrapper.prepend(safeBtn);
  actionsWrapper.append(warning);
}

function removeOverwriteButton() {
  if(document.getElementById(safeBtnId) !== null) {
    document.getElementById(safeBtnId).remove();
    document.querySelector('div.uppy-StatusBar-actions span').remove();
    const uploadBtn = document.querySelector(uploadBtnSelector);
    uploadBtn.classList.remove('mx-3', 'uppy-StatusBar-actionBtn--upload-danger');
  }
}

function updateUppyCount() {
  const uploadBtn = document.querySelector(uploadBtnSelector);
  if(document.getElementById(safeBtnId) === null && uploadBtn !== null) {
    const count = uppy.getFiles().length;
    uploadBtn.textContent = `Upload ${count} file${(count == 1) ? '': 's'}`; 
  }
}

function waitForElement(selector, deleted = false, { root = document.body, timeout = 5000 } = {}) {
  return new Promise((resolve, reject) => {
    const existing = root.querySelector(selector);
    if (existing) return resolve(existing);

    const observer = new MutationObserver(() => {
      const el = root.querySelector(selector);
      finished = deleted ? !el : el;
      if (finished) {
        observer.disconnect();
        clearTimeout(timer);
        resolve(el);
      }
    });

    observer.observe(root, { childList: true, subtree: true });

    const timer = setTimeout(() => {
      observer.disconnect();
      reject(new Error(`Timed out waiting for "${selector}"`));
    }, timeout);
  });
}