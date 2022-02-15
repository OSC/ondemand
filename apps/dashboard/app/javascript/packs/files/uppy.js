import { Uppy, BasePlugin } from '@uppy/core'
import Dashboard from '@uppy/dashboard'
import XHRUpload from '@uppy/xhr-upload'

window.Uppy = Uppy
window.BasePlugin = BasePlugin
window.Dashboard = Dashboard
window.XHRUpload = XHRUpload

(function(){
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

          console.log(this.empty_dirs);
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

          return fetch(`${history.state.currentDirectoryUrl}/${encodeURI(filename)}?dir=true`, {method: 'put', headers: { 'X-CSRF-Token': csrf_token }})
          //TODO: parse json response verify if there was an error creating directory and handle error

        })).then(() => this.empty_dirs = []);
      }
    }

    install () {
      this.uppy.addPostProcessor(this.createEmptyDirs);
    }

    uninstall () {
      this.uppy.removePostProcessor(this.createEmptyDirs);
    }
  }

  function closeAndResetUppyModal(uppy){
    uppy.getPlugin('Dashboard').closeModal();
    uppy.reset();
  }


  window.uppy = new Uppy({
    restrictions: {
      maxFileSize: 100,
    }
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
    endpoint: '<%= files_upload_path %>',
    withCredentials: true,
    fieldName: 'file',
    limit: 1,
    headers: { 'X-CSRF-Token': csrf_token },
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
    console.log('File(s) dropped');
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

})();
