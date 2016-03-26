local user_map = require 'ood.user_map'
local proxy    = require 'ood.proxy'

--[[
  pun_proxy_handler

  Maps an authenticated user to a system user. Then proxies user's traffic to
  user's backend PUN through a Unix domain socket. If the backend PUN is down,
  then launch the user's PUN through a redirect.
--]]
function pun_proxy_handler(r)
  -- read in OOD specific settings defined in Apache config
  local user_map_cmd     = r.subprocess_env['OOD_USER_MAP_CMD']
  local pun_socket_root  = r.subprocess_env['OOD_PUN_SOCKET_ROOT']

  -- get the system-level user name
  local user = user_map.map(r, user_map_cmd)

  -- generate connection object used in setting the reverse proxy
  local conn = {}
  conn.user = user
  conn.socket = pun_socket_root .. "/" .. user .. "/passenger.sock"
  conn.uri = r.unparsed_uri

  -- setup request for reverse proxy
  proxy.set_reverse_proxy(r, conn)

  -- handle if backend server is down
  r:custom_response(503, "/nginx/start?redir=" .. r:escape(conn.uri))

  -- let the proxy handler do this instead
  return apache2.DECLINED
end
