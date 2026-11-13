import { storeBoolean } from './utils';
import { csrfToken, settingsPath, safeViewingEnabled as serverSafeViewingEnabled } from './config';

export const STORAGE_KEY = 'ood_safe_viewing';
export const SAFE_VIEWING_CHANGE_EVENT = 'ood-safe-viewing-change';

export function isSafeViewingEnabled() {
  return document.documentElement.getAttribute('data-bs-theme') === 'dark'
    || document.documentElement.classList.contains('ood-safe-viewing');
}

export function applySafeViewing(enabled) {
  const html = document.documentElement;

  if (enabled) {
    html.setAttribute('data-bs-theme', 'dark');
    html.classList.add('ood-safe-viewing');
  } else {
    html.removeAttribute('data-bs-theme');
    html.classList.remove('ood-safe-viewing');
  }

  updateToggleButton(enabled);
  document.dispatchEvent(
    new CustomEvent(SAFE_VIEWING_CHANGE_EVENT, { detail: { enabled } })
  );
}

function updateToggleButton(enabled) {
  const button = document.getElementById('ood_dark_mode_toggle');
  if (!button) {
    return;
  }

  button.setAttribute('aria-pressed', enabled ? 'true' : 'false');
  button.classList.toggle('ood-theme-toggle--dark', enabled);
  button.title = enabled ? button.dataset.disableLabel : button.dataset.enableLabel;
}

function clearLocalFallback() {
  try {
    localStorage.removeItem(STORAGE_KEY);
  } catch (_e) {
    // localStorage may be unavailable in private browsing
  }
}

function persistSafeViewing(enabled) {
  const body = new URLSearchParams();
  body.append('settings[safe_viewing]', enabled ? 'true' : 'false');

  return fetch(settingsPath(), {
    method: 'POST',
    headers: {
      'X-CSRF-Token': csrfToken(),
      Accept: 'application/json',
    },
    body,
  }).then((response) => {
    if (!response.ok) {
      throw new Error(`Failed to persist safe viewing (${response.status})`);
    }
    // UserSettingStore is source of truth — drop any device-local fallback.
    clearLocalFallback();
  }).catch(() => {
    // Remember on this device only when the server write fails.
    storeBoolean(STORAGE_KEY, enabled);
  });
}

export function initDarkMode() {
  const button = document.getElementById('ood_dark_mode_toggle');
  if (!button) {
    return;
  }

  // Trust server-rendered UserSettingStore (and default_to_dark_mode).
  // localStorage is only a write-failure fallback, never an override.
  applySafeViewing(serverSafeViewingEnabled());

  button.addEventListener('click', () => {
    const next = !isSafeViewingEnabled();
    applySafeViewing(next);
    persistSafeViewing(next);
  });
}
