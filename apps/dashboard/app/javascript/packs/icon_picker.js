'use strict';

import ALL_ICONS from './icons';

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
  const icon = iconFromId(event.target.id);
  updateIcon(icon);
  showAllIcons();
}

function updateIcon(icon) {
  $(`#${ICON_SHOW_ID}`).attr("class", `fas fa-${icon} fa-fw app-icon`);
  $(`#${ICON_SELECT_ID}`).val(`fas://${icon}`);
}

function populateList() {
  const list = $("#icon_picker_list");
  if(list.length == 0 || ALL_ICONS.length == 0) { return; }

  const listContent = ALL_ICONS.map(name => {
    return listItem(name);
  }).join('');
  list.html(listContent);

  ALL_ICONS.forEach(name => {
    $(`#${iconId(name)}`).on('click', (event) => { picked(event)});
  });
};

function addSearch(){
  $(`#${ICON_SELECT_ID}`).on('input change', (event) => {
    const currentValue = event.target.value;

    // template picked and set value or copy & pasted full icon uri
    if(currentValue.startsWith('fas://')) {
      updateIcon(currentValue.replace('fas://', ''));
    } else {
      searchIcons(event);
    }
  });
}

function searchIcons(event){
  const searchString = event.target.value;
  const rex = new RegExp(searchString, "g");

  ALL_ICONS.forEach(name => {
    const ele = $(`#${iconId(name)}`)[0];
    if(ele === undefined) {
      return;
    }

    const show = rex.test(name);

    if(show) {
      ele.classList.remove('d-none');
    } else {
      ele.classList.add('d-none');
    }
  });
}

function showAllIcons(){
  ALL_ICONS.forEach(name => {
    const ele = $(`#${iconId(name)}`)[0];
    if(ele === undefined) {
      return;
    }

    ele.classList.remove('d-none');
  });
}

jQuery(() => {
  populateList();
  addSearch();
})