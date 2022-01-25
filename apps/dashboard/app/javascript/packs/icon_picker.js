'use strict';

import ALL_ICONS from 'icons';

const ICON_SHOW_ID = "product_icon"
const ICON_SELECT_ID = "product_icon_select"



function listItem(name) {
  return `<li 
              id="${iconId(name)}" 
              class="btn btn-outline-dark"
              role='button'>
            <i class="fas fa-${name} fa-fw"></i>
          </li>`;
}

function iconId(name) {
  return `icon_${name.replaceAll('-', '_')}`;
}

function iconFromId(id) {
  const m = id.match(/^icon_([\w+_]+)/);
  if(m && m[1]) { return m[1].replaceAll('_','-') };
}

function picked(event) {
  const icon = iconFromId(event.currentTarget.id);
  $(`#${ICON_SHOW_ID}`).attr("class", `fas fa-${icon} fa-fw app-icon`);
  $(`#${ICON_SELECT_ID}`).val(`fas://${icon}`)
}

function populateList() {
  const list = $("#icon_picker_list");
  if(list.length == 0 || ALL_ICONS.length == 0) { return; }

  // let's (re)-set the first icon since the ul has no li, then
  // we can slice it out below.
  list.html(listItem(ALL_ICONS[0]));

  ALL_ICONS.slice(1).forEach(name => {
    list.append(listItem(name));

    const id = iconId(name);
    $(`#${id}`).on('click', (event) => { picked(event)});
  });
};

jQuery(() => {
  populateList();
})