# Open OnDemand Versioning Policy
## Version Numbering
Open OnDemand code releases utilize a XXX.YYY.ZZZ numbering scheme (e.g. 2.0.29), where:
* XXX is the major version number
* YYY is the minor version number
* ZZZ is the patch version number

## Major Versions
Major versions have large sets of new features and functionalities.  They can
include breaking changes that prevent seamless upgrading from previous versions.
They can also include removal of functionality or configuration that has been
deprecated in previous versions.

## Minor Versions
Minor versions will contain new functionality that's backward compatible. They may
also contain bug fixes that are not in the prior releases' patch versions.

Minor versions will also introduce deprecations to functionality or configurations
that maybe be removed in the next major version.

## Patch Versions
Patch versions will only contain security fixes and bug fixes.

## Nightly versions
Nightly packages (.rpm and .deb) are built every night from of the current commit in
the main branch and released to the nightly repository.  They have varying degrees of
stability, mostly related to the release cycle. The closer in time they are to a release
the more stable they're generally considered.

## Dependency updates
Dependency updates may come anywhere in the release cycle. For example even in
a patch release. Dependencies (like `ruby` or `nodejs`) updates are largely driven
by the operating systems we support.

If a dependency has reached it's end of life for support from an operating system,
we may update that dependency even in a patch release.

Minor, major and patch versions may all include dependency updates should a dependency
reach the end of life within a given release cycle.

## Tagging
We create two types of tags. The first are regular tags like `v3.0.0` which is a real
production version.  The other are release candidates like `v3.0.0-rc8`.  Release candidates
are created for testing purposes by OSC, though they're freely available to anyone to
also test. Release candidates are considered stable, but could contain bugs.


## Version Timing
The Open OnDemand team anticipates releasing new major versions every 1 to 2 years.
Minor versions are generally released at most a few times per year.

Patch versions are released as needed.

All versions are typically tested first in production for at least a week at OSC
and other early adopter sites prior to being marked as an official release.

## Backporting and Support
The Open OnDemand team will only provide general support / backporting for a major/minor version
for a period of 3 months after the next major/minor version is released
(i.e. version 2.0 will only be supported for 3 months after the release of 3.0).  This includes
providing concurrent patch versions for relevant security / bug fixes where possible
(i.e. the developers would release a 2.0.1 version alongside a 3.0.1 version if released within
3 months of the 3.0 release).  The Open OnDemand community is welcome to generate pull requests
for additional backport code changes outside of that time frame.
