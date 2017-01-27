local user_map = require 'ood.user_map'
local proxy    = require 'ood.proxy'
local http     = require 'ood.http'

--[[
  node_proxy_handler

  Maps an authenticated user to a system user. Then proxies user's traffic to a
  backend node with the host and port specified in the request URI.
--]]
function node_proxy_handler(r)
  -- read in OOD specific settings defined in Apache config
  local user_map_cmd = r.subprocess_env['OOD_USER_MAP_CMD']
  local map_fail_uri = r.subprocess_env['OOD_MAP_FAIL_URI']
  local host_regex   = r.subprocess_env['OOD_HOST_REGEX'] or "^.*$"

  -- read in <LocationMatch> regular expression captures
  local host = r.subprocess_env['MATCH_HOST']
  local port = r.subprocess_env['MATCH_PORT']
  local uri  = r.subprocess_env['MATCH_URI'] or r.unparsed_uri

  -- get the system-level user name
  local user = user_map.map(r, user_map_cmd)
  if not user then
    if map_fail_uri then
      return http.http302(r, map_fail_uri .. "?redir=" .. r:escape(r.unparsed_uri))
    else
      return http.http404(r, "failed to map user (" .. r.user .. ")")
    end
  end

  -- confirm host is allowed through regular expression matching
  if not r:regex(host, host_regex) then
    return http.http404(r, "invalid host specified (" .. host .. ")")
  end

  -- generate connection object used in setting the reverse proxy
  local conn = {}
  conn.user = user
  conn.server = host .. ":" .. port
  conn.uri = uri

  -- setup request for reverse proxy
  proxy.set_reverse_proxy(r, conn)

  -- handle if backend server is down
  r:custom_response(503, "Failed to connect to " .. conn.server)

  -- let the proxy handler do this instead
  return apache2.DECLINED
end
