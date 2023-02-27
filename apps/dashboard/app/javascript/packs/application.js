/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_include_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb
//
// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

import jQuery from 'jquery';
import 'jquery-ujs';
import datatables from 'datatables.net';
import datatablesBs4 from 'datatables.net-bs4/js/dataTables.bootstrap4';
import datatablesSelect from 'datatables.net-select/js/dataTables.select';

import Rails from '@rails/ujs';

// Import popper.js for Bootstrap 4
import Popper from 'popper.js';

// Import Bootstrap 4
import 'bootstrap/dist/js/bootstrap';

// FIXME: confim modals don't work in esbuild.
// import 'data-confirm-modal';

// lot's of inline scripts and stuff rely on jquery just being available
window.jQuery = jQuery;
window.$ = jQuery;

// these plugins don't automatically load, so this loads them.
datatables(window, jQuery);
datatablesBs4(window, jQuery);
datatablesSelect(window, jQuery);

Rails.start();

jQuery(function(){

  $('li.vdi').popover({
    trigger: "hover",
    content: "A VDI (Virtual Desktop Interface) gives you desktop access to a shared node. This is the graphical version of a login node. Use this for lightweight tasks like accessing & viewing files, submitting jobs, and for visualizations.",
    title: function(){ return $(this).text() }
  });

  $('li.ihpc').popover({
    trigger: "hover",
    content: "An Interactive HPC session gives you dedicated access to one or more nodes on the cluster. This is similar to an interactive batch session with an accessible desktop on the primary node. Use this for heavyweight jobs such as long-running compute tasks or where you need dedicated resources.",
    title: function(){ return $(this).text() }
  });

  $('[data-toggle="popover"]').popover();
  $('[data-toggle="tooltip"]').tooltip();
});
