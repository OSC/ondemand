import { Uppy, BasePlugin } from '@uppy/core'
import Dashboard from '@uppy/dashboard'
import XHRUpload from '@uppy/xhr-upload'
import _ from 'lodash';
import {CONTENTID, EVENTNAME as DATATABLE_EVENTNAME} from './data_table.js';
import { maxFileSize, csrfToken, uppyLocale } from '../config.js';

let uppy = null;

jQuery(function() {

  uppy = new Uppy({
    restrictions: {
      maxFileSize: maxFileSize(),
    },
    onBeforeUpload: updateEndpoint,
    locale: uppyLocale(),
  });
  
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
  });

  uppy.on('complete', (result) => {
    if(result.successful.length > 0){
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

});

function closeAndResetUppyModal(uppy){
  uppy.getPlugin('Dashboard').closeModal();
  uppy.reset();
}

function updateEndpoint() {
  uppy.getPlugin('XHRUpload').setOptions({
    endpoint: history.state.currentFilesUploadPath,
  });
}

function reloadTable() {
  $(CONTENTID).trigger(DATATABLE_EVENTNAME.reloadTable,{});
}

