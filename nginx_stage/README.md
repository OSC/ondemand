# nginx_stage

![GitHub Release](https://img.shields.io/github/release/osc/nginx_stage.svg)
![GitHub License](https://img.shields.io/github/license/osc/nginx_stage.svg)

Stages and launches the per-user NGINX (PUN) processes for individual users. It
is also responsible for staging, listing, and cleaning up web application NGINX
configuration files, as well as listing and stopping running PUNs.

For more information please visit the
[Documentation](https://osc.github.io/ood-documentation/master/infrastructure/nginx-stage.html).

## PUN lifecycle commands

`pun`, `app` and `nginx` serialize changes using a per-user config lock.
`nginx_clean` skips users whose lock is busy. After a successful stop or quit,
commands wait up to 30 seconds for the original process to stop and for its
PID file and socket to disappear. A timeout prevents an app restart from
starting a replacement.

Signalling requires readable Linux `/proc` state, an nginx master title with
the exact config path, and the configured nginx executable. An unverified PID
is left alone. Replacing the nginx executable can make an old master fail this
check; executable-upgrade provenance is not handled here. These checks assume
root-owned PID/config files and do not provide atomic pidfd signalling or
coordinate commands run outside `nginx_stage`.

Disabled-user cleanup keeps config and secret files until shutdown succeeds.
Discovery still uses PID files:
if a timed-out master subsequently removes its PID file, a later cleanup run
does not discover its leftover run directory. No pending-cleanup records are
created.

## Contributing

1. Fork it ( https://github.com/OSC/ondemand/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
