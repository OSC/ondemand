--[[
  pun

  Start PUN process for given user
--]]
function pun(r, bin, user, sub_uri, app_init_url)
  local cmd = bin .. " pun -u '" .. r:escape(user) .. "'"
  if sub_uri then
    cmd = cmd .. " -i '" .. r:escape(sub_uri) .. "'"
  end
  if app_init_url then
    cmd = cmd .. " -a '" .. r:escape(app_init_url) .. "'"
  end

  local err = capture2e(cmd)

  if err == "" then
    return nil -- success
  else
    return err -- fail
  end
end


--[[
  app

  Initialize an app config & restart PUN
--]]
function app(r, bin, user, request, sub_uri)
  local cmd = bin .. " app -u '" .. r:escape(user) .. "' -r '" .. r:escape(request) .. "'"
  if sub_uri then
    cmd = cmd .. " -i '" .. r:escape(sub_uri) .. "'"
  end

  local err = capture2e(cmd)

  if err == "" then
    return nil -- success
  else
    return err -- fail
  end
end

--[[
  nginx

  Send the per-user nginx a signal
--]]
function nginx(r, bin, user, signal)
  local cmd = bin .. " nginx -u '" .. r:escape(user) .. "'"
  if signal then
    cmd = cmd .. " -s '" .. r:escape(signal) .. "'"
  end

  local err = capture2e(cmd)

  if err == "" then
    return nil -- success
  else
    return err -- fail
  end
end

--[[
  capture2

  Give a string for stdin, get a string for stdout
--]]
function capture2(cmd)
  local handle = io.popen(cmd, "r")
  local output = handle:read("*a")
  handle:close()
  return output
end

--[[
  capture2e

  Give a string for stdin, get a string for merged stdout and stderr
--]]
function capture2e(cmd)
  return capture2(cmd .. " 2>&1")
end

return {
  pun   = pun,
  app   = app,
  nginx = nginx
}
