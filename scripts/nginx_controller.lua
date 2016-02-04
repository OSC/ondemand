require 'map_user'

function nginx_handler(r)
    local user = map_user(r)

    local suburi = r.subprocess_env['SUB_URI']
    local nginx_suburi = r.subprocess_env['OOD_NGINX_SUB_URI']
    local nginx_binary = r.subprocess_env['OOD_NGINX_BINARY']

    local GET, GETMULTI = r:parseargs()
    local redir = GET['redir']

    -- defaults
    local subcommand = "nginx"
    local args = "-u '" .. user .. "'"

    local cmd = r.uri:match("^" .. suburi .. "/([^/]+)$")
    if cmd == "init" then
        -- app initialization
        subcommand = "app"
        local nginx_subrequest = redir:match("^" .. nginx_suburi .. "(/.+)$")
        args = args .. " -i '" .. nginx_suburi .. "' -r '" .. nginx_subrequest .. "'"
    else
        if cmd == "start" then
            -- start per-user nginx
            subcommand = "pun"
            args = args .. " -a '" .. suburi .. "/init?redir=$http_x_forwarded_escaped_uri'"
        else
            -- send per-user nginx signal
            args = args .. " -s '" .. cmd .. "'"
        end
    end

    local handle = io.popen(nginx_binary .. " " .. subcommand .. " " .. args .. " 2>&1", "r")
    local output = handle:read("*a"); handle:close()
    r.usleep(500000)    -- give nginx time, 0.5 sec

    if output == "" then
        if redir then
            r.status = 302
            r.headers_out['Location'] = redir
        else
            r.status = 200
            r:write("<html><body><p>Success!</p></body></html>")
        end
    else
        r.status = 404
        r:write("<html><body><p>Error:</p><pre>" .. output .. "</pre></body></html>")
    end

    return apache2.DONE
end
