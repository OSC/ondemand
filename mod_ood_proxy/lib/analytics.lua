
--[[
  analytics_handler

  Hooks into the final logging stage to parse the response headers before
  phoning home with analytics (required by OOD proposal).
--]]
function analytics_handler(r)
  local json = require 'ood.json'

  -- read in OOD specific settings defined in the Apache config
  local url = 'https://www.google-analytics.com/mp/collect'
  local tracking_id  = r.subprocess_env['OOD_GA_TRACKING_ID'] or r.subprocess_env['OOD_ANALYTICS_TRACKING_ID']
  local api_key      = r.subprocess_env['OOD_GA_API_SECRET']

  -- read in variables set previously in the request by mod_ood_proxy
  local user              = r.subprocess_env['MAPPED_USER'] -- set by the user mapping code

  -- only track HTML pages and authenticated users
  if (r.headers_out['Content-Type'] or ''):match('text/html') and user then
    local data = {}
    data['name']        = 'pageview'

    -- user
    local client_id     = r:md5(user)

    -- session
    data['ip']          = r.useragent_ip
    data['user_agent']  = r.headers_in['User-Agent'] or ''

    -- traffic sources
    data['referrer']    = (r.headers_in['Referer'] or ''):match('^([^?]*)')

    -- system info
    data['encoding']    = ((r.headers_out['Content-Type'] or ''):match('charset=([%w-]+)') or ''):lower()
    data['language']    = ((r.headers_in['Accept-Language'] or ''):match('^([%w-]+)') or ''):lower()

    -- content information
    data['host']        = r.server_name
    data['path']        = r.uri
    data['method']      = r.method

    local now = r:clock()
    event_data = json.table_to_json(data)
    post_body = json.ga_body(client_id, event_data)
    full_url = string.format("%s?measurement_id=%s&api_secret=%s", url, tracking_id, api_key)

    local handle = io.popen("wget --header='Content-type: application/json' --post-data='" .. post_body .. "' '" .. full_url .. "' -O /dev/null -T 5 -nv 2>&1")
    output = handle:read('*all'):match('^%s*(.-)%s*$')
    handle:close()
    r:debug("Analytics input: '" .. event_data .. "'")
    r:debug("Analytics output: '" .. r:escape_logitem(output) .. "' [" .. (r:clock() - now)/1000.0 .. " ms]")
  end

  return apache2.DECLINED
end
