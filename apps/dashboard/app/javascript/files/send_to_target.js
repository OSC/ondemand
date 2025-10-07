import { CONTENTID } from './data_table.js';
import { OODAlert, OODAlertSuccess } from '../alert';

export function initSendToTarget() {
  const button = document.getElementById('send-to-target-btn');
  if (!button) {
    return;
  }

  const endpoint = button.dataset.filesSelectTargetEndpoint;
  if (!endpoint) {
    return;
  }

  button.addEventListener('click', () => handleSend(button, endpoint));
}

function handleSend(button, endpoint) {
  const table = $(CONTENTID).DataTable();
  const selection = table.rows({ selected: true }).data().toArray();

  if (selection.length === 0) {
    OODAlert('Select at least one file or directory to send.');
    return;
  }

  button.setAttribute('disabled', 'disabled');

  const payload = buildPayload(selection);

  fetch(endpoint, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    credentials: 'same-origin',
    body: JSON.stringify(payload)
  })
    .then((response) => {
      if (!response.ok) {
        throw new Error();
      }

      OODAlertSuccess('Files sent successfully.');
    })
    .catch(() => {
      OODAlert('Failed to send files.');
    })
    .finally(() => {
      button.removeAttribute('disabled');
    });
}

function buildPayload(selection) {
  const baseDirectory = history.state.currentDirectory;
  const directoryUrl = history.state.currentDirectoryUrl;
  const filesystem = history.state.currentFilesystem;

  const files = selection.map((row) => {
    const name = row.name;
    const filePath = joinPath(baseDirectory, name);

    return {
      file_path: filePath,
      id: row.id,
      name: name,
      type: row.type,
      directory: row.type === 'd',
      size: row.size,
      human_size: row.human_size,
      modified_at: row.modified_at,
      owner: row.owner,
      mode: row.mode,
      url: row.url,
      download_url: row.download_url,
      edit_url: row.edit_url
    };
  });

  return {
    filesystem: filesystem,
    directory: baseDirectory,
    directory_url: directoryUrl,
    files: files
  };
}

function joinPath(base, name) {
  if (!base || base === '/') {
    return `/${name}`;
  }

  const sanitizedBase = base.endsWith('/') ? base.slice(0, -1) : base;
  return `${sanitizedBase}/${name}`;
}
