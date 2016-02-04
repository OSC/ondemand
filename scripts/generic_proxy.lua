require 'map_user'

function read_file(filename)
    local input = io.open(filename, "r")
    local data = nil
    if input then
        data = input:read()
        input:close()
    end
    return data
end

function write_file(filename, data)
    local output = io.open(filename, "w")
    if output then
        output:write(data)
        output:close()
    end
end

function split(str, delim)
    local t = {}
    for i in string.gmatch(str, "([^" .. delim .. "]+)") do
        table.insert(t, i)
    end
    return t
end

function proxy_filename(r, user, server)
    local data_root = r.subprocess_env['PROXY_DATA_ROOT']
    return data_root .. "/" .. r:escape(user) .. "#" .. r:escape(server)
end

function find_proxy(r, user, proxy_list, req_backend)
    -- find requested backend from all possible proxies
    local proxy_server = nil
    local proxy_files = {}
    for i, proxy in ipairs(proxy_list) do
        local proxy_file = proxy_filename(r, user, proxy)
        local backend = read_file(proxy_file)
        if not backend or backend == req_backend then
            proxy_server = proxy
            break
        end
        proxy_files[proxy_file] = proxy -- reverse map filename to proxy
    end

    -- find last modified file
    if not proxy_server then
        local files = ""
        for file, proxy in pairs(proxy_files) do
            files = files .. "'" .. file .. "' "
        end
        local cmd = "ls -tr " .. files .. " | head -1"
        local handle = io.popen(cmd, "r")
        local proxy_file = handle:read(); handle:close()
        proxy_server = proxy_files[proxy_file]
    end

    return proxy_server
end

function set_proxy(r, user, proxy, backend)
    local proxy_file = proxy_filename(r, user, proxy)
    write_file(proxy_file, backend)
end

function get_proxy(r, user, proxy)
    local proxy_file = proxy_filename(r, user, proxy)
    return read_file(proxy_file)
end

function proxy_server_handler(r)
    local user     = map_user(r)
    local suburi   = r.subprocess_env['SUB_URI']
    local idx_root = r.subprocess_env['PROXY_IDX_ROOT']
    local proxy_servers = split(r.subprocess_env['PROXY_SERVERS'], ",")

    local host, port, uri = r.unparsed_uri:match("^" .. suburi .. "/([^/]+)/([^/]+)(.*)")
    local backend = host .. ":" .. port

    -- find an available proxy server or override an old one
    local proxy_server = find_proxy(r, user, proxy_servers, backend)

    -- set this proxy server
    set_proxy(r, user, proxy_server, backend)

    -- redirect user to proxy server
    -- r.status = 302
    r.status = 307
    r.headers_out['Location'] = "//" .. proxy_server .. uri
    return apache2.DONE
end

function proxy_handler(r)
    local user = map_user(r)

    -- find what backend server maps to this proxy server
    local proxy_server = r.hostname .. ":" .. r.port
    local backend = get_proxy(r, user, proxy_server)
    if not backend then
        r.content_type = "text/plain"
        r:puts("Proxy server isn't mapped to any backend")
        return apache2.DONE
    end

    -- build connection information for backend server
    local conn = {}
    conn.user = user
    conn.server = backend
    conn.uri = r.unparsed_uri

    set_reverse_proxy(r, conn)  -- setup request for reverse proxy

    -- handle if backend server is down
    r:custom_response(503, "Failed to connect to " .. conn.server)

    return apache2.DECLINED
end

function unix_proxy_handler(r)
    local user = map_user(r)

    local socket_root = r.subprocess_env['OOD_NGINX_RUN_ROOT']

    -- build connection information for backend server
    local conn = {}
    conn.user = user
    conn.socket = socket_root .. "/" .. user .. "/passenger.sock"
    conn.uri = r.unparsed_uri

    set_reverse_proxy(r, conn)  -- setup request for reverse proxy

    -- handle if backend server is down
    r:custom_response(503, "/nginx/start?redir=" .. r:escape(conn.uri))

    return apache2.DECLINED
end

function set_reverse_proxy(r, conn)
    local protocol = (r.headers_in['Upgrade'] and "ws://" or "http://")

    r.handler = "proxy-server"
    r.proxyreq = apache2.PROXYREQ_REVERSE
    if conn.socket then
        r.filename = "proxy:unix:" .. conn.socket .. "|" .. protocol .. "localhost" .. conn.uri
    else
        r.filename = "proxy:" .. protocol .. conn.server .. conn.uri
    end

    -- useful information for backend server
    r.headers_in['Host'] = r.hostname .. ":" .. r.port  -- doesn't forward host with port
    r.headers_in['X-Forwarded-User'] = conn.user or ""
    r.headers_in['X-Forwarded-Escaped-Uri'] = r:escape(conn.uri)  -- required by PUN
end
