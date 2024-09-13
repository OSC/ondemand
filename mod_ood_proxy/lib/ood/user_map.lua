--[[
  map

  Given a request and authenticated user, map this user to a system-level user
  using the supplied match string or shell command.
--]]
function map(r, user_map_match, user_map_cmd, remote_user)
  local now = r:clock()
  local sys_user = ""
  -- match string
  if user_map_match ~= nil then
    sys_user = string.match(remote_user, user_map_match)
  -- run user_map_cmd and read in stdout
  elseif user_map_cmd ~= nil then
    local handle = io.popen(user_map_cmd .. " '" .. r:escape(remote_user) .. "'")
    sys_user = handle:read()
    handle:close()
  end

  -- if sys_user is a number, then it's the uid, so convert to username
  if tonumber(sys_user) then
    local handle = io.popen("id -un " .. sys_user)
    sys_user = handle:read()
    handle:close()
  end

  time_user_map = (r:clock() - now)/1000.0
  r:debug("Mapped '" .. remote_user .. "' => '" .. (sys_user or "") .. "' [" .. time_user_map .. " ms]")

  -- failed to map if returns empty string
  if not sys_user or sys_user == "" then
    return nil
  end


  r.subprocess_env['MAPPED_USER'] = sys_user -- set as CGI variable for later hooks (i.e., analytics)
  r.subprocess_env['OOD_TIME_USER_MAP'] = time_user_map -- set as CGI variable for later hooks (i.e., analytics)
  return sys_user
end

return {
  map = map
}
