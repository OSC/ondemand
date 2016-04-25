local user_map = require 'ood.user_map'
local proxy    = require 'ood.proxy'
local http     = require 'ood.http'

--[[
  pun_proxy_handler

  Maps an authenticated user to a system user. Then proxies user's traffic to
  user's backend PUN through a Unix domain socket. If the backend PUN is down,
  then launch the user's PUN through a redirect.
--]]
function pun_proxy_handler(r)
  -- read in OOD specific settings defined in Apache config
  local user_map_cmd    = r.subprocess_env['OOD_USER_MAP_CMD']
  local pun_socket_root = r.subprocess_env['OOD_PUN_SOCKET_ROOT']
  local nginx_uri       = r.subprocess_env['OOD_NGINX_URI']
  local map_fail_uri = r.subprocess_env['OOD_MAP_FAIL_URI']

  -- get the system-level user name
  local user = user_map.map(r, user_map_cmd)
  if not user then
    if map_fail_uri then
      return http.http302(r, map_fail_uri)
    else
      return http.http404(r, "failed to map user (" .. r.user .. ")")
    end
  end

  -- generate connection object used in setting the reverse proxy
  local conn = {}
  conn.user = user
  conn.socket = pun_socket_root .. "/" .. user .. "/passenger.sock"
  conn.uri = r.unparsed_uri

  -- setup request for reverse proxy
  proxy.set_reverse_proxy(r, conn)

  -- handle if backend server is down
  r:custom_response(503, nginx_uri .. "/start?redir=" .. r:escape(conn.uri))

  -- let the proxy handler do this instead
  return apache2.DECLINED
end
