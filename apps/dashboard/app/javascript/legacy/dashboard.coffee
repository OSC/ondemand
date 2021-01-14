$ ->
  $("a[target=_blank]").on "click", (event) ->
    # open url using javascript, instead of following directly
    event.preventDefault()

    if(window.open($(this).attr("href")) == null)
      # link was not opened in new window, so display error msg to user
      html = $("#js-alert-danger-template").html()
      msg = "This link is configured to open in a new window, but it doesn't seem to have opened. " +
            "Please disable your popup blocker for this page and try again."

      # replace message in alert and add to main div of layout
      $("div[role=main]").prepend(html.split("ALERT_MSG").join(msg))
