/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

// Import FontAwesome
require.context('../../assets/images', true)

// Import legacy stylesheets
require.context('../../assets/stylesheets', true)

import '@fortawesome/fontawesome-free'
import { library } from '@fortawesome/fontawesome-svg-core'
import { fas } from '@fortawesome/free-solid-svg-icons'

library.add(fas)

require('datatables.net-bs/css/dataTables.bootstrap')
require('datatables.net-bs/js/dataTables.bootstrap')

// Add Bootstrap 3 and JS plugins
import 'bootstrap/dist/css/bootstrap'
import 'bootstrap/dist/js/bootstrap'

document.addEventListener('DOMContentLoaded', () => {
  console.log('Loaded!')
  $('[data-toggle="popover"]').popover()
})

// Legacy JS imports
import '../legacy/application'
import '../legacy/products.coffee'
import '../legacy/dashboard.coffee'
import '../legacy/batch_connect/sessions.coffee'
