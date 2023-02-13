--[[
  logger

  Hooks into the final logging stage to parse the response headers before
  outputting to the logs.
--]]
function logger(r)
  -- read in variables set previously in the request by mod_ood_proxy
  local user              = r.subprocess_env["MAPPED_USER"] -- set by the user mapping code
  local time_user_map     = r.subprocess_env["OOD_TIME_USER_MAP"] -- set by the user mapping code
  local time_begin_proxy  = r.subprocess_env["OOD_TIME_BEGIN_PROXY"] -- set by the proxy code
  local rails_config_hosts = r.subprocess_env["OOD_ALLOWED_HOSTS"]

  -- only log authenticated users
  if user then
    local time = r:clock()
    local msg  = {}

    -- log hook id
    msg["log_hook"] = "ood"

    -- log
    msg["log_time"] = os.date("!%Y-%m-%dT%T", math.floor(time / 1000000)) .. "." .. time % 1000000 .. "Z"
    msg["log_id"]   = r.log_id

    -- user
    msg["local_user"]  = user
    msg["remote_user"] = r.user

    msg["rails_config_hosts"] = rails_config_hosts

    -- request
    msg["req_user_ip"]      = r.useragent_ip
    msg["req_method"]       = r.method
    msg["req_status"]       = r.status
    msg["req_uri"]          = r.uri
    msg["req_protocol"]     = r.protocol
    msg["req_hostname"]     = r.hostname
    msg["req_port"]         = r.port
    msg["req_server_name"]  = r.server_name
    msg["req_handler"]      = r.handler or ""
    msg["req_filename"]     = r.filename
    msg["req_is_https"]     = r.is_https and true or false
    msg["req_is_websocket"] = r.headers_in["Upgrade"] and true or false

    -- request headers
    msg["req_referer"]         = (r.headers_in["Referer"] or ""):match("^([^?]*)")
    msg["req_user_agent"]      = (r.headers_in["User-Agent"] or "")
    msg["req_accept"]          = (r.headers_in["Accept"] or ""):lower()
    msg["req_accept_charset"]  = (r.headers_in["Accept-Charset"] or ""):lower()
    msg["req_accept_encoding"] = (r.headers_in["Accept-Encoding"] or ""):lower()
    msg["req_accept_language"] = (r.headers_in["Accept-Language"] or ""):lower()
    msg["req_cache_control"]   = (r.headers_in["Cache-Control"] or ""):lower()
    msg["req_content_type"]    = (r.headers_in["Content-Type"] or ""):lower()
    msg["req_origin"]          = (r.headers_in["Origin"] or "")

    -- response headers
    msg["res_content_encoding"] = (r.headers_out["Content-Encoding"] or ""):lower()
    msg["res_content_length"]   = (r.headers_out["Content-Length"] or "")
    msg["res_content_type"]     = (r.headers_out["Content-Type"] or ""):lower()
    msg["res_content_disp"]     = (r.headers_out["Content-Disposition"] or "")
    msg["res_content_location"] = (r.headers_out["Content-Location"] or "")
    msg["res_content_language"] = (r.headers_out["Content-Language"] or "")
    msg["res_location"]         = (r.headers_out["Location"] or "")

    -- benchmarks
    msg["time_proxy"]    = time_begin_proxy and (r:clock() - time_begin_proxy)/1000.0 or 0
    msg["time_user_map"] = time_user_map and tonumber(time_user_map) or 0

    msg_str = {}
    for k, v in pairs(msg) do
      table.insert(msg_str, k .. "=\"" .. string.gsub(tostring(v), "\"", "'") .. "\"")
    end
    r:info(table.concat(msg_str, " "))
  end

  return apache2.DECLINED
end
