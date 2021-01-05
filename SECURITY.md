# Security Policy

This document outlines security procedures and general policies for the `OnDemand`
project.

## Security Audits

[Trusted CI](https://trustedci.org/), the NSF Cybersecurity Center of 
Excellence, conducted an in-depth vulnerability assessment of Open OnDemand, completing 
it in December 2018. This assessment included a careful review of the code, increasing 
our confidence in its security. The Ohio Supercomputing Center addressed the implementation 
issues (bugs) that were found during this review, producing a more robust revision of Open OnDemand.

## Reporting a Vulnerability

If you have security concerns or think you have found a vulnerability in Open OnDemand,
please contact us directly via [email](mailto:ood-users@lists.osc.edu) on the news list found 
[here](https://lists.osu.edu/mailman/listinfo/ood-users).  Emails sent to it are only seen by 
the core project team.

## Disclosure Policy

When the team receives a security vulnerability, they will generally assign it 
to a primary handler. This person will coordinate the fix and release process,
involving the following steps:

  * Confirm the problem and determine the affected versions.
  * Audit code to find any potential similar problems.
  * Prepare fixes for all releases still under maintenance. These fixes will be
    released as fast as possible.

## Comments on this Policy

If you have suggestions on how this process could be improved please submit 
a ticket, open a [Discorse](https://discourse.osc.edu/) topic or open a pull request.
