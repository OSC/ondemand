# Developing Open-OnDemand

## Getting Started

These are instructions to build and interact with a full stack
development container.  This container will create a duplicate user
with the same group and user id.  Starting the container will prompt  
you to set a password.  This is only credentials for web access to the
container.

Pull down this source code and start the container. 

```text
mkdir -p ~/ondemand
git clone ~/ondemand/src
cd ~/ondemand/src
rake dev:start
```

See `rake --tasks` for all the `dev:` related tasks.

```
rake dev:exec                               # Bash exec into the development container
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
`~/.config/ondemand/container:/etc/ood`.  This mount allows us to
completely configure this Open-OnDemand container.

Create and edit files in the host's home directory and to mount in
new configurations. 

Remove `~/.config/ondemand/container/static_user.yml` to reset your
container's password.

### Rebuilding the image

All the development tasks will use the `ood-dev:latest` image.  If
you want to rebuild to a newer version use the rebuild task.

```text
rake dev:rebuild
```