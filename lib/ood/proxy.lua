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

  -- provide the protocol used
  r.headers_in['X-Forwarded-Proto'] = r.is_https and "https" or "http"

  -- provide the authenticated user name
  r.headers_in['X-Forwarded-User'] = conn.user or ""

  -- **required** by PUN when initializing app
  r.headers_in['X-Forwarded-Escaped-Uri'] = r:escape(conn.uri)
end

return {
  set_reverse_proxy = set_reverse_proxy
}
