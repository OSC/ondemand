-- Standalone handler tests for the secure rnode request validation.

local proxy_calls = {}

package.preload['ood.user_map'] = function()
  return { map = function() return 'mapped-user' end }
end

package.preload['ood.proxy'] = function()
  return {
    set_reverse_proxy = function(_, conn)
      proxy_calls[#proxy_calls + 1] = conn
    end
  }
end

package.preload['ood.http'] = function()
  return {
    http302 = function() end,
    http404 = function() end
  }
end

apache2 = { DONE = 0, DECLINED = -1 }

local script_root = arg[0]:match('^(.*)/mod_ood_proxy/spec/[^/]+$') or '.'
dofile(script_root .. '/mod_ood_proxy/lib/node_proxy.lua')

local function request(options)
  options = options or {}
  proxy_calls = {}

  local prefix = options.prefix or '/secure-rnode'
  local host = options.host or 'compute1.site.edu'
  local port = options.port or '443'
  local uri = options.uri or '/index.html'
  local raw_target = options.raw_target or (prefix .. '/' .. host .. '/' .. port .. uri)
  local env = {
    MATCH_HOST = host,
    MATCH_PORT = port,
    MATCH_URI = uri
  }

  if options.secure ~= false then
    env.OOD_SECURE_RNODE = '1'
    env.OOD_SECURE_RNODE_PREFIX = prefix
    env.OOD_SECURE_RNODE_PORTS = options.allowed_ports
  end

  local r = {
    subprocess_env = env,
    unparsed_uri = raw_target,
    uri = raw_target,
    user = 'test-user',
    write = function(self, body) self.response_body = body end,
    custom_response = function() end
  }

  return node_proxy_handler(r), r
end

local passed = 0

local function accepts(name, options)
  options = options or {}
  local result = request(options)
  assert(result == apache2.DECLINED, name .. ': expected request to be proxied')
  assert(#proxy_calls == 1, name .. ': expected one proxy call')
  assert(proxy_calls[1].server == (options.host or 'compute1.site.edu') .. ':' .. (options.port or '443'),
    name .. ': unexpected proxy server')
  assert(proxy_calls[1].uri == (options.uri or '/index.html'), name .. ': unexpected proxy URI')
  passed = passed + 1
end

local function rejects(name, options)
  local result, r = request(options)
  assert(result == apache2.DONE, name .. ': expected request to be rejected')
  assert(r.status == 400, name .. ': expected HTTP 400')
  assert(r.response_body == 'Error -- invalid proxy target', name .. ': expected invalid-target response')
  assert(#proxy_calls == 0, name .. ': rejected request reached proxy setup')
  passed = passed + 1
end

accepts('allowlisted port', { allowed_ports = '443,8443' })
accepts('second allowlisted port', { port = '8443', allowed_ports = '443,8443' })
accepts('no port allowlist preserves valid ports', { port = '80' })
accepts('bracketed IPv6 host', { host = '[2001:db8::1]' })

rejects('port outside allowlist', { allowed_ports = '8443' })
for _, port in ipairs({ '0', '65536', '123456', 'abc' }) do
  rejects('invalid port ' .. port, { port = port })
end

for _, host in ipairs({ 'compute1@evil', 'compute1/evil', 'compute1%2eevil', 'compute1\\evil' }) do
  rejects('invalid host ' .. host, { host = host })
end
rejects('overlong host', { host = string.rep('a', 254) })
rejects('malformed bracketed IPv6 host', { host = '[2001:db8::1' })

rejects('relative URI', { uri = 'index.html' })
rejects('URI containing backslash', { uri = '/app\\admin' })
rejects('URI containing control byte', { uri = '/app\nadmin' })
rejects('overlong URI', { uri = '/' .. string.rep('a', 8192) })

rejects('wrong raw prefix', { raw_target = '/other/compute1.site.edu/443/index.html' })
rejects('raw authority boundary suffix', { raw_target = '/secure-rnode/compute1.site.edu/443evil/index.html' })
rejects('encoded host delimiter', { raw_target = '/secure-rnode/%63ompute1.site.edu/443/index.html' })
for _, escape in ipairs({ '%2f', '%5c', '%25', '%23', '%3f', '%ZZ' }) do
  rejects('unsafe or malformed escape ' .. escape, {
    raw_target = '/secure-rnode/compute1.site.edu/443/app' .. escape .. 'admin'
  })
end

accepts('non-secure proxy route remains unchanged', {
  secure = false,
  host = 'backend@internal',
  port = '0',
  uri = 'relative-path'
})

print(string.format('%d Lua proxy validation checks passed', passed))
