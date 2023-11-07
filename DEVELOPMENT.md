# Developing Open-OnDemand

These are instructions to build and interact with a full stack
development container.

If you've completed this or already run Open OnDemand at your site you
can refer to [the dashboard's readme](apps/dashboard/README.md) for details
on how to develop the dashboard.

## Getting Started

This container will create a duplicate user
with the same group and user id.  Starting the container will prompt
you to set a password.  This is only credentials for web access to the
container.

Pull down this source code and start the container.  We support podman
by setting the environment variable `CONTAINER_RT=podman`.

```text
mkdir -p ~/ondemand
git clone https://github.com/OSC/ondemand.git ~/ondemand/src
cd ~/ondemand/src
rake dev:start
```

See `rake --tasks` for all the `dev:` related tasks.

```
rake dev:exec                               # Bash exec into the development container
rake dev:bash                               # alias for dev:exec
rake dev:restart                            # Restart development container
rake dev:start                              # Start development container
rake dev:stop                               # Stop development container
```

### Login to the container

Here's the important bit about user mapping with containers. Let's use the
example of `jessie` with `id` below. In creating the development container,
we added a user with the same.  The password is for `dex` the IDP, and the
web only.

```
uid=1000(jessie) gid=1000(jessie) groups=1000(jessie)
```

Now you'll be able to access `http://localhost:8080/` where it'll redirect
you to `dex` the OpenID Connect provider within the container. Use the email
`<your username>@localhost`.


### Configuring the container

In starting the container, you may see the mount
`~/.config/ondemand/container/config:/etc/ood/config`.  This mount allows us to
completely configure this Open-OnDemand container.

Create and edit files in the host's home directory and to mount in
new configurations.

Edit or remove `~/.config/ondemand/container/config/ood_portal.yml` to change
your container's password.

### Rebuilding the image

All the development tasks will use the `ood-dev:latest` image.  If
you want to rebuild to a newer version use the rebuild task.

```text
rake dev:rebuild
```

## Advanced setups

### Additional Capabilities

While starting this container, this library will respond to some environment
variables you may want and/or need.

For example if you need additional Linux capabilities you can use `OOD_CTR_CAPABILITIES`
with a comma separated list of the capabilities you want.

If `privileged` is in this list, no capabilies are used and the container is ran with
the `--privileged` flag.

```shell
OOD_CTR_CAPABILITIES=net_raw,net_admin
```

### Additional Mounts

You can mount the current directory to override what exists in the container
by setting _anything_ in the `OOD_MNT_` environment variables.

* `OOD_MNT_PORTAL` mounts <project_root>/ood-portal-generator to /opt/ood/ood-portal-generator
* `OOD_MNT_NGINX` mounts <project_root>/nginx_stage to /opt/ood/nginx_stage
* `OOD_MNT_PROXY` mounts <project_root>/ood_proxy to /opt/ood/ood_proxy
