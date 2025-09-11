'use strict';

import { appsDatatablePageLength } from './config.js';

jQuery(function() {
  const pageLength = appsDatatablePageLength();
  $('#all-apps-table').DataTable({
    stateSave: false,
    pageLength: pageLength
  });

  // Popover overflow management
  $('body').on('inserted.bs.popover', function(){
    $('.app-settings-popup .row').each(function () {
      const $row = $(this);
      const rowWidth = $row.width();
      dtWidth = $row.find('dt').outerWidth(true);
      ddWidth = $row.find('dd').outerWidth(true);

      totalContentWidth = ddWidth + dtWidth
      if (totalContentWidth > rowWidth) {
        $row.find('dt').css('max-width', rowWidth - ddWidth)
      }
    });
  });
});
