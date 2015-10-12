
((i, s, o, g, r, a, m) ->
  i['GoogleAnalyticsObject'] = r
  i[r] = i[r] or ->
      (i[r].q = i[r].q or []).push arguments
      return

  i[r].l = 1 * new Date
  a = s.createElement(o)
  m = s.getElementsByTagName(o)[0]
  a.async = 1
  a.src = g
  m.parentNode.insertBefore a, m
  return
) window, document, 'script', '//www.google-analytics.com/analytics.js', 'ga'
ga 'create', 'UA-66793213-1', 'auto'
ga 'set', 'anonymizeIp', 'true'
ga 'set', '&uid', JobStatusapp.user
ga 'set', 'dimension1', JobStatusapp.app
ga 'set', 'dimension2', JobStatusapp.user
ga 'send', 'pageview'

jQuery ->
# Record event when page loaded
  $(document).ready (e) ->
    ga('send', 'event', 'jobstatus', 'page loaded');