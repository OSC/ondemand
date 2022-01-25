'use strict';

class IconPicker {

  constructor() {

  }

};



function makePicker() {
  ip = new IconPicker();
  

  const all_icons = [...document.styleSheets].flatMap(styleSheet => {
    return [...styleSheet.cssRules]
      .map(rule => rule.cssText.match(/fa-.+/) )
      .filter(r => r);
  });

  const f = 'break!';
}


jQuery({
  makePicker();
})