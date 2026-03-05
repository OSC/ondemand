# Open OnDemand Versioning Policy
## Version Numbering
Open OnDemand releases follow a three-part versioning scheme: XXX.YYY.ZZZ, such as `4.1.3`, where:
* XXX is the major version number
* YYY is the minor version number
* ZZZ is the patch version number

## Major Versions
Major versions introduce significant new features and functionality.  They may
include breaking changes that prevent seamless upgrades from previous versions and
may remove functionality or configuration that was deprecated in previous versions.

## Minor Versions
Minor versions contain new functionality that is backward compatible and include bug fixes,
including fixes previously released in patch versions. They may also include security fixes.

Minor versions may also introduce deprecations to functionality or configurations 
that may be removed in the next major version.

## Patch Versions
Patch versions primarily contain security fixes and bug fixes and are not intended to 
introduce new functionality.

## Nightly Versions
Nightly packages (.rpm and .deb) are built every night from the current commit in
the main branch and released to the nightly repository.  Stability varies depending on 
the development cycle. Nightly builds closer to a release candidate are generally more
stable, though no guarantees are provided.

## Dependency Updates
Dependency updates may occur at any point in the release cycle, including in patch releases
when necessary. Updates to dependencies such as `ruby` or `nodejs` are often driven
by operating system support policies and security requirements, particularly when a 
dependency reaches end of life.

## Tagging
We create two types of tags. The first are regular tags like `v4.0.0` which is a real
production version.  The other are release candidates like `v4.0.0-rc2`.  Release 
candidates are created primarily for testing at OSC and early adopter sites, but are 
publicly available for broader testing. Release candidates are considered stable, 
but could contain bugs.

## Version Timing
Patch versions are generally released on an approximately 8-week cadence from announcement 
to announcement. This cadence was introduced to provide sites with a more predictable 
planning window for updates. Exceptions may occur for high-impact bugs or security 
vulnerabilities, which may be released outside of the standard patch window.

Major and minor versions are released as new functionality is ready and validated through 
internal testing and subsequent production deployment at OSC. 

Versions are typically deployed in OSC production for a minimum of one week prior to 
being announced as an official release. This validation period may be shortened in 
cases of urgent security vulnerabilities or high-impact issues.

## Backporting and Support
The Open OnDemand team provides support and backporting for active major and minor release 
series. While a support window has previously been defined, its application has varied. 
This policy clarifies and standardizes that approach.

The team provides approximately four months of support after a subsequent major or minor 
version is released. This aligns with the current patch cadence and generally results
in two patch cycles of overlap.

During this overlap period, concurrent patch releases may be provided for relevant security 
fixes and significant bug fixes where feasible. Outside of this window, additional backports 
are not typically provided by the core team. Community members may maintain and apply their 
own patches as needed.
