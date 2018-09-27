# ood_auth_map

![GitHub Release](https://img.shields.io/github/release/osc/ood_auth_map.svg)
![GitHub License](https://img.shields.io/github/license/osc/ood_auth_map.svg)

This library provides a few useful scripts that can map a supplied
authenticated username to a local system username. This is typically used to
map the Apache proxy’s `REMOTE_USER` to a local system user when proxying the
client to the correct backend per-user NGINX process listening on a Unix domain
socket.

For more information please visit the
[Documentation](https://osc.github.io/ood-documentation/master/infrastructure/ood-auth-map.html).

## Contributing

1. Fork it ( https://github.com/OSC/ood_auth_map/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
