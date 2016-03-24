require 'map_user'

function authz_check_sys_user(r, user_map_script)
    if r.user == nil then
        return apache2.AUTHZ_DENIED_NO_USER
    end

    local user = map_user(r, user_map_script)
    local cmd = "id '" .. user .. "' &> /dev/null"
    r:custom_response(401, "Invalid system user: " .. user)
    if os.execute(cmd) == 0 then
        return apache2.AUTHZ_GRANTED
    else
        return apache2.AUTHZ_DENIED
    end
end
