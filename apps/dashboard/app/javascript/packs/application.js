/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb
//
// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

import 'jquery-migrate'
import 'jquery-ujs'

// Import DataTables
import 'datatables.net'
import 'datatables.net-bs4/js/dataTables.bootstrap4'

import 'datatables.net-select'
import 'datatables.net-select-bs4'

// Import popper.js for Bootstrap 4
import 'popper.js'

// Import Bootstrap 4
import 'bootstrap/dist/js/bootstrap'

// Import application stylesheets
require.context('../stylesheets', true)
