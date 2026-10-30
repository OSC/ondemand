import { storeBoolean, getBoolean } from './utils';
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

  const label = button.querySelector('.ood-theme-toggle__label');
  const lightLabel = button.dataset.lightLabel;
  const darkLabel = button.dataset.darkLabel;

  button.setAttribute('aria-pressed', enabled ? 'true' : 'false');
  button.classList.toggle('ood-theme-toggle--dark', enabled);
  button.title = enabled ? button.dataset.disableLabel : button.dataset.enableLabel;

  if (label) {
    label.textContent = enabled ? darkLabel : lightLabel;
  }
}

function persistSafeViewing(enabled) {
  storeBoolean(STORAGE_KEY, enabled);

  const body = new URLSearchParams();
  body.append('settings[safe_viewing]', enabled ? 'true' : 'false');

  return fetch(settingsPath(), {
    method: 'POST',
    headers: {
      'X-CSRF-Token': csrfToken(),
      Accept: 'application/json',
    },
    body,
  }).catch(() => {
    // Preference remains in localStorage as a short-term fallback if the request fails.
  });
}

export function initDarkMode() {
  const button = document.getElementById('ood_dark_mode_toggle');
  if (!button) {
    return;
  }

  const serverEnabled = serverSafeViewingEnabled();
  const localEnabled = getBoolean(STORAGE_KEY);
  let enabled = serverEnabled;

  // Migrate legacy localStorage-only preference into UserSettingStore.
  if (!serverEnabled && localEnabled) {
    enabled = true;
    persistSafeViewing(true);
  } else {
    storeBoolean(STORAGE_KEY, enabled);
  }

  applySafeViewing(enabled);

  button.addEventListener('click', () => {
    const next = !isSafeViewingEnabled();
    applySafeViewing(next);
    persistSafeViewing(next);
  });
}
