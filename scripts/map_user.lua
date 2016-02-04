function map_user(r, user_map_script)
    user_map_script = user_map_script or r.subprocess_env['USER_MAP_SCRIPT']
    local user = r.user

    -- run name mapper script if supplied
    if user_map_script then
        -- use cached value employing ivm_get/ivm_set
        -- note: not ideal as apache runs with prefork mpm, so it opens
        --       multiple processes (will call script once more if run on
        --       never used process)
        -- for db need to install drivers (i.e., httpd24-apr-util-sqlite)
        local cached_user = r:ivm_get("user_cache_" .. user)
        if not cached_user then
            local handle = io.popen(user_map_script .. " '" .. user .. "'")
            cached_user = handle:read()
            handle:close()

            r:ivm_set("user_cache_" .. user, cached_user)
        end
        user = cached_user
    end

    return user
end
