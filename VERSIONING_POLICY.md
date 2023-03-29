# Open OnDemand Versioning Policy
## Version Numbering
Open OnDemand code releases utilize a XXX.YYY.ZZZ numbering scheme (e.g. 2.0.29), where:
* XXX is the major version number
* YYY is the minor version number
* ZZZ is the patch version number

## Major Versions
New major version numbers will typically be implemented for any of the following reasons:
* Significant breaking changes that prevent seamless upgrading from previous versions
* Significant deprecations related to software dependencies
* Large sets of new features or functionalities

## Minor Versions
New minor version numbers will typically be implemented for any of the following reasons:
* New features of functionalities
* Large sets of bug fixes

## Patch Versions
New patch version numbers will typically be implemented for any of the following reasons:
* Security updates
* Minor bug fixes

## Tagging
Intermediate or transient releases will be indicated via additional tagging, including:
* Pre-release, for releases that are being actively tested in production at early adopter sites
* rc#, for release candidate # (where # gets incremented as needed for subsequent release candidates)

## Version Timing
The Open OnDemand team anticipates releasing new major versions every 1 to 2 years.  Minor versions are generally released at most a few times per year.  Patch versions are released as needed.  All versions are typically tested first in production for at least a week at early adopter sites prior to being marked as an official release.

## Backporting and Support
The Open OnDemand team will only provide general support / backporting for a major/minor version for a period of 3 months after the next major/minor version is released (i.e. version 2.0 will only be supported for 3 months after the release of 3.0).  This includes providing concurrent patch versions for relevant security / bug fixes where possible (i.e. the developers would release a 2.0.1 version alongside a 3.0.1 version if released within 3 months of the 3.0 release).  The Open OnDemand community is welcome to generate pull requests for additional backport code changes outside of that time frame.  
