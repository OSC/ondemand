import ClipboardJS from 'clipboard'
import Handlebars from 'handlebars';

$(document).ready(function() {
  
  var clipBoard = new ClipBoard();

  $("#directory-contents").on('success', function(e) {
    $(e.trigger).tooltip({title: 'Copied path to clipboard!', trigger: 'manual', placement: 'bottom'}).tooltip('show');
    setTimeout(() => $(e.trigger).tooltip('hide'), 2000);
    e.clearSelection();
  });
  
  $("#directory-contents").on('error', function(e) {
    e.clearSelection();
  });

  $("#directory-contents").on("clipboardClear", function (e, options) {
    clipBoard.clearClipboard();
    clipBoard.updateViewForClipboard();
  });

  $("#directory-contents").on("updateClipboardFromSelection", function (e, options) {
    clipBoard.updateClipboardFromSelection(options.selection);
    clipBoard.updateViewForClipboard();
  });

  $("#directory-contents").on("updateViewForClipboard", function (e, options) {
    clipBoard.updateViewForClipboard();
  });


});

class ClipBoard {
  _clipBoard = null;
  _handleBars = null;

  constructor() {
    this._clipBoard = new ClipboardJS('#copy-path');
    this._handleBars = Handlebars;
  }

  getClipBoard() {
    return this._clipBoard;
  }

  getHandleBars() {
    return this._handleBars;
  } 

  clearClipboard() {
    localStorage.removeItem('filesClipboard');
  }

  updateClipboardFromSelection(selection) {
  
    if(selection.length == 0){
      this.clearClipboard();
    } else {
      let clipboardData = {
        from: history.state.currentDirectory,
        files: selection.toArray().map((f) => {
            return { directory: f.type == 'd', name: f.name };
        })
      };
  
      localStorage.setItem('filesClipboard', JSON.stringify(clipboardData));
    }
  }
  
  
  updateViewForClipboard() {
    let clipboard = JSON.parse(localStorage.getItem('filesClipboard') || '{}'),
        template_str  = $('#clipboard-template').html(),
        template = this._handleBars.compile(template_str);
  
    $('#clipboard').html(template(clipboard));
  
    $('#clipboard-clear').on("click", () => {
        this.clearClipboard();
        this.updateViewForClipboard();
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
    
          const eventData = {
            'files': files,
            'token': csrf_token
          };
  
          $("#directory-contents").trigger('fileOpsMove', eventData);    
        }
      }
      else{
        console.error('files clipboard is empty');
      }
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

          const eventData = {
            'files': files,
            'token': csrf_token
          };
        
          $("#directory-contents").trigger('fileOpsCopy', eventData);    
        }
      }
      else{
        console.error('files clipboard is empty');
      }
    });
  
  }
  

}
