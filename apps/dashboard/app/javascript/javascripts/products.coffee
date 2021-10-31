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
      cmd = $(@).data('cmd')
      target =$(@).data('target')
      header = "$ <code><strong>#{cmd}</strong></code>\n"
      $("#{id} .modal-title").html """
        <i class="fa fa-spinner fa-spin float-right" aria-hidden="true" id="#{id.substring(1)}Spinner"></i>
        #{title}
      """
      $("#{id} .product-cli-body").html header
      xhr = new XMLHttpRequest
      xhr.onreadystatechange = ->
        if @status == 200
          $("#{id} .product-cli-body").html "#{header}#{@responseText}"
          $("#{id} .product-cli-body").scrollTop $("#{id} .product-cli-body")[0].scrollHeight
      xhr.onloadend = ->
        $("#{id}Spinner").replaceWith """
          <button class="close float-right" data-dismiss="modal">&times;</button>
        """
        if @status != 200
          $("#{id} .product-cli-body").html "#{header}A fatal error has occurred"
      xhr.open 'PATCH', target
      xhr.setRequestHeader 'X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')
      xhr.setRequestHeader 'X-Requested-With', 'XMLHttpRequest'
      xhr.send()
      $(id).modal 'show'
  }, '[data-toggle="cli"]'
