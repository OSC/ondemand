local user_map = require 'ood.user_map'
local proxy    = require 'ood.proxy'
local http     = require 'ood.http'

local MAX_PROXY_HOST_BYTES = 253
local MAX_PROXY_URI_BYTES = 8192
local MAX_RAW_TARGET_BYTES = 16384

local function invalid_proxy_target(r)
  r.status = 400
  r:write("Error -- invalid proxy target")
  return apache2.DONE
end

local function valid_proxy_port(port)
  if type(port) ~= 'string' or #port == 0 or #port > 5 or not string.match(port, '^%d+$') then
    return false
  end

  local number = tonumber(port)
  return number ~= nil and number >= 1 and number <= 65535
end

local function valid_secure_rnode_host(host)
  if type(host) ~= 'string' or #host == 0 or #host > MAX_PROXY_HOST_BYTES then
    return false
  end

  for i = 1, #host do
    local byte = string.byte(host, i)
    if byte <= 32 or byte == 127 or byte >= 128 then
      return false
    end
  end

  for _, delimiter in ipairs({'/', '\\', '?', '#', '@', '%'}) do
    if string.find(host, delimiter, 1, true) then
      return false
    end
  end

  if string.find(host, ':', 1, true) then
    return string.match(host, '^%[[0-9A-Fa-f:.]+%]$') ~= nil
  end

  if string.find(host, '[', 1, true) or string.find(host, ']', 1, true) then
    return false
  end

  return true
end

local function valid_secure_rnode_uri(uri)
  if type(uri) ~= 'string' or #uri > MAX_PROXY_URI_BYTES then
    return false
  end

  if uri ~= '' and string.sub(uri, 1, 1) ~= '/' then
    return false
  end

  for i = 1, #uri do
    local byte = string.byte(uri, i)
    if byte < 32 or byte == 127 or byte == 92 then
      return false
    end
  end

  return true
end

local function secure_rnode_port_allowed(port, allowed_ports)
  if allowed_ports == nil or allowed_ports == '' then
    return true
  end

  local number = tonumber(port)
  for item in string.gmatch(allowed_ports, '[^,]+') do
    if tonumber(item) == number then
      return true
    end
  end

  return false
end

local function valid_secure_rnode_raw_target(unparsed_uri, prefix, host, port)
  if type(unparsed_uri) ~= 'string' or #unparsed_uri == 0 or #unparsed_uri > MAX_RAW_TARGET_BYTES then
    return false
  end

  local raw_path = string.match(unparsed_uri, '^([^?]*)') or unparsed_uri
  if string.sub(raw_path, 1, 1) ~= '/' then
    return false
  end

  if type(prefix) ~= 'string' or #prefix == 0 or string.sub(prefix, 1, 1) ~= '/' then
    return false
  end

  local authority = prefix .. '/' .. host .. '/' .. port
  if string.sub(raw_path, 1, #authority) ~= authority then
    return false
  end

  local boundary = string.sub(raw_path, #authority + 1, #authority + 1)
  if boundary ~= '' and boundary ~= '/' then
    return false
  end

  local i = 1
  while i <= #raw_path do
    local byte = string.byte(raw_path, i)
    if byte < 32 or byte == 127 or byte == 35 or byte == 92 then
      return false
    end

    if byte == 37 then
      if i <= #authority or i + 2 > #raw_path then
        return false
      end

      local hex = string.sub(raw_path, i + 1, i + 2)
      if not string.match(hex, '^[0-9A-Fa-f][0-9A-Fa-f]$') then
        return false
      end

      local decoded = tonumber(hex, 16)
      if decoded < 32 or decoded == 127 or decoded == 37 or decoded == 47 or
          decoded == 92 or decoded == 35 or decoded == 63 then
        return false
      end
      i = i + 3
    else
      i = i + 1
    end
  end

  return true
end

--[[
  node_proxy_handler

  Maps an authenticated user to a system user. Then proxies user's traffic to a
  backend node with the host and port specified in the request URI.
--]]
function node_proxy_handler(r)
  -- read in OOD specific settings defined in Apache config
  local user_map_match  = r.subprocess_env['OOD_USER_MAP_MATCH']
  local user_map_cmd    = r.subprocess_env['OOD_USER_MAP_CMD']
  local user_env        = r.subprocess_env['OOD_USER_ENV']
  local map_fail_uri    = r.subprocess_env['OOD_MAP_FAIL_URI']
  local secure_rnode    = r.subprocess_env['OOD_SECURE_RNODE'] == '1'
  local secure_rnode_prefix = r.subprocess_env['OOD_SECURE_RNODE_PREFIX']
  local secure_rnode_ports = r.subprocess_env['OOD_SECURE_RNODE_PORTS']

  -- read in <LocationMatch> regular expression captures
  local host = r.subprocess_env['MATCH_HOST']
  local port = r.subprocess_env['MATCH_PORT']
  local uri  = r.subprocess_env['MATCH_URI']

  -- get the system-level user name
  local user = user_map.map(r, user_map_match, user_map_cmd, user_env and r.subprocess_env[user_env] or r.user)
  if not user then
    if map_fail_uri then
      return http.http302(r, map_fail_uri .. "?redir=" .. r:escape(r.unparsed_uri))
    else
      return http.http404(r, "failed to map user (" .. r.user .. ")")
    end
  end

  if secure_rnode and (not valid_proxy_port(port) or
      not secure_rnode_port_allowed(port, secure_rnode_ports) or
      not valid_secure_rnode_host(host) or not valid_secure_rnode_uri(uri or '') or
      not valid_secure_rnode_raw_target(r.unparsed_uri, secure_rnode_prefix, host, port)) then
    return invalid_proxy_target(r)
  end

  -- generate connection object used in setting the reverse proxy
  local conn = {}
  conn.user = user
  conn.server = host .. ":" .. port
  conn.uri = uri or r.uri or '/'

  -- last ditch effort to ensure that the uri is at least something
  -- because the request-line of an HTTP request _has_ to have something for a URL
  if conn.uri == '' then
    conn.uri = '/'
  end

  -- setup request for reverse proxy
  proxy.set_reverse_proxy(r, conn)

  -- handle if backend server is down
  r:custom_response(503, "Failed to connect to " .. conn.server)

  -- let the proxy handler do this instead
  return apache2.DECLINED
end
