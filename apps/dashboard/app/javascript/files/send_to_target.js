import { CONTENTID } from './data_table.js';
import { OODAlertError, OODAlertSuccess } from '../alert';

const TOKEN_KEY = 'files_select_target_token';

export function initSendToTarget() {
  const button = document.getElementById('send-to-target-btn');
  if (!button) {
    return;
  }

  const endpoint = button.dataset.filesSelectTargetEndpoint;
  const expirationMinutes = parseInt(button.dataset.tokenExpiration);
  if (!endpoint || !expirationMinutes) {
    return;
  }

  const tokenFromUrl = getUrlToken();
  const storedToken = getStoredToken(expirationMinutes);

  // If token in URL, store it
  if (tokenFromUrl) {
    storeToken(tokenFromUrl);
  }

  const effectiveToken = tokenFromUrl || storedToken;

  // Disable if no token
  if (!effectiveToken) {
    disableButton(button);
  }

  button.addEventListener('click', () =>
      handleSendToTarget(button, endpoint, expirationMinutes)
  );
}

function handleSendToTarget(button, endpoint, expirationMinutes) {
  const targetToken = getStoredToken(expirationMinutes);

  if (!targetToken) {
    disableButton(button);
    OODAlertError('Application token is missing or expired. Start again');
    return;
  }

  const table = $(CONTENTID).DataTable();
  const selection = table.rows({ selected: true }).data().toArray();

  if (selection.length === 0) {
    OODAlertError('Select at least one file or directory to send.');
    return;
  }

  disableButton(button);

  const payload = buildPayload(selection, targetToken);

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

        OODAlertSuccess('Selected file information sent successfully.');
      })
      .catch(() => {
        OODAlertError('Failed to send file information.');
      })
      .finally(() => {
        button.removeAttribute('disabled');
      });
}

function buildPayload(selection, token) {
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
    token: token,
    filesystem: filesystem,
    directory: baseDirectory,
    directory_url: directoryUrl,
    files: files
  };
}

function getUrlToken() {
  const params = new URLSearchParams(window.location.search);
  return params.get(TOKEN_KEY);
}

function storeToken(token) {
  const data = {
    value: token,
    stored_at: Date.now()
  };
  sessionStorage.setItem(TOKEN_KEY, JSON.stringify(data));
}

function getStoredToken(expirationMinutes) {
  const raw = sessionStorage.getItem(TOKEN_KEY);
  if (!raw) return null;
  try {
    const tokenData = JSON.parse(raw);
    const ageMinutes = (Date.now() - tokenData.stored_at) / 1000 / 60;
    if (ageMinutes > expirationMinutes) {
      sessionStorage.removeItem(TOKEN_KEY);
      return null;
    }
    return tokenData.value;
  } catch {
    sessionStorage.removeItem(TOKEN_KEY);
    return null;
  }
}

function disableButton(button) {
  button.setAttribute('disabled', 'disabled');
}

function joinPath(base, name) {
  if (!base || base === '/') {
    return `/${name}`;
  }

  const sanitizedBase = base.endsWith('/') ? base.slice(0, -1) : base;
  return `${sanitizedBase}/${name}`;
}
