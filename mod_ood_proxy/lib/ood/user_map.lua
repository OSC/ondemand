
--[[
  actual_username

  What we get from the user mapping script can be an actual
  alphanumeric username, UID, or numeric username.
  This helper distinguishes between numeric values that are usernames
  and numeric values that are in fact UIDs.
--]]
function actual_username(username)

  local num = tonumber(username)
  if num then
    local pwd = require "posix.pwd"
    local data = pwd.getpwnam(num)

    -- it's a numeric username.
    if data then
      return data.pw_name

    -- not a numeric username, so must be a UID.
    else
      data = pwd.getpwuid(num)
      return data.pw_name
    end

  -- it's not numeric, so just return the string.
  else
    return username
  end
end

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
    -- if match string ends in :lower, lowercase the username
    local pat = string.match(user_map_match, "^(.*):lower$")
    if pat then
        sys_user = string.match(remote_user, pat)
        sys_user = string.lower(sys_user)
    else
        sys_user = string.match(remote_user, user_map_match)
    end
  -- run user_map_cmd and read in stdout
  elseif user_map_cmd ~= nil then
    local handle = io.popen(user_map_cmd .. " '" .. r:escape(remote_user) .. "'")
    sys_user = handle:read()
    handle:close()
  end

  sys_user = actual_username(sys_user)

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
