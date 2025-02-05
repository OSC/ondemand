# Open OnDemand's Accessibility Assessment


## Table of Contents

- [Introduction](#introduction)
- [3rd Party Apps](#3rd-party-apps)
- [Accessibility by URL](#accessibility-by-url)
  - [All or most URLs](#all-or-most-urls)
  - [/pun/sys/dashboard](#/pun/sys/dashboard)
  - [/pun/sys/dashboard/batch_connect and sub URLs](#/pun/sys/dashboard/batch_connect-and-sub-urls)
    - [/pun/sys/dashboard/batch_connect/sessions](#/pun/sys/dashboard/batch_connect/sessions)
    - [Batch connect app web forms](#batch-connect-app-web-forms)
  - [/pun/sys/dashboard/noVNC-1.1.0/vnc.html](#/pun/sys/dashboard/noVNC-1.1.0/vnc.html)
  - [/pun/sys/dashboard/files and sub URLs](#/pun/sys/dashboard/files-and-sub-urls)
  - [/pun/sys/shell and sub URLs](#/pun/sys/shell-and-sub-urls)
  - [/pun/sys/myjobs and sub URLs](#/pun/sys/myjobs-and-sub-urls)
  - [/pun/sys/dashboard/admin and sub URLs](#/pun/sys/dashboard/admin-and-sub-urls)


## Introduction

This document describes the accessibility of Open OnDemand version `2.0.26`
with regard to the WCAG 3.0 standard.

Specifically, it outlines where Open OnDemand does not meet this standard.
It may also link to a ticket that developers track. You can search
[all accessibility issues](https://github.com/OSC/ondemand/issues?q=is%3Aissue+is%3Aopen+label%3Aarea%2Faccessibility)
as well.

## 3rd Party Apps

Open OnDemand not only provides some basic functionality out of the box,
it is also a platform to use other applications like Jupyter, RStudio and
Matlab just to name a few.

We do not control the accessibility of these third party apps and they
are not documented here.

## Accessibility by URL

Each section below documents a single webpage. If the section heading
includes sub URLs this means the same webpage is used to generate content
based on the URL.

As an example in the section entitled `/pun/sys/dashboard/files and sub URLs`,
the URL `/pun/sys/files/fs/home/annie` will have the same accessibility characteristics
as `/pun/sys/files/fs/home/jessie`.

### All or most URLs

These issues affect all or most URLs.

- Most URLs have the main navigation bar. This is a list of issues with that navigation
  bar. See this issue for [navigation bar accessibility issue](https://github.com/OSC/ondemand/issues/945)
  for more details.
  - Screen readers will see the navigation bar landmark as 'banner landmark', 'navigation'
    and 'navigation landmark', where really we should only have 1 single landmark.
- Many [alerts don't notify screen readers.](https://github.com/OSC/ondemand/issues/2077)
  As an example, when you start an interactive session there's an alert to notify the user
  of it's success or failure. Screen readers should be notified of this alert.

### /pun/sys/dashboard

This is the landing page and what the root URL `/` redirects to.

The landing page allows for site administrators to create panels. The panels we
distribute are covered in this document. Panels specifically created at any
given site are unknown to us (the developers), have not and will not be assessed
for accessibility.

- [The welcome logo does not provide alt text.](https://github.com/OSC/ondemand/issues/2067)
- [Message of the Day and pinned apps use heading levels 3 & 4 instead of 2 & 3.](https://github.com/OSC/ondemand/issues/2074).

### /pun/sys/dashboard/batch_connect and sub URLs

#### /pun/sys/dashboard/batch_connect/sessions

- [Batch connect session cards are not very accessible.](https://github.com/OSC/ondemand/issues/664)
  There are several issues with batch connect session cards.
    - First when they change state, say from 'Queued' to 'Running' there's no notification that this happened.
    - Secondly, there's no good organization of these cards. They should probably be in a list.
    - Lastly some of the text is off, like the session id link that is a UUID. It's an ambiguous link.

#### Batch connect app web forms

Batch connect app forms are URLS in the form `pun/sys/dashboard/batch_connect/[TOKEN]/session_contexts/new`
where `[TOKEN]` is a specific app at a specific site.  While these apps are site specific the web forms
they create should be accessible.

Sites can add extra things to these forms that we (the developers) are not in control of.  This document
covers all the functionality that we the developers provide.  It does not cover customizations a site
may have included.

- [Dynamic form updates do not update the user.](https://github.com/OSC/ondemand/issues/2075)  When a
  user updates a form field, another form field may automatically be updated.  There is no screen reader
  notification when this occurs.
- [Resolution fields don't have the right labels.](https://github.com/OSC/ondemand/issues/2076)  Resolution
  form fields have labels visible to sighted users, but screen-reader navigation does not automatically read
  them. The user is forced to navigate around the form element to hear the label.

### /pun/sys/dashboard/noVNC-1.1.0/vnc.html

No VNC is a technology stack we use to access VNC applications over the web.
No VNC using the HTML5 `canvas` element which is currently inaccessible.  It does
not communicate with a screen reader whatsoever.

Native VNC clients like Tiger VNC or Real VNC are also inaccessible.

We have this [ticket concerning No VNC accessibility](https://github.com/OSC/ondemand/issues/675)
where we come to this conclusion.

### /pun/sys/dashboard/files and sub URLs

- [The files table does not notify users of updates](https://github.com/OSC/ondemand/issues/2080).
  When a user clicks through to another directory in the file browser table the table updates
  with the contents of the chosen directory. However, screen-readers are not notified that this
  change has occurred.
- [Screen-Readers read the sorting arrows in the files table](https://github.com/OSC/ondemand/issues/2081)
  when they should only read the column name.
- [File browsing landmarks could be better.](https://github.com/OSC/ondemand/issues/2079)  There's
  currently a little too much navigation to get anywhere interesting.

### /pun/sys/shell and sub URLs

The shell application is considered completely inaccessible.  Screen
readers do work on it a little, but it's so little as to be rendered
completely useless.

The underlying library `hterm` does have support for accessibility but
we need some mechanism to turn it on.

We have this ticket concerning [shell accessibility](https://github.com/OSC/ondemand/issues/672)
to tracks this.

### /pun/sys/myjobs and sub URLs

TODO

### /pun/sys/dashboard/admin and sub URLs

TODO
