# Unreleased

* Display a cluster's metadata title instead of titleized id.
* Redirect user to new templates page on cancel
* Fix a bug when requesting data for a workflow with an unassigned batch_host

# v2.4.1

* Fix bug in `bin/setup` that crashes when `OOD_PORTAL` is set but not
  `OOD_SITE`

# v2.4.0

* Allow user to enter relative path names as template source
* Allow a user to create a new workflow from a path
* Allow user to resubmit a completed/failed job
* Display the script name associated with a workflow
* Add prompt to null selectpicker option
* Wrap long names that break out of containers
* UI enhancements

# v2.3.4

* Terminal button now links to appropriate host instead of default
* Update to OOD Appkit 1.0.1
* Alert if no valid hosts are available
* Hide row of job creation buttons if no submit hosts
* UI enhancements
