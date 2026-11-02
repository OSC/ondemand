-- luacheck configuration for mod_ood_proxy
--
-- These files run inside Apache's mod_lua, which provides the `apache2`
-- global. Handler functions (logger, pun_proxy_handler, ...) are defined as
-- globals on purpose because mod_lua looks them up by name.
std = "min"
max_line_length = 120

read_globals = { "apache2" }

globals = {
  "logger",
  "pun_proxy_handler",
  "node_proxy_handler",
  "nginx_handler",
}
