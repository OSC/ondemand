'use strict;'

const CONFIG_ID = 'ood_config'

function configData() {
  return $(`#${CONFIG_ID}`).data();
}

function setNavbarColor() {
  const cfgData = configData();
  const styles = document.styleSheets[0];

  styles.insertRule(navbar('light', cfgData['bgColor']), styles.lenth);
  styles.insertRule(navbar('dark', cfgData['bgColor']), styles.lenth);
  
  styles.insertRule(navbarHighlight('light', cfgData['linkBgColor']), styles.lenth);
  styles.insertRule(navbarHighlight('dark', cfgData['linkBgColor']), styles.lenth);
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

export { setNavbarColor };
