--[[
  analytics_handler

  Hooks into the final logging stage to parse the response headers before
  phoning home with analytics (required by OOD proposal).
--]]
function analytics_handler(r)
  -- read in OOD specific settings defined in the Apache config
  local tracking_url = r.subprocess_env['OOD_ANALYTICS_TRACKING_URL']
  local tracking_id  = r.subprocess_env['OOD_ANALYTICS_TRACKING_ID']

  -- read in variables set previously in the request by mod_ood_proxy
  local user              = r.subprocess_env['MAPPED_USER'] -- set by the user mapping code
  local time_user_map     = r.subprocess_env['OOD_TIME_USER_MAP'] -- set by the user mapping code
  local time_begin_proxy  = r.subprocess_env['OOD_TIME_BEGIN_PROXY'] -- set by the proxy code

  -- only track HTML pages and authenticated users
  if (r.headers_out['Content-Type'] or ''):match('text/html') and user then
    local version = '1'
    local hit_type = 'pageview'

    -- user
    local client_id = user .. '@' .. r.server_name
    local user_id   = user .. '@' .. r.server_name

    -- session
    local user_ip    = r.useragent_ip
    local user_agent = r.headers_in['User-Agent'] or ''

    -- traffic sources
    local doc_referrer = (r.headers_in['Referer'] or ''):match('^([^?]*)')

    -- system info
    local doc_encoding  = ((r.headers_out['Content-Type'] or ''):match('charset=([%w-]+)') or ''):lower()
    local user_language = ((r.headers_in['Accept-Language'] or ''):match('^([%w-]+)') or ''):lower()

    -- content information
    local doc_host = r.server_name
    local doc_path = r.uri

    -- extra computed properties
    local unique_id  = r:sha1(user .. user_ip .. doc_host .. doc_path .. r:clock())
    local time_proxy = time_begin_proxy and math.floor((r:clock() - time_begin_proxy)/1000.0) or 0
    local time_user_map = time_user_map and math.floor(time_user_map) or 0

    -- custom dimensions / metrics
    local cd1 = user                     -- Username        (User)
    local cd2 = unique_id                -- Session ID      (Session)
    local cd3 = os.date('!%Y-%m-%dT%TZ') -- Timestamp       (Hit)
    local cd4 = r.user                   -- Remote Username (Hit)
    local cd5 = r.method                 -- Request Method  (Hit)
    local cd6 = tostring(r.status)       -- Request Status  (Hit)
    local cm1 = tostring(time_proxy)     -- Proxy Time      (Hit/Integer)
    local cm2 = tostring(time_user_map)  -- User Map Time   (Hit/Integer)

    -- process analytics
    local now = r:clock()
    local query = 'v=' .. r:escape(version) ..
      '&t='   .. r:escape(hit_type) ..
      '&tid=' .. r:escape(tracking_id) ..
      '&cid=' .. r:escape(client_id) ..
      '&uid=' .. r:escape(user_id) ..
      '&uip=' .. r:escape(user_ip) ..
      '&ua='  .. r:escape(user_agent) ..
      '&dr='  .. r:escape(doc_referrer) ..
      '&de='  .. r:escape(doc_encoding) ..
      '&ul='  .. r:escape(user_language) ..
      '&dh='  .. r:escape(doc_host) ..
      '&dp='  .. r:escape(doc_path) ..
      '&cd1=' .. r:escape(cd1) ..
      '&cd2=' .. r:escape(cd2) ..
      '&cd3=' .. r:escape(cd3) ..
      '&cd4=' .. r:escape(cd4) ..
      '&cd5=' .. r:escape(cd5) ..
      '&cd6=' .. r:escape(cd6) ..
      '&cm1=' .. r:escape(cm1) ..
      '&cm2=' .. r:escape(cm2)
    local handle = io.popen("wget --post-data='" .. query .. "' " .. tracking_url .. " -O /dev/null -T 5 -nv 2>&1")
    output = handle:read('*all'):match('^%s*(.-)%s*$')
    handle:close()
    r:info("Analytics input: '" .. query .. "'")
    r:info("Analytics output: '" .. r:escape_logitem(output) .. "' [" .. (r:clock() - now)/1000.0 .. " ms]")
  end

  return apache2.DECLINED
end
