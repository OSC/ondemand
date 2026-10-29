# OOD Shell

This app is distributed as a part of Open OnDemand.  Configure a File Access Control List
on this directory and or the `manifest.yml` file to disable it for some users.

This documentation assumes you have [development enabled](https://osc.github.io/ood-documentation/latest/app-development/enabling-development-mode.html)
for yourself.  Containers built in [the development documentation](../../DEVELOPMENT.md)
have development enabled automatically.

This is a guide for developing this application and assumes you have nodejs available on the system.

You can refer to the [documentation on customizing](https://osc.github.io/ood-documentation/latest/customization.html)
if you're looking to update your installation.

## On-screen terminal keys

Use **Keys** in the Shell menu to show or hide the terminal keypad. It appears
initially when the browser reports a coarse pointing device, including touch
screens on computers with hardware keyboards. Your visibility choice is saved
when browser storage is available; the default does not detect a keyboard.

On short viewports, including when a software keyboard reduces the visible
height, **More** reveals the control shortcuts, symbols, Home, End, page
navigation and Shift Tab. **Less** collapses them again. Esc, Tab, Ctrl, Alt
and the arrows remain available in the compact layout. Larger viewports show
all keys. Touch targets keep their normal size in either layout.

Activate Ctrl or Alt once to apply it to the next key, twice to lock it, and a
third time to turn it off. The underline identifies a locked modifier. Hiding
the keypad or hiding the page clears armed modifiers. Arrows and page-navigation
keys repeat while held; releasing the key, cancelling the pointer, leaving the
window or disconnecting stops repetition.

Other keypad buttons activate on release. To cancel a pressed shortcut such as
Ctrl-D, move away from the button before releasing. Keyboard and assistive
technology activation also work through the buttons' normal click actions.

Modifier rules:

- A one-shot modifier is consumed by the next accepted input even when it does
  not change the bytes, as with Ctrl+Tab or Ctrl+Esc.
- Dedicated Ctrl-C, Ctrl-Z, Ctrl-D and Ctrl-X buttons send those shortcuts
  directly. They ignore armed modifiers and consume one-shots; locks remain on.
- Sticky modifiers transform single-character keyboard input. Longer strings,
  including composition, autocomplete and hardware arrow sequences, pass through
  unchanged and consume one-shots. Paste and terminal-generated responses bypass
  sticky modifiers and do not consume them.
- Keypad Alt uses an ESC prefix for text (Meta), independently of hterm's
  `alt-sends-what` preference. Navigation keys use xterm modifier parameters and
  respect application cursor mode.
- Shift Tab sends `ESC [ Z`, with xterm modifier parameters when Ctrl or Alt is
  armed.

### Testing the keypad

With development dependencies installed, run all Shell tests with:

```sh
npm test -- --runInBand
```

The keypad integration suite renders the actual Handlebars view in jsdom and
loads the complete bundled hterm library. It checks DOM events, focus, modifier
state, input routing, pointer cancellation, repeat timing and viewport changes.
It does not emulate a browser's layout engine or software keyboard.

Before release, check iOS Safari and an Android browser with the software
keyboard open in portrait and landscape. Confirm that the terminal remains
usable, More exposes all secondary keys, modifiers affect typed input, and
sliding away cancels shortcuts. Also check repeat release over the terminal
iframe, simultaneous touches, keyboard dismissal and reopening, and screen
reader announcements for the one-shot and locked states.

## Development

First, you'll need to clone this repo and make a symlink if you haven't don so already.

```text
mkdir -p ~/ondemand/dev
git clone https://github.com/OSC/ondemand.git ~/ondemand/src
cd ~/ondemand/dev
ln -s ../src/apps/shell
```


```text
cd ~/ondemand/dev/shell
bin/setup
```

Now you should be able to navigate to `/pun/dev/shell` and see the app
in the developer views.

### Failures to start

If you ever encounter an error like this, it's because you ran `bin/setup` to compile the javascript
against a higher version of `/lib64/libstdc++` than what's available on the webnode.

You may be building it on a login node, but the runtime is always the webnode (where Open OnDemand is installed).

If you use modules, check the g++/c++ modules you have enabled when you build or simply `module purge` and rebuild
with the default, system installed c++ binary.

```
Error: /lib64/libstdc++.so.6: version `CXXABI_1.3.9' not found (required by /users/PZS0714/johrstrom/ondemand/src/apps/shell/node_modules/node-pty/build/Release/pty.node)
    at Object.Module._extensions..node (internal/modules/cjs/loader.js:1057:18)
    at Module.load (internal/modules/cjs/loader.js:863:32)
```

### Customizing

Now you can refer to the [documentation on customizing](https://osc.github.io/ood-documentation/latest/customization.html)
and make those changes to a `.env.local` file in the same directory as this README.md.

### Running this app locally

You can also boot this app locally outside of Open OnDemand infrastructure.

Run this command:
```text
node app.js
```
And you should see it's listening on port 3000.

You can now navigate to the app in a web-browser.

`http://localhost:3000/`

To specify the host:

`http://localhost:3000/ssh/<host>`

To specify a directory on the default host:

`http://localhost:3000/ssh/default/<dir>`

To specify a host and directory:

`http://localhost:3000/ssh/<host>/<dir>`

### Terminal Color Themes

Color Themes from https://github.com/mbadolato/iTerm2-Color-Schemes:

- windowsterminal themes used (since they are JSON format) with "cursorColor": specified
- renamed Builtin Pastel Dark to Pastel Dark
- renamed Builtin Solarized Light to Solarized Light
- see [iTerm-Color-Schemes](https://github.com/mbadolato/iTerm2-Color-Schemes) for access to individual theme licenses

### Updating `hterm`

Clone Google's repository that includes some other things in addition to hterm:

```console
$ git clone https://chromium.googlesource.com/apps/libapps
```

Run the build script. It requires Python, specifically Python 3 for hterm 1.81 and newer. Here, it is run from the root directory of this new local repository (libapps):

```console
$ scl enable rh-python35 -- hterm/bin/mkdist.sh
```

There will be a file created in `hterm/dist/js` called `hterm_all.js`. Copy and rename this file to `public/javascripts/hterm_all_x.xx.js` in the Shell App repository, where x.xx represents the version number hterm (for cache busting), and change the reference in `views/index.hbs` to point to this new file.

#### Hacking `hterm`

So you've updated hterm and now something is broken.  Maybe only on one platform (*cough firefox*).  Here's a list of hacks/changes we've made to these files so when you're updating from one version to another you may have to add these 
changes. If you're lucky you may be able to cherry pick them, if not, hopefully we've made an issue where you can reference and you can at least see the commit. 

* 0cbc84e3d53386064e278a0495c940a217f4f18b - that fixed [issue 64](https://github.com/OSC/ood-shell/issues/64)
* <commit needed> - that fixed [issue 5101](https://github.com/OSC/ondemand/issues/5101)

This commit seems to have been fixed upstream, so no need to add it. We're just leaving it here
in the documentation for historical purposes. For completeness, this was fixed upstream in
https://chromium.googlesource.com/apps/libapps/+/ed10144155cc3abbc68b2ff94bfeda23c94159cf
* a9e2e3980b0f491d0478a20e21aad022285b64ee - that fixed [issue 1214](https://github.com/OSC/ondemand/issues/1214)
