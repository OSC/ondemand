/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb
import OnDemand from 'ondemand'

const images = require.context('../images', true)
const imagePath = (name) => images(name, true)

window.$ = jQuery;
window.DataTable = require('datatables.net-bs')

require('bootstrap/dist/js/bootstrap')
require('@popperjs/core')

// Import OnDemand styles
require('../../assets/javascripts/application')

require('./dashboard')
require('./products')

require('stylesheets/application')

console.log(OnDemand)
