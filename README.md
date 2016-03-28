# mod_ood_proxy

An Apache httpd module implementing the Open OnDemand proxy API.

## Requirements

- Apache httpd 2.4 [(Documentation)[https://httpd.apache.org/docs/2.4/]]
- mod_lua [(Documentation)[https://httpd.apache.org/docs/2.4/mod/mod_lua.html]]
- mod_env [(Documentaiton)[https://httpd.apache.org/docs/2.4/mod/mod_env.html]]
- mod_proxy [(Documentation)[https://httpd.apache.org/docs/2.4/mod/mod_proxy.html]]
    - mod_proxy_connect
    - mod_proxy_wstunnel
- mod_auth_*

## Installation

Todo...

## API

Unless otherwise specified, any call to a `mod_ood_proxy` handler listed below
in the Apache config should be done in the `LuaHookFixups` hook. This is the
final 'fix anything' phase before the content handlers are run. This will
ensure any authentication modules are called before the `mod_ood_proxy`
handlers and then followed up by the proxy module to handle the content.

```
LuaHookFixups node_proxy.lua node_proxy_handler
```

Unfortunately there is no easy way to pass arguments to a Lua handler. The
method we have devised is by using CGI variables defined in `mod_env` that are
set in a phase that occurs before the `LuaHookFixups` hook.

```
# Argument set before LuaHookFixups phase
SetEnv ARG_FOR_LUA "value of argument"

# Use example_handler Lua code in LuaHookFixups phase
LuaHookFixups example.lua example_handler
```

The variables are then accessed in the `mod_lua` handler as

```lua
-- example.lua

function example_handler(r)
  local arg_for_lua = r.subprocess_env['ARG_FOR_LUA']

  -- do stuff

  return apache2.DONE
end
```

### nginx_handler

Todo...

### pun_proxy_handler

Todo...

### node_proxy_handler

Todo...
