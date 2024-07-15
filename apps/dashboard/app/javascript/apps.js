'use strict';

import { configData } from './config.js';

jQuery(function() {
  const cfgData = configData();
  $('#all-apps-table').DataTable({
    stateSave: false,
    pageLength: cfgData['appsDatatablePageLength']
  });
});
