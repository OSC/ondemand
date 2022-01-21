local user_map    = require 'ood.user_map'
local http        = require 'ood.http'
local nginx_stage = require 'ood.nginx_stage'

--[[
  nginx_handler

  Controls the authenticated user's PUN and/or PUN related operations using the
  Apache configured pun stage command. The relevant tasks are:
    1. 'init'  = initialize PUN app and redirect user to it
    2. 'stop'  = send `stop` signal to PUN process
--]]
function nginx_handler(r)
  -- read in OOD specific settings defined in Apache config
  local user_map_match = r.subprocess_env['OOD_USER_MAP_MATCH']
  local user_map_cmd   = r.subprocess_env['OOD_USER_MAP_CMD']
  local user_env       = r.subprocess_env['OOD_USER_ENV']
  local nginx_uri      = r.subprocess_env['OOD_NGINX_URI']
  local pun_uri        = r.subprocess_env['OOD_PUN_URI']
  local pun_stage_cmd  = r.subprocess_env['OOD_PUN_STAGE_CMD']
  local map_fail_uri   = r.subprocess_env['OOD_MAP_FAIL_URI']

  -- get the system-level user name
  local user = user_map.map(r, user_map_match, user_map_cmd, user_env and r.subprocess_env[user_env] or r.user)
  if not user then
    if map_fail_uri then
      return http.http302(r, map_fail_uri .. "?redir=" .. r:escape(r.unparsed_uri))
    else
      return http.http404(r, "failed to map user (" .. r.user .. ")")
    end
  end

  -- grab "redir" query param
  local GET, GETMULTI = r:parseargs()
  local redir = GET['redir']

  -- grab task specified in nginx URI request
  local task = r.uri:match("^" .. nginx_uri .. "/([^/]+)$")

  -- generate shell command from requested task
  -- please see `nginx_stage` documentation for explanation of shell command
  local err = nil
  if task == "init" then
    -- initialize app based on "redir" param (require a valid redir parameter)
    if not redir then return http.http404(r, 'requires a `redir` query parameter') end
    local pun_app_request = redir:match("^" .. pun_uri .. "(/.+)$")
    if not pun_app_request then return http.http404(r, "bad `redir` request (" .. redir .. ")") end
    -- generate app config & restart PUN process
    err = nginx_stage.app(r, pun_stage_cmd, user, pun_app_request, pun_uri)
    return err and http.http404(r, err) or http.http302(r, redir)
  elseif task == "stop" then
    -- stop PUN process
    err = nginx_stage.nginx(r, pun_stage_cmd, user, "stop")
    if redir then
      local pun_app_request = redir:match("^" .. pun_uri .. "(/.+)$")
      if not pun_app_request then return http.http404(r, "bad `redir` request (" .. redir .. ")") end
      return http.http302(r, pun_app_request)  -- ignore errors
    else
      return err and http.http404(r, err) or http.http200(r)
    end
  elseif task == "noop" then
    -- do nothing
    return redir and http.http307(r, redir) or http.http200(r)
  else
    return http.http404(r, "invalid nginx task")
  end
end
