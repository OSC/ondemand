
# Open OnDemand Roadmap

Open OnDemand (OOD) development is shaped by community feedback, project needs, grant commitments, 
technical requirements, and input from project stakeholders. This page explains how we prioritize 
work, track development, and plan releases.

Priorities and plans may change as new needs arise.

## What's Planned for the Next Release

For information on what's being considered for the next major or minor release, check our project 
boards under [GitHub Projects](https://github.com/orgs/OSC/projects) and [GitHub milestones](https://github.com/OSC/ondemand/milestones).

These are updated frequently, include a README for more information, and status updates on the integrated side panel. Plans 
may change and inclusion in a milestone or project board does not guarantee a feature will be included in the next release.

## Where Work Comes From

Development work comes from several places:

- GitHub issues opened by the community or OOD team
- Security advisories and vulnerabilities
- Community feedback through Discourse, conferences, and community meetings
- Input from project leadership, grant PIs, governance committees, grant committments, and OSC

## How We Prioritize Work

The OOD team uses a mix of community feedback, team judgement, and project 
requirements to determine priorities.

Security vulnerabilities and high-impact bugs typically take priority over planned 
development work and they require an earlier patch or release.

For major and minor releases, we generally consider:

- **Required work:** Dependencies, compatibility, grant commitments, and other project requirements
- **Community requests:** Features and improvements requested by users and administrators
- **Maintainer-driven work:** Features and improvements proposed by the development team along with
- strategic planning
- **Ongoing maintenance:** Bug fixes, testing, documentation, refactors, and technical debt

These aren't strict categories or a fixed order. Priorities depend on the needs of the project, 
available resources, and release plans.

## How We Track Work

We use GitHub to organize and track development across the Open OnDemand repositories, primarily 
`ondemand`, `ood_core`, and `ood-documentation`.

Issues are organized using labels, issue types, and fields that are all in GitHub.

We also use GitHub milestones and project boards to plan upcoming releases, track pull requests, and 
stay on top of delivering new versions of OOD.

- [GitHub Project Boards](https://github.com/orgs/OSC/projects)
- [Release Milestones](https://github.com/OSC/ondemand/milestones)
- [ondemand Repository Issues](https://github.com/OSC/ondemand/issues)

## From Issue to Release

Work generally moves through the following steps:

1. An issue is opened, categorized, and reviewed by the team.
2. The issue is triaged and, when appropriate, included in release planning.
3. Changes are developed through pull requests, reviewed, tested, and merged into the main branch.
4. Pull request commits are backported to supported versions when needed.
5. The code goes through testing before a patch or release is published via manual and automated testing along
   with being deployed to OSC production for at least one week.
7. Release announcements communicate fixes, new features, and other updates to the community via Discourse,
   our documentation pages, the newsletter, and the occasional press release.

The process may vary depending on the type and urgency of the work.

## Release Planning

**Patch releases** generally follow an eight-week schedule. They may include bug fixes, security fixes, 
and dependency updates. Security issues or other urgent fixes may require a release outside the regular schedule.

**Major and minor releases** do not currently follow a fixed schedule. Timing depends on development 
progress, dependencies, grant commitments, conferences or community events, and other project deadlines.

See the [Open OnDemand Versioning Policy](https://github.com/OSC/ondemand/blob/master/VERSIONING_POLICY.md) for more information.

## Who Helps Set Priorities

The OOD team at OSC handles day-to-day issue triage, development planning, and releases.

Project PIs, grant stakeholders, and governance committees help guide priorities and strategic direction. 
Community feedback also plays a critical role in identifying bugs, requesting features, and driving development decisions.

## Community Feedback and Feature Requests

We welcome and truly value feedback from the Open OnDemand community!

If you have an idea or run into an issue, you can:

- [Open a GitHub issue](https://github.com/OSC/ondemand/issues) or add comments and reactions to an existing issue.
- Share questions, suggestions, and feedback on [Open OnDemand Discourse](https://discourse.openondemand.org/).
- Participate in community meetings and discussions.
