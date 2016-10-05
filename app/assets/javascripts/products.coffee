# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  # Create data table
  $('#productTable').DataTable()

  # Add CLI modal feature
  $(document).on {
    'click': ->
      id = '#productCliModal'
      title = $(@).data('title')
      target =$(@).data('target')
      $("#{id} .modal-title").html """
        <i class="fa fa-spinner fa-spin pull-right" id="#{id.substring(1)}Spinner"></i>
        #{title}
      """
      $("#{id} pre").html """
        Loading...
      """
      xhr = new XMLHttpRequest
      xhr.onreadystatechange = ->
        if @status == 200
          $("#{id} pre").html @responseText
          $("#{id} pre").scrollTop $("#{id} pre")[0].scrollHeight
      xhr.onloadend = ->
        $("#{id}Spinner").replaceWith """
          <button class="close pull-right" data-dismiss="modal">&times;</button>
        """
        if @status != 200
          $("#{id} pre").html 'Error'
      xhr.open 'PATCH', target
      xhr.setRequestHeader 'X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')
      xhr.setRequestHeader 'X-Requested-With', 'XMLHttpRequest'
      xhr.send()
      $(id).modal 'show'
  }, '[data-toggle="cli"]'
