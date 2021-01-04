# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#
# Timer object
#

class Timer
  constructor: (@callback, @delay) ->
    @remaining = @delay
    @active = true
    @resume()
  resume: () ->
    return unless @active
    @start = new Date()
    clearTimeout(@timerId)
    @timerId = setTimeout(@callback, @remaining)
  restart: () ->
    return unless @active
    @remaining = @delay
    @resume()
  pause: () ->
    return unless @active
    clearTimeout(@timerId)
    @remaining -= new Date() - @start
  stop: () ->
    return unless @active
    clearTimeout(@timerId)
    @active = false

#
# Poller object
#

class Poller
  constructor: (@url, @delay) ->
    @poll()
  poll: ->
    @timer = new Timer(@request.bind(this), @delay)
  request: ->
    that = this
    $.getScript(@url).done((script, textStatus, jqxhr) ->
      console.log textStatus
      return
    ).fail((jqxhr, textStatus, errorThrown) ->
      console.log textStatus
      return
    ).always(() ->
      that.poll()
      return
    )
  pause: () ->
    @timer.pause()
  resume: () ->
    @timer.resume()

#
# Run on document load
#

jQuery ->
  # Pollers used
  polls = []

  # Look for pollers and start them
  $('[data-toggle="poll"]').each ->
    url   = $(this).data('url')
    delay = $(this).data('delay')
    polls.push(new Poller(url, delay)) if url && delay

  # Pause pollers when modal appears
  # (as modal may bind to object that gets replaced such as "delete")
  $(document).on
    'show.bs.modal': ->
      for poll in polls
        poll.pause()  # pause pollers
    'hidden.bs.modal': ->
      for poll in polls
        poll.resume() # resume pollers
