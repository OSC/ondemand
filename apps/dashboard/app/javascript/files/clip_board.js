import ClipboardJS from 'clipboard'
import Handlebars from 'handlebars';
import {CONTENTID} from './data_table.js';
import {EVENTNAME as SWAL_EVENTNAME} from './sweet_alert.js';
import {EVENTNAME as FILEOPS_EVENTNAME} from './file_ops.js';
import { csrfToken } from '../config.js';

export {EVENTNAME};

const EVENTNAME = {
  clearClipboard: 'clearClipboard',
  updateClipboard: 'updateClipboard',
  updateClipboardView: 'updateClipboardView',
}

jQuery(function () {

  var clipBoard = new ClipBoard();

  $("#copy-move-btn").on("click", function () {
    let table = $(CONTENTID).DataTable();
    let selection = table.rows({ selected: true }).data();

    const eventData = {
      selection: selection
    };

    $(CONTENTID).trigger(EVENTNAME.updateClipboard, eventData);

  });


  $(CONTENTID).on('success', function (e) {
    $(e.trigger).tooltip({ title: 'Copied path to clipboard!', trigger: 'manual', placement: 'bottom' }).tooltip('show');
    setTimeout(() => $(e.trigger).tooltip('hide'), 2000);
    e.clearSelection();
  });

  $(CONTENTID).on('error', function (e) {
    e.clearSelection();
  });

  $(CONTENTID).on(EVENTNAME.clearClipboard, function (e, options) {
    clipBoard.clearClipboard();
    clipBoard.updateViewForClipboard();
  });

  $(CONTENTID).on(EVENTNAME.updateClipboard, function (e, options) {
    if (options.selection.length == 0) {
      const eventData = {
        'title': 'Select a file, files, or directory to copy or move.',
        'message': 'You have selected none.',
      };

      $(CONTENTID).trigger(SWAL_EVENTNAME.showError, eventData);
      $(CONTENTID).trigger(EVENTNAME.clearClipbaord, eventData);

    } else {
      clipBoard.updateClipboardFromSelection(options.selection);
      clipBoard.updateViewForClipboard();
    }
  });

  $(CONTENTID).on(EVENTNAME.updateClipboardView, function (e, options) {
    clipBoard.updateViewForClipboard();
  });


});

class ClipBoard {
  _clipBoard = null;

  constructor() {
    this._clipBoard = new ClipboardJS('#copy-path');
    this.updateViewForClipboard();
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
        from_fs: history.state.currentFilesystem,
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
        clipboard.to_fs = history.state.currentFilesystem;

        if (clipboard.from == clipboard.to) {
          // No files are changed, so we just have to clear and update the clipboard
          this.clearClipboard();
          this.updateViewForClipboard();
        }
        else {
          let files = {};
          clipboard.files.forEach((f) => {
            files[`${clipboard.from}/${f.name}`] = `${history.state.currentDirectory}/${f.name}`
          });

          const eventData = {
            'files': files,
            'token': csrfToken(),
            'from_fs': clipboard.from_fs,
            'to_fs': clipboard.to_fs,
          };

          $(CONTENTID).trigger(FILEOPS_EVENTNAME.moveFile, eventData);
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
        clipboard.to_fs = history.state.currentFilesystem;

        // files is a hashmap with keys of file current path and value as the corresponding files desired path
        let files = {};

        clipboard.files.forEach((f) => {
          files[`${clipboard.from}/${f.name}`] = `${clipboard.to}/${f.name}`;
        });

        const eventData = {
          'files': files,
          'token': csrfToken(),
          'from_fs': clipboard.from_fs,
          'to_fs': clipboard.to_fs,
        };

        $(CONTENTID).trigger(FILEOPS_EVENTNAME.copyFile, eventData);
      }
      else {
        console.error('files clipboard is empty');
      }
    });

  }


}
