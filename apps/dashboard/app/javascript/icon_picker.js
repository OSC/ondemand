'use strict';

import ALL_ICONS from './icons';

const ICON_SHOW_ID = "product_icon"
const ICON_SELECT_ID = "product_icon_select"

// simple boolean for whether there are currently any hidden icons
let hiddenIcons = false;

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
  updateIcon(icon);
  showAllIcons();
}

function updateIcon(icon) {
  $(`#${ICON_SHOW_ID}`).attr("class", `fas fa-${icon} fa-fw app-icon`);
  $(`#${ICON_SELECT_ID}`).val(`${icon}`);
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

    updateIcon(currentValue);
    searchIcons(event);
  });
}

/**
 * Creates an inverted index of ALL_ICONS.
 * Returns an array type.
 **/
 function createInvertedIndex(arr) {
  const invertedIndex = {};

  arr.forEach((str, index) => {
    for (let i = 0; i < str.length; i++) {
      const char = str[i];
      if (!invertedIndex[char]) {
        invertedIndex[char] = [];
      }
      invertedIndex[char].push(index);
    }
  });

  return invertedIndex;
}
 
const invertedIndex = createInvertedIndex(ALL_ICONS);

function searchIcons(event) {
  const searchString = event.target.value.toLowerCase(); // Convert input to lowercase for case-insensitive search
  const indexKeys = Object.keys(invertedIndex); // Get all keys (characters) from the inverted index
  const resultIndices = new Set(); // Set to store indices of matching icons
  const uniqueSearchCharacters = new Set(searchString.split(''));
  const searchCharacters = [...uniqueSearchCharacters].filter((char) => indexKeys.includes(char));

  // Account for boundary condition where the search string is empty
  if(searchString.length === 0) {
    for(let i = 0; i < ALL_ICONS.length; i++) {
      resultIndices.add(i);
    }
  } else {
    searchCharacters.forEach(char => {
      const indices = invertedIndex[char]; // Get indices for the character in the inverted index
      indices.forEach(index => {
        const iconStr = ALL_ICONS[index].toLowerCase();
        if (iconStr.includes(searchString)) {
          resultIndices.add(index);
        }
      });
    });
  }

  ALL_ICONS.forEach((name, idx) => {
    const ele = $(`#${iconId(name)}`)[0];
    if (ele === undefined) {
      return;
    }

    const show = resultIndices.has(idx);

    if (show) {
      ele.classList.remove('d-none');
    } else {
      ele.classList.add('d-none');
    }
  });
}

function showAllIcons(){
  // there are no hidden icons, so just return
  if(hiddenIcons === false) {
    return;
  }

  ALL_ICONS.forEach(name => {
    const ele = $(`#${iconId(name)}`)[0];
    if(ele === undefined) {
      return;
    }

    ele.classList.remove('d-none');
  });

  hiddenIcons = false;
}

function addResetForm() {
  $(`#${ICON_SELECT_ID}`).closest('form').on('reset', () => {
    // show all icons if the form is reset
    showAllIcons();
    updateIcon('cog');
  });
}

jQuery(() => {
  populateList();
  addSearch();
  addResetForm();
})