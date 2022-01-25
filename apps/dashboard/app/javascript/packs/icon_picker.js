'use strict';

const ICON_SHOW_ID = "product_icon"
const ICON_SELECT_ID = "product_icon_select"

function all_icons() {
  return [...document.styleSheets].flatMap(styleSheet => {
    return [...styleSheet.cssRules]
      .map((rule) => {  
        const m = rule.cssText.match(/^\.fa-([\w-]+)/);
        if(m && m[1]) {
          let b = 'break!';
          return m[1];
        }
      })
      .filter(r => r);
  }).slice(700,714); //just get the first few right now
}

function listItem(name) {
  return `<li 
              id="${iconId(name)}" 
              class="btn btn-outline-dark">
            <i class="fas fa-${name}"></i>
          </li>`;
}

function iconId(name) {
  return `icon_${name.replace('-', '_')}`;
}

function iconFromId(id) {
  const m = id.match(/^icon_([\w+_]+)/);
  if(m && m[1]) { return m[1].replace('_','-') };
}

function picked(event) {
  console.log(event.currentTarget.id);

  const icon = iconFromId(event.currentTarget.id);
  $(`#${ICON_SHOW_ID}`).attr("class", `fas fa-${icon} app-icon`);
  $(`#${ICON_SELECT_ID}`).val(`fas://${icon}`)
}

function populateList() {
  const list = $("#icon_list");
  const icons = all_icons();
  if(list.length == 0 || icons.length == 0) { return; }

  // let's (re)-set the first icon since the ul has no li, then
  // we can slice it out below.
  list.html(listItem(icons[0]));

  icons.slice(1).forEach(name => {      
    list.append(listItem(name));

    const id = iconId(name);
    $(`#${id}`).on('click', (event) => { picked(event)});
  });
};

jQuery(() => {
  populateList();
})