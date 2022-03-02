import ClipboardJS from 'clipboard'
import {Handlebars} from './datatable.js';

export {ClipboardJS, clipboardjs, clearClipboard, updateClipboardFromSelection, updateViewForClipboard };

global.ClipboardJS = ClipboardJS

var clipboardjs = null;

$(document).ready(function(){
  
  clipboardjs = new ClipboardJS('#copy-path');
  
  clipboardjs.on('success', function(e) {
    //FIXME: for some reason the jQuery function tooltip is not being recognized.  Will need to figure out why or move on to new tooltip plugin.
    
    // $(e.trigger).tooltip({title: 'Copied path to clipboard!', trigger: 'manual', placement: 'bottom'}).tooltip('show');
    // setTimeout(() => $(e.trigger).tooltip('hide'), 2000);
    e.clearSelection();
  });
  clipboardjs.on('error', function(e) {
    e.clearSelection();
  });

  //FIXME: so need to handle updateViewForClipboard based on EVENTS emitted by local storage modifications
  updateViewForClipboard();
  global.addEventListener('storage', () => {
    updateViewForClipboard();
  });
  
});

function updateClipboardFromSelection(){
  let selection = table.rows({selected: true}).data();
  if(selection.length == 0){
    clearClipboard();
  }
  else {
    let clipboardData = {
      from: history.state.currentDirectory,
      files: selection.toArray().map((f) => {
          return { directory: f.type == 'd', name: f.name };
      })
    };

    localStorage.setItem('filesClipboard', JSON.stringify(clipboardData));
  }
}

function clearClipboard(){
   localStorage.removeItem('filesClipboard');
}

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
