'use strict';

import 'datatables.net'
import 'datatables.net-bs4/js/dataTables.bootstrap4'

jQuery(function() {
  $('#all-apps-table').DataTable({
    stateSave: true
  });
});
