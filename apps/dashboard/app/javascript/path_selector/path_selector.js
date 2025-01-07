'use strict';

import { PathSelectorTable } from "./path_selector_data_table";

export function attachPathSelectors() {
  $("[data-path-selector='true']").each((_idx, element) => {
    const query = `#${pathSelectorId(element.id)}`;
    const modal = $(query).get(0);

    makeTable(modal);
  });  
}

function pathSelectorId(id) {
  return `${id}_path_selector`;
}

function makeTable(element) {
  const options = getPathSelectorOptions(element);
  new PathSelectorTable(options);
}

function getPathSelectorOptions(element) {
  const options = {};

  options.filesPath           = element.dataset['filesPath'];
  options.initialDirectory    = element.dataset['initialDirectory'];
  options.tableId             = element.dataset['tableId'];
  options.breadcrumbId        = element.dataset['breadcrumbId'];
  options.selectButtonId      = element.dataset['selectButtonId'];
  options.inputFieldId        = element.dataset['inputFieldId'];
  options.showFiles           = element.dataset['showFiles'];
  options.showHidden          = element.dataset['showHidden'];
  options.filePattern         = element.dataset['filePattern']
  options.modalId             = element.id;

  return options;
}
