'use strict';

import { attachPathSelectors }  from './path_selector/path_selector';

function onFirstFrameRender(event) {
  const frame = event.target;
  if (!(frame instanceof HTMLElement)) return;
  if (frame.id !== 'import_pane') return;

  attachPathSelectors();

  document.removeEventListener('turbo:frame-render', onFirstFrameRender);
}

jQuery(function() {
  document.addEventListener('turbo:frame-render', onFirstFrameRender);
});
