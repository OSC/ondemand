import ClipboardJS from 'clipboard'
import {Handlebars, table} from './datatable.js';

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
  

  $('#copy-move-btn').on("click", () => {
    updateClipboardFromSelection();
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

}
