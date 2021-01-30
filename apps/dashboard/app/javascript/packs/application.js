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

// Import local assets with Webpack Context Module API.
// https://webpack.js.org/guides/dependency-management/#context-module-api
const cache = {}

function importAll (r) {
  r.keys().forEach(key => cache[key] = r(key))
}

// Import images
importAll(require.context('../../assets/images', true))

// Import legacy Javascript and CoffeeScript
importAll(require.context('../legacy', true, /\.(js|coffee)$/))

// Import legacy stylesheets
importAll(require.context('../../assets/stylesheets', true))

// Import Font Awesome icons.
import '@fortawesome/fontawesome-free'
import { library } from '@fortawesome/fontawesome-svg-core'
import { fas } from '@fortawesome/free-solid-svg-icons'

library.add(fas)

require('datatables.net-bs/css/dataTables.bootstrap')
require('datatables.net-bs/js/dataTables.bootstrap')

// Add Bootstrap 3 and JS plugins
import 'bootstrap/dist/css/bootstrap'
import 'bootstrap/dist/js/bootstrap'
