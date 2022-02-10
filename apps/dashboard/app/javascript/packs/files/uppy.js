$(document).ready(function(){
    window.onpopstate = function(event){
        // FIXME: handle edge case if state ! exist
        setTimeout(() => {
          goto(event.state.currentDirectoryUrl, false);
        }, 0);
      };

    function() {
    class EmptyDirCreator extends BasePlugin {
    constructor (uppy, opts) {
        super(uppy, opts)
        this.id = this.opts.id || 'EmptyDirUploaderCatcher';
        this.type = 'acquirer';

        this.empty_dirs = [];
        this.last_entries = [];

        this.handleRootDrop = this.handleRootDrop.bind(this);
        this.createEmptyDirs = this.createEmptyDirs.bind(this);

        this.uppy = uppy;
    }
}
    
});
  
  
    function closeAndResetUppyModal(uppy){
      uppy.getPlugin('Dashboard').closeModal();
      uppy.reset();
    }
  
  
    window.uppy = new Uppy({
      restrictions: {
        maxFileSize: <%= Configuration.file_upload_max %>,
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
  

  

  function handleRootDrop (e) {
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

  function createEmptyDirs (ids) {
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

  function install () {
    this.uppy.addPostProcessor(this.createEmptyDirs);
  }

  function uninstall () {
    this.uppy.removePostProcessor(this.createEmptyDirs);
  }


  // borrowed from Turbolinks
  // event: MouseEvent
  function clickEventIsSignificant(event) {
    return !(
      // (event.target && (event.target as any).isContentEditable)
         event.defaultPrevented
      || event.which > 1
      || event.altKey
      || event.ctrlKey
      || event.metaKey
      || event.shiftKey
    )
  }
  
  // this would be perfect for stimulus FYI
  $('#directory-contents tbody').on('click', '.view-file', function(e){
    e.preventDefault();
  
    window.open(this.href, 'ViewFile', "location=yes,resizable=yes,scrollbars=yes,status=yes");
  });
  
  $('#directory-contents tbody').on('click', '.delete-file', function(e){
    e.preventDefault();
  
    let row = table.row(this.dataset.rowIndex).data();
    deleteFiles([row.name]);
  });
  
  $('#directory-contents tbody').on('click', '.download-file', function(e){
    e.preventDefault();
  
    let file = table.row(this.dataset.rowIndex).data();
  
    if(file.type == 'd') {
      downloadDirectory(file)
    }
    else {
      downloadFile(file)
    }
  });
  
  $('#directory-contents tbody').on('click', '.rename-file', function(e){
    e.preventDefault();
  
    let row = table.row(this.dataset.rowIndex).data();
  
    // if there was some other attribute that just had the name...
    let filename = $($.parseHTML(row.name)).text();
  
    Swal.fire({
      title: 'Rename',
      input: 'text',
      inputLabel: 'Filename',
      inputValue: filename,
      inputAttributes: {
        spellcheck: 'false',
      },
      showCancelButton: true,
      inputValidator: (value) => {
        if (! value) {
          // TODO: validate filenames against listing
          return 'Provide a filename to rename this to';
        }
        else if (value.includes('/') || value.includes('..')){
         return 'Filename cannot include / or ..';
        }
      }
    })
    .then((result) => result.isConfirmed ? Promise.resolve(result.value) : Promise.reject('cancelled'))
    .then((new_filename) => renameFile(filename, new_filename))
  });
  
  $('#directory-contents tbody, #path-breadcrumbs, #favorites').on('click', 'a.d', function(){
    if(clickEventIsSignificant(event)){
      event.preventDefault();
      event.cancelBubble = true;
      if(event.stopPropagation) event.stopPropagation();
  
      goto(this.getAttribute("href"));
    }
  });
  
  $('#directory-contents tbody').on('dblclick', 'tr td:not(:first-child)', function(){
      // handle doubleclick
      let a = this.parentElement.querySelector('a');
      if(a.classList.contains('d')) goto(a.getAttribute("href"));
  });
  

  function reportTransfer(data){
    // 1. add the transfer label
    findAndUpdateTransferStatus(data);
  
    let attempts = 0
  
    // 2. poll for the updates
    var poll = function() {
      $.getJSON(data.show_json_url, function (newdata) {
        findAndUpdateTransferStatus(newdata);
  
        if(newdata.completed) {
          if(! newdata.error_message) {
            if(newdata.target_dir == history.state.currentDirectory) {
              reloadTable();
            }
  
            // 3. fade out after 5 seconds
            fadeOutTransferStatus(newdata)
          }
        }
        else {
          // not completed yet, so poll again
          setTimeout(poll, 1000);
        }
      }).fail(function() {
        if (attempts >= 3) {
          Swal.fire('Operation may not have happened', 'Failed to retrieve file operation status.', 'error');
        } else {
          setTimeout(poll, 1000);
          attempts++;
        }
      });
    }
  
    poll();
  }