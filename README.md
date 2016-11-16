# OOD Dashboard

This app is a Rails app for Open OnDemand that serves as a gateway to launching other Open OnDemand apps. It is meant to be run as the user (and on behalf of the user) using the app. Thus, at an HPC center if I log into OnDemand using the `efranz` account, this app should run as `efranz`. This Rails app doesn't use a database.

## New Install


1. Check out and build the app (make sure the app directory's name is "dashboard"):

  ```
# start in build directory for all sys apps i.e. cd ~/ood_portals/ondemand/sys
git clone https://github.com/OSC/ood-dashboard.git dashboard
cd dashboard
git checkout tags/v1.5.1
scl enable git19 nodejs010 rh-ruby22 -- bin/bundle install --path vendor/bundle
scl enable git19 nodejs010 rh-ruby22 -- bin/rake assets:precompile RAILS_ENV=production
```

2. Copy the built app directory to the deployment directory, and start the server.

3. Access the dashboard by going to /pun/sys/dashboard


## Updating to a New Stable Version

When updating a deployed version of the Open OnDemand dashboard.


1. Fetch and checkout new version of code:

  ```
cd dashboard # cd to build directory
get fetch
git checkout tags/v1.5.1 # check out latest tag
```

2. Install gem dependencies and rebuild assets

  ```
scl enable git19 nodejs010 rh-ruby22 -- bin/bundle install --path vendor/bundle
scl enable git19 nodejs010 rh-ruby22 -- bin/rake tmp:clear
scl enable git19 rh-ruby22 nodejs010 -- bin/rake assets:clobber RAILS_ENV=production
scl enable git19 rh-ruby22 nodejs010 -- bin/rake assets:precompile RAILS_ENV=production
```

3. Restart app

  ```
scl enable git19 rh-ruby22 nodejs010 -- touch tmp/restart.txt
```

4. Copy the built app directory to the deployment directory. There is no need to restart the server. Because we touched `tmp/restart.txt` in the app, the next time a user accesses an app Passenger will reload their app.

## Configuration and Branding

Configuration and branding is done by adding a custom .env.local file to modify
environment variables and adding a custom config/initializers/ood.rb initializer
for anything customization requires ruby code.

* `OOD_PORTAL="ondemand"` - the lowercase portal name that matches the name of the installation directory and the data directory created in the user's home directory; this should also be set in the path for `OOD_DATAROOT` in the `.env.production` file
* `OOD_DASHBOARD_DOCS_URL` - URL to access OnDemand documentation for users
* `OOD_DASHBOARD_DEV_DOCS_URL` - URL to access OnDemand Developer documentation for app developers
* `OOD_DASHBOARD_PASSWD_URL` - URL to access page to change your HPC password
* `OOD_DASHBOARD_SUPPORT_URL` - URL for users to get HPC support
* `OOD_DASHBOARD_LOGOUT_URL` - [temporary till Apache can handle logout](https://github.com/OSC/ood-dashboard/issues/34) specify the logout URL; its a sprintf string, so if `%{login}` is provided, this will be substituted with the original login domain
* `MOTD_PATH="/etc/motd"` - optional: the message of the day, if you have one (see below)

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

## App Sharing

**This is a feature currently in development. The documentation below is for developers working on this feature.**


App sharing features creating a new app from a prebuilt app. In order to provide this feature, we need to prebuild an app in a subdirectory of the dashboard so this can be copied to the user's home directory.

To do this, run the command below in the dashboard directory (change `OOD_PORTAL` to match the portal this dashboard is setup for):

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
