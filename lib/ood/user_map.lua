--[[
  map

  Given a request and authenticated user, map this user to a system-level user
  using the supplied shell command.
--]]
function map(r, user_map_cmd, remote_user)
  -- run user_map_cmd and read in stdout
  local now = r:clock()
  local handle = io.popen(user_map_cmd .. " '" .. r:escape(remote_user) .. "'")
  sys_user = handle:read()
  handle:close()
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
