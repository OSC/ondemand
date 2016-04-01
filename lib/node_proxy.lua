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
  local node_uri     = r.subprocess_env['OOD_NODE_URI']
  local is_relative  = r.subprocess_env['OOD_IS_RELATIVE']

  -- get the system-level user name
  local user = user_map.map(r, user_map_cmd)
  if not user then return http.http404(r, "failed to map user (" .. r.user .. ")") end

  -- get the host & port of webserver on backend node from request
  local host, port, rel_uri = r.unparsed_uri:match("^" .. node_uri .. "/([^/]+)/([^/]+)(.*)")

  -- generate connection object used in setting the reverse proxy
  local conn = {}
  conn.user = user
  conn.server = host .. ":" .. port
  conn.uri = is_relative and rel_uri or r.unparsed_uri

  -- setup request for reverse proxy
  proxy.set_reverse_proxy(r, conn)

  -- handle if backend server is down
  r:custom_response(503, "Failed to connect to " .. conn.server)

  -- let the proxy handler do this instead
  return apache2.DECLINED
end
