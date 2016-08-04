--[[
  map

  Given a request and authenticated user, map this user to a system-level user
  using the supplied shell command.
--]]
function map(r, user_map_cmd)
  -- read in authenticated user
  local auth_user = r:escape(r.user)

  -- read in cached user if available
  local sys_user = r:ivm_get("user_cache_" .. auth_user)

  -- read in cookie with suggested system user
  local tmp_sys_user = r:getcookie("mod_ood_proxy_session")

  -- if no cached user, then find system user and cache it
  if not sys_user or not tmp_sys_user or sys_user ~= tmp_sys_user then
    -- run user_map_cmd and read in stdout
    local handle = io.popen(user_map_cmd .. " '" .. auth_user .. "'")
    sys_user = handle:read()
    handle:close()

    -- failed to map if returns empty string
    if not sys_user or sys_user == "" then
      return nil
    end

    -- cache system user
    r:ivm_set("user_cache_" .. auth_user, sys_user)
    r:setcookie{
      key = "mod_ood_proxy_session",
      value = sys_user,
      expires = os.time() + 28800,
      httponly = true,
      secure = true
    }
  end

  return sys_user
end

return {
  map = map
}
