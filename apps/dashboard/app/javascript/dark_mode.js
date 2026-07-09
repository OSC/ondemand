import { storeBoolean, getBoolean } from './utils';

export const STORAGE_KEY = 'ood_safe_viewing';
export const SAFE_VIEWING_CHANGE_EVENT = 'ood-safe-viewing-change';

export function isSafeViewingEnabled() {
  return getBoolean(STORAGE_KEY);
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

export function initDarkMode() {
  applySafeViewing(isSafeViewingEnabled());

  const button = document.getElementById('ood_dark_mode_toggle');
  if (!button) {
    return;
  }

  button.addEventListener('click', () => {
    const enabled = !isSafeViewingEnabled();
    storeBoolean(STORAGE_KEY, enabled);
    applySafeViewing(enabled);
  });
}
