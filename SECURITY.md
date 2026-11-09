# Security Policy

This document outlines security procedures and general policies for the `Open OnDemand`
project.

## Reporting a Vulnerability

If you have security concerns or think you have found a vulnerability in Open OnDemand,
please submit a private report by visiting the 'Security' section of our GitHub located at [github.com/OSC/ondemand/security/](https://github.com/OSC/ondemand/security/) 
and clicking 'Report a vulnerability'. 

If you have questions about Open OnDemand's security, or have issues submitting a report please 
contact us directly via [security@openondemand.org](mailto:security@openondemand.org).
Emails sent there are only seen by the core project team.

## Disclosure Policy

Reporters will get a response from the core team as soon as we are able.
    
When the team receives a security vulnerability, they will generally assign it 
to a primary handler. This person will coordinate the fix and release process,
involving the following steps:

  * Confirm the problem and determine the affected versions.
  * Audit code to find any potential similar problems.
  * Prepare fixes for all releases still under maintenance. Vulnerabilities rated
    moderate or below may be released in the regular 8 week patch cycle. Vulnerabilities
    higher than moderate may be released sooner, outside the regular patch cycle.
  * Redact the information provided by the reporter and publish the vulnerability.
  * 90 days after publishing the vulnerability the original unredacted may be published
    if the reporter wishes. During investigation the team will ask if the reporter
    wishes the original report to be published in full 90 days after publishing.

## Access to Patched Binaries

By default, all compiled binary releases will be made available under the early access
program to active support subscribers, followed by a 3-5 week delay before being made 
available to the general public.  Source code for all releases will continue to be 
publicly available at the time they are committed to a branch, allowing for anyone to 
compile from source themselves, even during the early access period.

For all releases that contain security fixes, the development team will strive to publish 
manual mitigation details in conjunction with the source code and binary early access 
release, but might not be able to. Such manual mitigations might require sites to completely 
disable or restrict key features and functionalities of Open OnDemand and/or related 
applications and are not guaranteed to be applicable to all versions or deployments of 
Open OnDemand.

For releases that contain fixes for CVEs or GHSAs rated as high or critical, the development 
team will either publish manual mitigation details in conjunction with the source code 
and compiled binary early access release, or will make available to the public a compiled 
binary containing at least that security fix at the same time as the early access release.

## Comments on this Policy

If you have suggestions on how this process could be improved please submit 
a ticket, open a [Discourse](https://discourse.openondemand.org/) topic or open a pull request.

## Security Audits

The Open OnDemand core development team has had several engagements with [Trusted CI](https://trustedci.org/), the NSF Cybersecurity Center of Excellence. The first engagement was in 2018, during which Trusted CI conducted an in-depth vulnerability assessment and identified a few implementation issues that the Open OnDemand developers subsequently addressed.  [A report of that 2018 engagement is available here.](https://openondemand.org/trustedci-2018) The next engagement was in early 2021 and had three objectives: (1) integrate security automation into DevOps flows; (2) transfer skills for vulnerability assessments; and (3) develop needed security policies, practices, and procedures.  [A report of that 2021 engagement is available here.](https://openondemand.org/trustedci) 
