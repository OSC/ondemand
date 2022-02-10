import ClipboardJS from 'clipboard'


window.ClipboardJS = ClipboardJS
window.updateViewForClipboard = updateViewForClipboard;

//FIXME: so need to handle updateViewForClipboard based on EVENTS emitted by local storage modifications
updateViewForClipboard();
window.addEventListener('storage', () => {
  updateViewForClipboard();
});


$(document).ready(function(){
  clipboardjs.on('success', function(e) {
    $(e.trigger).tooltip({title: 'Copied path to clipboard!', trigger: 'manual', placement: 'bottom'}).tooltip('show');
    setTimeout(() => $(e.trigger).tooltip('hide'), 2000);
    e.clearSelection();
  });
  clipboardjs.on('error', function(e) {
    e.clearSelection();
  });


  
});



function updateViewForClipboard(){
  let clipboard = JSON.parse(localStorage.getItem('filesClipboard') || '{}'),
      template_str  = $('#clipboard-template').html(),
      template = Handlebars.compile(template_str);

  $('#clipboard').html(template(clipboard));

  $('#clipboard-clear').on("click", () => {
      clearClipboard();
      updateViewForClipboard();
  });


  $('#clipboard-copy-to-dir').on("click", () => {
    let clipboard = JSON.parse(localStorage.getItem('filesClipboard') || 'null');

    if(clipboard){
      clipboard.to = history.state.currentDirectory;

      if(clipboard.from == clipboard.to){
        console.error('clipboard from and to are identical')

        // TODO: we want to support this use case
        // copy and paste as a new filename
        // but lots of edge cases
        // (overwrite or rename duplicates)
        // _copy
        // _copy_2
        // _copy_3
        // _copy_4
      }
      else{
        // [{"/from/file/path":"/to/file/path" }]
        let files = {};
        clipboard.files.forEach((f) => {
          files[`${clipboard.from}/${f.name}`] = `${history.state.currentDirectory}/${f.name}`
        });

        copyFiles(files, csrf_token);
      }
    }
    else{
      console.error('files clipboard is empty');
    }
  });

  $('#clipboard-move-to-dir').on("click", () => {
    let clipboard = JSON.parse(localStorage.getItem('filesClipboard') || 'null');

    if(clipboard){
      clipboard.to = history.state.currentDirectory;

      if(clipboard.from == clipboard.to){
        console.error('clipboard from and to are identical')
        // TODO:
      }
      else{
        let files = {};
        clipboard.files.forEach((f) => {
          files[`${clipboard.from}/${f.name}`] = `${history.state.currentDirectory}/${f.name}`
        });

        moveFiles(files, csrf_token);
      }
    }
    else{
      console.error('files clipboard is empty');
    }
  });
}
