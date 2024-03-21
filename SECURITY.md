# Security Policy

This document outlines security procedures and general policies for the `Open OnDemand`
project.

## Reporting a Vulnerability

If you have security concerns or think you have found a vulnerability in Open OnDemand,
please contact us directly via [security@openondemand.org](mailto:security@openondemand.org).
Emails sent to it are only seen by the core project team.

## Disclosure Policy

Reporters should get a response from the core team within hours of reporting that
acknowledging the disclosure.
    
When the team receives a security vulnerability, they will generally assign it 
to a primary handler. This person will coordinate the fix and release process,
involving the following steps:

  * Confirm the problem and determine the affected versions (1-2 days).
  * Audit code to find any potential similar problems (1-2 days).
  * Prepare fixes for all releases still under maintenance. These fixes will be
    released as fast as possible (2-7 days).

## Comments on this Policy

If you have suggestions on how this process could be improved please submit 
a ticket, open a [Discourse](https://discourse.openondemand.org/) topic or open a pull request.

## Security Audits

The Open OnDemand core development team has had several engagements with [Trusted CI](https://trustedci.org/), the NSF Cybersecurity Center of Excellence. The first engagement was in 2018, during which Trusted CI conducted an in-depth vulnerability assessment and identified a few implementation issues that the Open OnDemand developers subsequently addressed.  [A report of that 2018 engagement is available here.](https://openondemand.org/trustedci-2018) The next engagement was in early 2021 and had three objectives: (1) integrate security automation into DevOps flows; (2) transfer skills for vulnerability assessments; and (3) develop needed security policies, practices, and procedures.  [A report of that 2021 engagement is available here.](https://openondemand.org/trustedci) 
