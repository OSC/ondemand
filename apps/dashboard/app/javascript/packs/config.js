'use strict;'

const CONFIG_ID = 'ood_config'

function configData() {
  return document.getElementById(CONFIG_ID).dataset;
}

function setNavbarColor() {
  const cfgData = configData();
  const styles = document.styleSheets[0];

  const bgLightColor = cfgData['bgColor'] === '' ? 'rgb(248, 248, 248)' : cfgData['bgColor'];
  const bgDarkColor = cfgData['bgColor'] === '' ? 'rgb(83, 86, 90)' : cfgData['bgColor'];

  const linkLightColor = cfgData['linkBgColor'] === '' ? 'rgb(231, 231, 231)' : cfgData['linkBgColor'];
  const linkDarkColor = cfgData['linkBgColor'] === '' ? 'rgb(59, 61, 63)' : cfgData['linkBgColor'];

  styles.insertRule(navbar('light', bgLightColor), styles.rules.length);
  styles.insertRule(navbar('dark', bgDarkColor), styles.rules.length);
  
  styles.insertRule(navbarHighlight('light', linkLightColor), styles.rules.length);
  styles.insertRule(navbarHighlight('dark', linkDarkColor), styles.rules.length);
}

function navbar(theme, color){
  return `
    .navbar-${theme} {
      background-color: ${color};
    }`;
}

function navbarHighlight(theme, color) {
  return `
    .navbar-${theme} ul.navbar-nav > li.nav-item > a:focus, .navbar-${theme} ul.navbar-nav > li.nav-item.show > a {
      background-color: ${color};
      border-radius: 0.25em;
    }`;
}

function maxFileSize () {
  const cfgData = configData();

  // Check if cfgData['maxFileSize'] is just empty string, 
  // if so set default of maxFileUpload=10737420000 bytes.
  if (cfgData['maxFileSize'].length == 0) {
    return parseInt(10737420000, 10);
  }
  else {
    const maxFileSize = cfgData['maxFileSize'];
    return parseInt(maxFileSize, 10);
  }
}

function transfersPath() {
  const cfgData = configData();
  const transfersPath = cfgData['transfersPath'];

  return transfersPath;
}

function csrfToken() {
  const csrf_token = document.querySelector('meta[name="csrf-token"]').content;

  return csrf_token;
}

export { 
  setNavbarColor, 
  maxFileSize, 
  transfersPath, 
  csrfToken 
};
