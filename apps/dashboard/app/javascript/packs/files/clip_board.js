import ClipboardJS from 'clipboard'
import Handlebars from 'handlebars';
import {CONTENTID} from './data_table.js';
import {EVENTNAME as SWAL_EVENTNAME} from './sweet_alert.js';
import {EVENTNAME as FILEOPS_EVENTNAME} from './file_ops.js';

export {EVENTNAME};

const EVENTNAME = {
  clearClipboard: 'clearClipboard',
  updateClipboard: 'updateClipboard',
  updateClipboardView: 'updateClipboardView',
}

jQuery(function () {

  var clipBoard = new ClipBoard();

  $(CONTENTID.table).on('success', function (e) {
    $(e.trigger).tooltip({ title: 'Copied path to clipboard!', trigger: 'manual', placement: 'bottom' }).tooltip('show');
    setTimeout(() => $(e.trigger).tooltip('hide'), 2000);
    e.clearSelection();
  });

  $(CONTENTID.table).on('error', function (e) {
    e.clearSelection();
  });

  $(CONTENTID.table).on(EVENTNAME.clearClipboard, function (e, options) {
    clipBoard.clearClipboard();
    clipBoard.updateViewForClipboard();
  });

  $(CONTENTID.table).on(EVENTNAME.updateClipboard, function (e, options) {
    if (options.selection.length == 0) {
      const eventData = {
        'title': 'Select a file, files, or directory to copy or move.',
        'message': 'You have selected none.',
      };

      $(CONTENTID.table).trigger(SWAL_EVENTNAME.showError, eventData);
      $(CONTENTID.table).trigger(EVENTNAME.clearClipbaord, eventData);

    } else {
      clipBoard.updateClipboardFromSelection(options.selection);
      clipBoard.updateViewForClipboard();
    }
  });

  $(CONTENTID.table).on(EVENTNAME.updateClipboardView, function (e, options) {
    clipBoard.updateViewForClipboard();
  });


});

class ClipBoard {
  _clipBoard = null;

  constructor() {
    this._clipBoard = new ClipboardJS('#copy-path');
  }

  getClipBoard() {
    return this._clipBoard;
  }

  clearClipboard() {
    localStorage.removeItem('filesClipboard');
  }

  updateClipboardFromSelection(selection) {

    if (selection.length == 0) {
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
      template_str = $('#clipboard-template').html(),
      template = Handlebars.compile(template_str);

    $('#clipboard').html(template(clipboard));

    $('#clipboard-clear').on("click", () => {
      this.clearClipboard();
      this.updateViewForClipboard();
    });

    $('#clipboard-move-to-dir').on("click", () => {
      let clipboard = JSON.parse(localStorage.getItem('filesClipboard') || 'null');
      if (clipboard) {
        clipboard.to = history.state.currentDirectory;

        if (clipboard.from == clipboard.to) {
          console.error('clipboard from and to are identical')
          // TODO:
        }
        else {
          let files = {};
          clipboard.files.forEach((f) => {
            files[`${clipboard.from}/${f.name}`] = `${history.state.currentDirectory}/${f.name}`
          });

          const eventData = {
            'files': files,
            'token': csrf_token
          };

          $(CONTENTID.table).trigger(FILEOPS_EVENTNAME.moveFile, eventData);
        }
      }
      else {
        console.error('files clipboard is empty');
      }
    });


    $('#clipboard-copy-to-dir').on("click", () => {
      let clipboard = JSON.parse(localStorage.getItem('filesClipboard') || 'null');

      if (clipboard) {
        clipboard.to = history.state.currentDirectory;

        if (clipboard.from == clipboard.to) {
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
        else {
          // [{"/from/file/path":"/to/file/path" }]
          let files = {};
          clipboard.files.forEach((f) => {
            files[`${clipboard.from}/${f.name}`] = `${history.state.currentDirectory}/${f.name}`
          });

          const eventData = {
            'files': files,
            'token': csrf_token
          };

          $(CONTENTID.table).trigger(FILEOPS_EVENTNAME.copyFile, eventData);
        }
      }
      else {
        console.error('files clipboard is empty');
      }
    });

  }


}
