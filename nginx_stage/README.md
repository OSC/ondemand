# nginx_stage

![GitHub Release](https://img.shields.io/github/release/osc/nginx_stage.svg)
![GitHub License](https://img.shields.io/github/license/osc/nginx_stage.svg)

Stages and launches the per-user NGINX (PUN) processes for individual users. It
is also responsible for staging, listing, and cleaning up web application NGINX
configuration files, as well as listing and stopping running PUNs.

For more information please visit the
[Documentation](https://osc.github.io/ood-documentation/master/infrastructure/nginx-stage.html).

## Recovering from an invalid PUN PID file

When a PUN socket exists alongside an invalid PID file, `nginx_stage pun`
blocks startup and reports both paths. `nginx_stage nginx_clean` reports the
invalid PID file and leaves both files in place, even with `--force`.

1. Use your site's process inspection tools to verify that the affected
   user's PUN has stopped. Identify the PUN independently of the invalid PID file.
2. Remove the invalid PID file and stale socket at the paths in the startup error.
3. Retry startup for the affected user.

## Contributing

1. Fork it ( https://github.com/OSC/ondemand/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
