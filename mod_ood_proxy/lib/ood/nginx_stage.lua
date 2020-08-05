
--[[
  pun

  Start PUN process for given user
--]]
function pun(r, bin, user, app_init_url, exports, pre_hook_root_cmd)
  local cmd = bin .. " pun -u '" .. r:escape(user) .. "'"
  local stdin = parse_exports(r, exports)

  if app_init_url then
    cmd = cmd .. " -a '" .. r:escape(app_init_url) .. "'"
  end

  if pre_hook_root_cmd then
    cmd = cmd .. " -P '" .. r:escape(pre_hook_root_cmd) .. "'"
  end

  local err = capture2e_with_stdin(cmd, stdin)

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

  Give a string for a command, get a string for stdout
--]]
function capture2(cmd)
  local handle = io.popen(cmd, "r")
  local output = handle:read("*a")
  handle:close()
  return output
end

--[[
  capture2e

  Give a string for a command, get a string for merged stdout and stderr
--]]
function capture2e(cmd)
  return capture2(cmd .. " 2>&1")
end

--[[
  capture2e_with_stdin

  Give a command and some standard in, get a string for merged stdout and stderr
--]]
function capture2e_with_stdin(cmd, stdin)
  math.randomseed(os.time())
  local num = math.random(0,1000000000)

  local input_file = '/tmp/pun_boot_' .. os.time() .. '_' .. num
  os.execute('mkfifo -m 600 ' .. input_file)
  local redir_cmd = 'cat ' .. input_file .. ' | ' .. cmd .. " 2>&1"

  local output_handle = io.popen(redir_cmd, "r")
  local stdin_handle = io.open(input_file, "w")

  stdin_handle:write(stdin)
  output = stdin_handle:close()

  output = output_handle:read("*all")
  output_handle:close()

  os.remove(input_file)

  return output
end

--[[
  parse_exports

  Given exports to be a comma seperated list of environment variable
  names: split that string, extract the variable values from the request's
  environment and return a string of key=value pairs seperated by newlines
  like "KEY=VALUE\nNEXT=THEOTHER\n".
--]]
function parse_exports(r, exports)
  if exports then
      environment = ""

      for key in string.gmatch(exports, '([^,]+)') do
          value = r.subprocess_env[key]
          if value then
            environment = environment .. key .. "=" .. value .. "\n"
          end
      end

      return environment
  else
      return ""
  end
end

return {
  pun   = pun,
  app   = app,
  nginx = nginx
}
