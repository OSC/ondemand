'use strict';

import { openLinkInJs } from './utils';

document.addEventListener('DOMContentLoaded', () => {
  const anchors = document.querySelectorAll('a[target=_blank]');

  anchors.forEach(anchor => {
    anchor.addEventListener('click', (event) => { openLinkInJs(event); });
  });
});
