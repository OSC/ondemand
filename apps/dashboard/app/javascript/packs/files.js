import ClipboardJS from 'clipboard'
import Swal from 'sweetalert2'

window.ClipboardJS = ClipboardJS
window.Swal        = Swal

const Uppy      = require('@uppy/core')
const Dashboard = require('@uppy/dashboard')
const XHRUpload = require('@uppy/xhr-upload')

class EmptyDirCreator extends Uppy.Plugin {
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

        return fetch(`${history.state.currentDirectoryUrl}/${encodeURI(filename)}?dir=true`, {method: 'put'})
        //TODO: parse json response verify if there was an error creating directory and handle error

      })).then(() => this.empty_dirs = []);
    }
  }

  install () {
    this.uppy.addPostProcessor(this.createEmptyDirs);

    //TODO: subscribe to event on dashboard close?! to clear empty_dirs?
  }

  uninstall () {
    this.uppy.removePostProcessor(this.createEmptyDirs);
  }
}

window.EmptyDirCreator = EmptyDirCreator

function getUppyEndpoint() {
  let directoryContentsDiv = "#directory-contents"
  let el = document.querySelector(directoryContentsDiv)

  if (el == null) {
    return null
  }

  let { dataset } = el

  return dataset.uppyEndpoint
}

function getCSRFToken() {
  return document.querySelector('meta[name="csrf-token"]').content
}

$(function() {
  const uppy = Uppy({
    debug: true,
    allowMultipleUploads: false,
  })
  .use(EmptyDirCreator)
  .use(Dashboard, {
    trigger: '#upload-btn',
    fileManagerSelectionType: 'both',
    disableThumbnailGenerator: true,
    showLinkToFileUploadResult: false,
    closeModalOnClickOutside: true,
    closeAfterFinish: true,
    allowMultipleUploads: false,
  })
  .use(XHRUpload, {
    endpoint: getUppyEndpoint(),
    withCredentials: true,
    fieldName: 'file',
    limit: 1,
    headers: { 'X-CSRF-Token': getCSRFToken() }
  })

  uppy.on('file-added', (file) => {
    uppy.setFileMeta(file.id, { parent: history.state.currentDirectory })
    if (file.meta.relativePath == null && file.data.webkitRelativePath) {
      uppy.setFileMeta(file.id, { relativePath: file.data.webkitRelativePath })
    }
  })

  uppy.on('complete', (result) => {
    if(result.successful.length > 0) {
      reloadTable()
    }
  })

  window.uppy = uppy;
})