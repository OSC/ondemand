## OSC Job Status for Oakley/Ruby

Application displays the current system status of jobs running, queued, and held on the Oakley and Ruby Clusters.

### Deployment on OOD

1. Git clone this repository
2. Modify `.env.production` as appropriate, or rename one of the versioned copies
3. Install gems and restart app.

```
$ scl enable git19 rh-ruby22 nodejs010 -- bin/bundle install --path=vendor/bundle
$ scl enable git19 rh-ruby22 nodejs010 -- bin/rake assets:clobber RAILS_ENV=production
$ scl enable git19 rh-ruby22 nodejs010 -- bin/rake assets:precompile RAILS_ENV=production
$ scl enable git19 rh-ruby22 nodejs010 -- bin/rake ood_appkit:restart
```
