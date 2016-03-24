--[[
  set_reverse_proxy

  Modify a given request to utilize mod_proxy for reverse proxying.
--]]
function set_reverse_proxy(r, conn)
  -- find protocol used by parsing the request headers
  local protocol = (r.headers_in['Upgrade'] and "ws://" or "http://")

  -- setup request to use mod_proxy for the reverse proxy
  r.handler = "proxy-server"
  r.proxyreq = apache2.PROXYREQ_REVERSE

  -- define reverse proxy destination using connection object
  if conn.socket then
    r.filename = "proxy:unix:" .. conn.socket .. "|" .. protocol .. "localhost" .. conn.uri
  else
    r.filename = "proxy:" .. protocol .. conn.server .. conn.uri
  end

  -- include useful information for the backend server
  r.headers_in['Host'] = r.hostname .. ":" .. r.port            -- force it to include port along with host
  r.headers_in['X-Forwarded-User'] = conn.user or ""            -- provide authenticated user name
  r.headers_in['X-Forwarded-Escaped-Uri'] = r:escape(conn.uri)  -- **required** by PUN when initializing app
end
