'use strict';

const bcPrefix = 'batch_connect_session_context';
const shortNameRex = new RegExp(`${bcPrefix}_([\\w\\-]+)`);
const tokenRex = /([A-Z][a-z]+){1}([\w\-]+)/;

// @example ['NodeType', 'Cluster']
const optionTokens = [];

// simple lookup table to indicate that the change handler is setup between two
// elements. I.e., {'cluster': [ 'node_type' ] } means that changes to cluster
// trigger changes to node_type
const handlerCache = {};

function bcElement(name) {
  return `${bcPrefix}_${name.toLowerCase()}`;
};

// here the simple name for 'batch_connect_session_context_cluster'
// is just 'cluster'.
function shortId(elementId) {
  const match = elementId.match(shortNameRex);

  if (match.length >= 1) {
    return match[1];
  } else {
    return '';
  };
};

/**
 * Mountain case the words from a string, by tokenizing on [-_].  In the
 * simplest case it simple capitalizes.
 *
 * @param      {string}  str     The word string to capitalize
 *
 * @example  given 'foo' this returns 'Foo'
 * @example  given 'foo-bar' this returns 'FooBar'
 */
 function mountainCaseWords(str) {
  let camelCase = "";
  let capitalize = true;

  str.split('').forEach((c) => {
    if (capitalize) {
      camelCase += c.toUpperCase();
      capitalize = false;
    } else if(c == '-' || c == '_') {
      capitalize = true;
    } else {
      camelCase += c;
    }
  });

  return camelCase;
}

function snakeCaseWords(str) {
  let snakeCase = "";
  let first = true;

  str.split('').forEach((c) => {
    if (first){
      first = false;
      snakeCase += c.toLowerCase();
    } else if(c == c.toUpperCase()) {
      snakeCase += `_${c.toLowerCase()}`;
    } else {
      snakeCase += c;
    }
  });

  return snakeCase;
}

/**
 *
 * @param {Array} elements
 */
function memorizeElements(elements) {
  elements.each((_i, ele) => {
    optionTokens.push(mountainCaseWords(shortId(ele['id'])));
    handlerCache[ele['id']] = [];
  });
};

function makeChangeHandlers(){
  const allElements = $(`[id^=${bcPrefix}]`);
  memorizeElements(allElements);

  allElements.each((_i, element) => {
    if (element['type'] == "select-one"){
      let optionSearch = `#${element['id']} option`;
      let options = $(optionSearch);
      options.each((_i, opt) => {
          // the variable 'opt' is just a data structure, not a jQuery result. 
          // it has no attr, data, show or hide methods so we have to query
          // for it again
          let data = $(`${optionSearch}[value='${opt.value}']`).data();
          let keys = Object.keys(data);
          if(keys.length !== 0) {
            keys.forEach((key) => {
              addChangeHandler(parseOptions(key), element['id']);
            });
          }
      });
    }
  });
};

function addChangeHandler(causeId, targetId) {
  const changeId = String(causeId || '');

  if(changeId.length == 0 || handlerCache[causeId].includes(targetId)) {
    // nothing to do. invalid causeId or we already have a handler between the 2
    return;
  }

  let causeElement = $(`#${causeId}`);

  if(targetId && causeElement) {
    // cache the fact that there's a new handler here
    handlerCache[causeId].push(targetId);

    causeElement.on('change', (event) => {
      toggleOptionsFor(event, targetId);
    });

    // fake an event to initialize
    toggleOptionsFor({ target: document.querySelector(`#${causeId}`) }, targetId);
  }
};

/**
 @example

  optionForNodeTypeFoo ->
    batch_connect_session_context_node_type
    or
    undefined if it can't parse anything
 
  @param {string} data - the option string to parse

 */
function parseOptions(input) {
  // looking for NodeType when i know i have node_type
  const str = input.replace('optionFor','');

  // just return the first one you find
  return optionTokens.map((token) => {
    let match = str.match(`^${token}{1}`);

    if (match && match.length >= 1) {
      let ele = snakeCaseWords(match[0]);
      return bcElement(ele);
    }
  }).filter((id) => {
    return id !== undefined;
  })[0];
}

/**
 * Hide or show options of an element based on which cluster is
 * currently selected and the data-option-for-CLUSTER attributes
 * for each option
 *
 * @param      {string}  element_name  The name of the element with options to toggle
 */
 function toggleOptionsFor(event, elementId) {
  const options = $(`#${elementId} option`);

  // If I'm changing cluster to 'oakely', optionFor is 'Cluster'
  // and optionTo is 'Oakley'.
  const optionTo = mountainCaseWords(event.target.value);
  const optionFor = optionForEvent(event.target);

  options.each(function(_i, option) {
    // the variable 'option' is just a data structure. it has no attr, data, show
    // or hide methods so we have to query for it again
    let optionElement = $(`#${elementId} option[value='${option.value}']`);
    let data = optionElement.data();
    let hide = data[`optionFor${optionFor}${optionTo}`] === false;

    if(hide) {
      optionElement.hide();

      if(optionElement.prop('selected')) {
        optionElement.prop('selected', false);

        // when de-selecting something, the default is to fallback to the very first
        // option. But there's an edge case where you want to hide the very first option,
        // and deselecting it does nothing.
        if(optionElement.next()){
          optionElement.next().prop('selected', true);
        }
      }
    } else {
      optionElement.show();
    }
  });
};

function optionForEvent(target) {
  let simpleName = shortId(target['id']);
  return mountainCaseWords(simpleName);
};

jQuery(function() {
  makeChangeHandlers();
});
