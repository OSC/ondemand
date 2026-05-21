import { storeBoolean, getBoolean } from './utils';

export const STORAGE_KEY = 'ood_safe_viewing';

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
}

function updateToggleButton(enabled) {
  const button = document.getElementById('ood_dark_mode_toggle');
  if (!button) {
    return;
  }

  const enableLabel = button.dataset.enableLabel;
  const disableLabel = button.dataset.disableLabel;
  const icon = button.querySelector('i');

  button.setAttribute('aria-pressed', enabled ? 'true' : 'false');
  button.title = enabled ? disableLabel : enableLabel;

  if (icon) {
    icon.classList.toggle('fa-moon', !enabled);
    icon.classList.toggle('fa-sun', enabled);
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
