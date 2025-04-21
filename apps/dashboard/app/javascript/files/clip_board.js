import ClipboardJS from 'clipboard';
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
      $(CONTENTID).trigger(EVENTNAME.clearClipboard, eventData);

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
    let clipboard = JSON.parse(localStorage.getItem('filesClipboard') || '{}');

    const clipboardContainer = document.getElementById('clipboard');
    clipboardContainer.innerHTML = ''; // Clear existing content

    if (clipboard.files && clipboard.files.length > 0) {
      // Create card structure
      const card = document.createElement('div');
      card.className = 'card mb-3';

      const cardBody = document.createElement('div');
      cardBody.className = 'card-body';

      const closeButton = document.createElement('button');
      closeButton.id = 'clipboard-clear';
      closeButton.type = 'button';
      closeButton.className = 'btn-close';
      closeButton.setAttribute('data-bs-dismiss', 'alert');
      closeButton.setAttribute('aria-label', 'Close');
      cardBody.appendChild(closeButton);

      const description = document.createElement('p');
      description.className = 'mt-4';
      description.innerHTML = `Copy or move the files below from <code>${clipboard.from}</code> to the current directory:`;
      cardBody.appendChild(description);

      card.appendChild(cardBody);

      // Create file list
      const listGroup = document.createElement('ul');
      listGroup.className = 'list-group list-group-flush';

      clipboard.files.forEach((file) => {
        const listItem = document.createElement('li');
        listItem.className = 'list-group-item';

        const icon = document.createElement('span');
        icon.title = file.directory ? 'directory' : 'file';
        icon.className = file.directory
          ? 'fa fa-folder color-gold'
          : 'fa fa-file color-lightgrey';
        listItem.appendChild(icon);

        const fileName = document.createTextNode(` ${file.name}`);
        listItem.appendChild(fileName);

        listGroup.appendChild(listItem);
      });

      card.appendChild(listGroup);

      // Create action buttons
      const actionsBody = document.createElement('div');
      actionsBody.className = 'card-body';

      const copyButton = document.createElement('button');
      copyButton.id = 'clipboard-copy-to-dir';
      copyButton.className = 'btn btn-primary';
      copyButton.textContent = 'Copy';
      actionsBody.appendChild(copyButton);

      const moveButton = document.createElement('button');
      moveButton.id = 'clipboard-move-to-dir';
      moveButton.className = 'btn btn-danger float-end';
      moveButton.textContent = 'Move';
      actionsBody.appendChild(moveButton);

      card.appendChild(actionsBody);

      clipboardContainer.appendChild(card);

      // Attach event listeners
      this.addClipboardEventListeners();
    }
  }

  addClipboardEventListeners() {
    const clearButton = document.getElementById('clipboard-clear');
    if (clearButton) {
      clearButton.addEventListener('click', () => {
        this.clearClipboard();
        this.updateViewForClipboard();
      });
    }

    const moveButton = document.getElementById('clipboard-move-to-dir');
    if (moveButton) {
      moveButton.addEventListener('click', () => {
        const clipboard = JSON.parse(localStorage.getItem('filesClipboard') || 'null');
        if (clipboard) {
          clipboard.to = history.state.currentDirectory;
          clipboard.to_fs = history.state.currentFilesystem;

          if (clipboard.from === clipboard.to) {
            this.clearClipboard();
            this.updateViewForClipboard();
          } else {
            const files = {};
            clipboard.files.forEach((file) => {
              files[`${clipboard.from}/${file.name}`] = `${history.state.currentDirectory}/${file.name}`;
            });

            const eventData = {
              files: files,
              token: csrfToken(),
              from_fs: clipboard.from_fs,
              to_fs: clipboard.to_fs,
            };

            $(CONTENTID).trigger(FILEOPS_EVENTNAME.moveFile, eventData);
          }
        } else {
          console.error('Files clipboard is empty');
        }
      });
    }

    const copyButton = document.getElementById('clipboard-copy-to-dir');
    if (copyButton) {
      copyButton.addEventListener('click', () => {
        const clipboard = JSON.parse(localStorage.getItem('filesClipboard') || 'null');
        if (clipboard) {
          clipboard.to = history.state.currentDirectory;
          clipboard.to_fs = history.state.currentFilesystem;

          const files = {};
          clipboard.files.forEach((file) => {
            files[`${clipboard.from}/${file.name}`] = `${clipboard.to}/${file.name}`;
          });

          const eventData = {
            files: files,
            token: csrfToken(),
            from_fs: clipboard.from_fs,
            to_fs: clipboard.to_fs,
          };

          $(CONTENTID).trigger(FILEOPS_EVENTNAME.copyFile, eventData);
        } else {
          console.error('Files clipboard is empty');
        }
      });
    }
  }
}