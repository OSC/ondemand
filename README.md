# OOD Dashboard

This app is a Rails app for Open OnDemand that serves as a gateway to launching other Open OnDemand apps. It is meant to be run as the user (and on behalf of the user) using the app. Thus, at an HPC center if I log into OnDemand using the `efranz` account, this app should run as `efranz`.

## Install

This Rails app doesn't use a database.

1\. First enable software collections, checkout the code, and install the dependencies:

```
cd /path/to/build/directory/sys
git clone https://github.com/OSC/ood-ondemand.git dashboard
cd dashboard
git checkout tags/v1.0.3 # latest version
scl enable nodejs010 rh-ruby22 -- bin/bundle install --path vendor/bundle
```

2\. At this point, configure the app and its branding by creating a .env.local (or copying from a .env.local template i.e. .env.local.osc) and modifying the values of the environment variables. See below for details on configuration and branding.

Update the dataroot of the `.env.production` file. This tells the production instance where to write user data - which is the user's home directory. By convention, it is `~/<PORTAL>/data`. So for OSC's OnDemand instance, our portal name is "ondemand" and thus the .env.production file has this line:

```
OOD_DATAROOT=$HOME/ondemand/data/$APP_TOKEN
```

3\. After updating the .env.local file, build the assets to complete the installation. Make sure that `RAILS_RELATIVE_URL_ROOT` is unset before running this command, as this will then be set by the `dot-env` gem, as `RAILS_RELATIVE_URL_ROOT` is set in `.env.production`.

```
scl enable nodejs010 rh-ruby22 -- RAILS_ENV=production bin/rake assets:precompile
scl enable nodejs010 rh-ruby22 -- bin/rake tmp:clear
```

4\. Next we need to build our staging app (change `OOD_PORTAL` to match the portal this dashboard is setup for):

```sh
OOD_APP=my_app OOD_PORTAL=ondemand scl enable rh-ruby22 nodejs010 -- /bin/bash <(cat <<\EOF
  dir=$(mktemp -d) &&
  cd ${dir} &&
  gem install -N -i . rails -v '~> 4.2' &&
  GEM_HOME=${PWD} bin/rails new ${OLDPWD}/vendor/${OOD_APP} \
    -m https://raw.githubusercontent.com/AweSim-OSC/rails-application-template/remote_source/awesim.rb \
    --skip-turbolinks \
    --skip-bundle \
    --skip-spring &&
  rm -fr ${dir}
EOF
)
```

5\. At this point, you should copy the directory to the deployment directory, if that location is not the same place as the build directory. For more explanation of how this is done, see https://github.com/OSC/Open-OnDemand#app-deployment-strategy.

### Update

When updating a deployed version of the Open OnDemand dashboard: 

1. do a git fetch
2. checkout the latest tag
3. rebuild the assets
4. clear the cache and touch the tmp/restart.txt file so Passenger reloads the app

## Configuration and Branding

Configuration is done within the .env file. Look at the .env file to see an example configuration for OSC.

* `OOD_PORTAL="ondemand"` - the lowercase portal name that matches the name of the installation directory and the data directory created in the user's home directory; this should also be set in the path for `OOD_DATAROOT` in the `.env.production` file
* `MOTD_PATH="/etc/motd"` - optional: the message of the day, if you have one (see below)
* `OOD_DASHBOARD_DOCS_URL` - URL to access OnDemand documentation for users
* `OOD_DASHBOARD_DEV_DOCS_URL` - URL to access OnDemand Developer documentation for app developers
* `OOD_DASHBOARD_PASSWD_URL` - URL to access page to change your HPC password
* `OOD_DASHBOARD_SUPPORT_URL` - URL for users to get HPC support
* `OOD_DASHBOARD_SHOW_ALL_APPS=false` - for OSC OnDemand this is currently set to true - for other Open OnDemand instances this should be set to false; this is a temporary solution to switch between showing only the Files and/or Clusters dropdowns in the menu (for shell access) versus showing all the applications currently deployed in OSC OnDemand, but not yet available in Open Source. This will soon be replaced by a more flexible solution for controlling the applicaiton menu hierarchy.
* `OOD_DASHBOARD_LOGOUT_URL` - [temporary till Apache can handle logout](https://github.com/OSC/ood-dashboard/issues/34) specify the logout URL; its a sprintf string, so if `%{login}` is provided, this will be substituted with the original login domain

To brand the site, you can change the title, colors, and logo of the dashboard app:

* `OOD_DASHBOARD_TITLE="OSC OnDemand <sup>beta</sub>"` - set the title of the dashboard; this can include HTML tags, such as superscript text "beta" or "1.0"
* `OOD_DASHBOARD_HEADER_IMG_LOGO=/public/logo.png"` - use a logo instead of text for the nav bar title
* Bootstrap variables are overridden using OodAppkit (https://github.com/OSC/ood_appkit#override-bootstrap-variables) so the nav bar colors can be modified to match the brand of the site. This is an example of changing the nav bar color to OH-TECH colors:

    ```
BOOTSTRAP_NAVBAR_INVERSE_BG='rgb(200,16,46)'
BOOTSTRAP_NAVBAR_INVERSE_LINK_COLOR='rgb(255,255,255)'
```

* When changing these, you will need to clear assets, even in development by running `bin/rake assets:clobber` or `RAILS_ENV=production bin/rake assets:clobber`, as these are set in a SSCSS file that is also an erb file, and Sprockets will not recognize when the dotenv files are modified.

## Message Of The Day

If `MOTD_PATH="/etc/motd"` is set, the message of the day file will be parsed and displayed on the front page of the dashboard. This assumes the MOTD file is formatted like this:

1. split messages using a line of multiple `**********`
2. each message starts with a single line like this: `2016/03/01`
3. title follows this format on the following line: `--- SYSTEM DOWNTIME RESCHEDULED: JULY 12TH 7AM-5PM`
4. after that the message body follows markdown rules for formatting, and is parsed using a markdown parser

Messages that do not match this formatting will be omitted.

In the future, we hope to:

* support more flexible formats for MOTD based on feedback
* support parsing an RSS feed instead of an MOTD formatted file by letting the admin provide a system path or a URL to the RSS feed

