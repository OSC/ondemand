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
import 'datatables.net';
import 'datatables.net-bs4/js/dataTables.bootstrap4';
import 'datatables.net-select/js/dataTables.select';
import 'datatables.net-plugins/api/processing().mjs';

// Enables hotwire Turbo Streams/Frames 
import "@hotwired/turbo-rails"
import { Turbo } from "@hotwired/turbo-rails"
// Disables Turbo Drive on an app-wide basis to prevent eager-loading links on mouse-over (which is annoying)
// Any links within a <turbo-stream> or <turbo-frame> tag will be eager-loaded as expected.
Turbo.session.drive = false

import Rails from '@rails/ujs';

// Import @popperjs/core for Bootstrap 5
import { createPopper } from '@popperjs/core';

// Import Bootstrap 5
import 'bootstrap/dist/js/bootstrap';

// lot's of inline scripts and stuff rely on jquery just being available
window.jQuery = jQuery;
window.$ = jQuery;

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

  $('[data-bs-toggle="popover"]').popover();
  $('[data-bs-toggle="tooltip"]').tooltip();
});
