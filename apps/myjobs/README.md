# Job Composer (renamed from My Jobs)

This app is a Rails app we ship with Open OnDemand that used to create and manage batch jobs
from template directories. Like all Open OnDemand apps, it's meant to run as a non-root user.

This is a guide for developing this application and assumes you have nodejs & ruby available on the system.

You can find [template documentation here](https://osc.github.io/ood-documentation/latest/customization.html#custom-job-composer-templates).

## Developing

First, you'll need to clone this repo and make a symlink if you haven't don so already.

```text
mkdir -p ~/ondemand/dev
git clone https://github.com/OSC/ondemand.git ~/ondemand/src
cd ~/ondemand/dev
ln -s ../src/apps/myjobs
```

Now run `bin/setup` from within this directory to fetch all the dependencies
and compile.

Now you should be able to navigate to `/pun/dev/myjobs` and see the app
in the developer views.

### Customizing

See `config/configuration_singleton.rb` from the root of this directory for all
the configurations you may be able to apply.
