# Place all the Bootstrap related behaviors and hooks here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  # Must opt-in to use Bootstrap tooltips
  $('[data-toggle="tooltip"]').tooltip container: "body"
