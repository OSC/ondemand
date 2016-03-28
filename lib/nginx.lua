local user_map = require 'ood.user_map'

--[[
  nginx_handler

  Controls the authenticated user's PUN and/or PUN related operations using the
  Apache configured pun stage command. The relevant tasks are:
    1. 'init' = initialize PUN app and redirect user to it
    2. 'start' = initialize PUN and start PUN process
    3. ... = all remainder tasks are sent to the PUN process as a signal
             Examples: 'stop', 'quit', 'reopen', 'reload'
--]]
function nginx_handler(r)
  -- read in OOD specific settings defined in Apache config
  local user_map_cmd  = r.subprocess_env['OOD_USER_MAP_CMD']
  local nginx_uri     = r.subprocess_env['OOD_NGINX_URI']
  local pun_uri       = r.subprocess_env['OOD_PUN_URI']
  local pun_stage_cmd = r.subprocess_env['OOD_PUN_STAGE_CMD']

  -- get the system-level user name
  local user = user_map.map(r, user_map_cmd)
  if not user then
    r.status = 404
    r:write("Error -- failed to map user " .. r.user)
    return apache2.DONE
  end

  -- grab "redir" query param
  local GET, GETMULTI = r:parseargs()
  local redir = GET['redir']

  -- grab task specified in nginx URI request
  local task = r.uri:match("^" .. nginx_uri .. "/([^/]+)$")

  -- generate shell command from requested task
  -- please see `nginx_stage` documentation for explanation of shell command
  local pun_stage_subcmd
  local pun_stage_args = "-u '" .. r:escape(user) .. "'"
  if task == "init" then
    -- initialize app based on "redir" param
    pun_stage_subcmd = "app"
    local pun_app_request = redir:match("^" .. pun_uri .. "(/.+)$")
    pun_stage_args = pun_stage_args .. " -i '" .. r:escape(pun_uri) .. "' -r '" .. r:escape(pun_app_request) .. "'"
  else
    if task == "start" then
      -- start PUN process
      pun_stage_subcmd = "pun"
      pun_stage_args = pun_stage_args .. " -a '" .. r:escape(nginx_uri .. "/init?redir=$http_x_forwarded_escaped_uri") .. "'"
    else
      -- send task as signal to PUN process
      pun_stage_subcmd = "nginx"
      pun_stage_args = pun_stage_args .. " -s '" .. r:escape(task) .. "'"
    end
  end

  -- run shell command and read in stdout/stderr
  local handle = io.popen(pun_stage_cmd .. " " .. pun_stage_subcmd .. " " .. pun_stage_args .. " 2>&1", "r")
  local pun_stage_output = handle:read("*a"); handle:close()

  -- give the PUN process sufficient time to accomplish task (0.5 sec)
  r.usleep(500000)

  -- properly handle pun_stage_cmd output
  -- note: pun_stage_cmd should not return any output upon successful
  --       completion
  if pun_stage_output == "" then
    if redir then
      -- success & redirect
      r.status = 302
      r.headers_out['Location'] = redir
    else
      -- success, so inform the user
      r.status = 200
      r:write("Success")
    end
  else
    -- something bad happened, so inform the user
    r.status = 404
    r:write("Error -- " .. pun_stage_output)
  end

  -- skip remaining handlers
  return apache2.DONE
end
