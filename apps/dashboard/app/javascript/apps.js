'use strict';

import { appsDatatablePageLength } from './config.js';

jQuery(function() {
  const pageLength = appsDatatablePageLength();
  $('#all-apps-table').DataTable({
    stateSave: false,
    pageLength: pageLength
  });
});
