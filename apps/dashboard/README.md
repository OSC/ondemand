# Open OnDemand Dashboard

The Open OnDemand Dashboard is the main component of Open OnDemand.

See [DEVELOPMENT.md](../../DEVELOPMENT.md) for instructions on developing
this component.

## Batch Connect app announcements

App-specific announcements can be added centrally under the configured
announcement directory, without modifying or releasing the app itself. For
example, with the default `/etc/ood/config/announcements.d` directory:

```text
/etc/ood/config/announcements.d/
  apps/
    sys/
      bc_jupyter/
        maintenance.md
    usr/
      alice/
        bc_jupyter/
          maintenance.yml
```

Announcement files use the same Markdown or YAML formats as global
announcements. The directory components after `apps/` match the Batch Connect
app token (`sys/<name>`, `dev/<name>`, or `usr/<owner>/<name>`). A sub-app can
have a further directory named for the sub-app token. When that directory
exists, its announcements are used instead of the parent app's announcements;
otherwise, the parent app's announcements are used. App announcements appear
on the Dashboard page for configuring and launching that Batch Connect app,
not inside the running app session. They are shown each time the page is
loaded; dismissing an app announcement is not currently supported.
