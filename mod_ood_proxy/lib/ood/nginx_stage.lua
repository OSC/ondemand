
--[[
  pun

  Start PUN process for given user
--]]
function pun(r, bin, user, app_init_url, exports, pre_hook_root_cmd, allowed_hosts)
  local cmd = bin .. " pun -u '" .. r:escape(user) .. "'"
  local err

  if app_init_url then
    cmd = cmd .. " -a '" .. r:escape(app_init_url) .. "'"
  end

  if pre_hook_root_cmd then
    local env_table = exports_to_table(r, exports)
    if allowed_hosts then
      -- capture2e_with_env will prefix OOD_
      env_table["ALLOWED_HOSTS"] = allowed_hosts
    end
    cmd = cmd .. " -P '" .. r:escape(pre_hook_root_cmd) .. "'"
    err = capture2e_with_env(cmd, env_table)
  else
    if allowed_hosts then
      local posix = require 'posix'
      posix.setenv("OOD_ALLOWED_HOSTS", allowed_hosts)
    end
    err = capture2e(cmd)
  end


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
  capture2e_with_env

  fork this process, modify the environment of the child and execute the
  command.  This returns a string that is the stdout & stderr combined.
--]]
function capture2e_with_env(cmd, env_table)
  local posix = require 'posix'

  local read_pipe, write_pipe = posix.pipe()
  local childpid, errmsg = posix.fork()

  if childpid == nil then
    return "failed to fork " .. cmd .. " with error message: '" .. errmsg .. "'"

  -- child pid
  elseif childpid == 0 then
    posix.close(read_pipe)

    for key,value in pairs(env_table) do
      posix.setenv("OOD_" .. key, value) -- sudo rules allow for OOD_* env vars
    end

    local output = capture2e(cmd)
    posix.write(write_pipe, output)
    posix.close(write_pipe)
    os.exit(0)

  -- child pid
  else
    posix.close(write_pipe)

    posix.wait(childpid)

     -- FIXME: probably a better way than to read byte by byte
    local output = ""
    local b = posix.read(read_pipe, 1)
    while #b == 1 do
       output = output .. b
       b = posix.read(read_pipe, 1)
    end

    posix.close(read_pipe)
    return output
  end
end

--[[
  export_table
  Given exports to be a comma separated list of environment variable
  names: split that string, extract the variable values from the request's
  environment and return a table of the environment variable key:value pairs
--]]
function exports_to_table(r, exports)
  local export_table = {}

  if exports then
    for key in string.gmatch(exports, '([^,]+)') do
        value = r.subprocess_env[key]
        if value then
          export_table[key] = value
        end
    end
  end

  return export_table
end

return {
  pun   = pun,
  app   = app,
  nginx = nginx
}
