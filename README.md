# Getting started

```
mkdir cloudcmd
cd cloudcmd
```

Clone `osc-fileexplorer`

### Install dependencies

Use `npm` to install the dependencies defined in the `package.json`

```
$ npm i
```

### Copy the custom osc code to cloudcmd

```
$ cp -r osc_custom/* node_modules/cloudcmd/
```

Currently, this removes the Contact option and replaces the Console functionality with a link to the Wetty app.

## (Optional) Manual Instructions:

##### Remove undesirable features

Find and remove the following lines from `node_modules/cloudcmd/html/index.html`

```
<button id=~       class="cmd-button reduce-text icon-console"   title="Console"         >~</button>
<button id=contact class="cmd-button reduce-text icon-contact"   title="Contact"         ></button>
```

##### Add wetty link

Add this line with the appropriate to the bottom of the button list at `node_modules/cloudcmd/html/index.html`

```
<a href="http://websvcs08.osc.edu:5000/pun/shared/jnicklas/wetty/ssh/" target="_blank"><button id=wetty class="cmd-button reduce-text icon-console" title="Wetty">~</button></a>
```

##### Disable authentication checkbox

Add `false` and `disabled` to checkbox in `node_modules/cloudcmd/tmpl/config.hbs`

```
<input data-name="js-auth" type="checkbox" false disabled>
```


