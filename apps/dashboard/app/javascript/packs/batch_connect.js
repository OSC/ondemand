'use strict';

import { attachPathSelectors } from './path_selector/path_selector'

const bcPrefix = 'batch_connect_session_context';
const shortNameRex = new RegExp(`${bcPrefix}_([\\w\\-]+)`);

// @example ['NodeType', 'Cluster']
const formTokens = [];

// simple lookup table to indicate that the change handler is setup between two
// elements. I.e., {'cluster': [ 'node_type' ] } means that changes to cluster
// trigger changes to node_type
const optionForHandlerCache = {};


// simples array of string ids for elements that have a handler
const minMaxHandlerCache = [];
const setHandlerCache = [];
// hide handler cache is a map in the form '{ from: [hideThing1, hideThing2] }'
const hideHandlerCache = {};

// Lookup tables for setting min & max values
// for different directives.
const minMaxLookup = {};
const setValueLookup = {};
const hideLookup = {};

// whether we're still initializing or not
let initializing = true;

function bcElement(name) {
  return `${bcPrefix}_${name}`;
};

// Remove bcPrefix from elementId; Return empty string if prefix not found
// 'batch_connect_session_context_cluster' becomes 'cluster'
function shortId(elementId) {
  const match = elementId.match(shortNameRex);

  return (match.length >= 1) ? match[1] : '';
};

/**
 * Format passed string to snake_case. All characters become lowercase. Existing
 * underscores are unchanged and dashes become underscores. Underscores are added 
 * before locations where an uppercase character is followed by a lowercase character.
 *
 * @param      {string}  str     The word string to snake case
 *
 * @example  given 'PascalCase' this returns 'pascal_case'
 * @example  given 'camelCase' this returns 'camel_case'
 * @example  given 'OSC_JUPYTER' this returns 'osc_jupyter'
 */
function snakeCaseWords(str) {
  if(str === undefined) return undefined;

  let snakeCase = "";

  str.split('').forEach((c, index) => {
    if(c === '-' || c === '_') {
      snakeCase += '_';
    } else if (index == 0) {
      snakeCase += c.toLowerCase();
    } else if(c == c.toUpperCase() && isNaN(c)) {
      const nextIsUpper = (index + 1 !== str.length) ? str[index + 1] === str[index + 1].toUpperCase() : true;
      if (str[index-1] === '_' || nextIsUpper) {
        snakeCase += c.toLowerCase();
      } else {
        snakeCase += `_${c.toLowerCase()}`;
      }
    } else {
      snakeCase += c;
    }
  });

  return snakeCase;
}

/**
 * Get the data attributes for an element similar to jquery .data()
 * Returns a dict of all keys that start with data- after they have been snake_cased and remove data- prefix
 * Values of dict are values of attributes starting with data-
 * 
 * @param {*} element
 */
function getData(element) {
  let data = {};
  [...element.attributes].filter(x => x.name.startsWith('data-')).forEach(attr => {
    data[snakeCaseWords(attr.name.replace('data-', ''))] = attr.value;
  });
  return data;
}

/**
 * Returns a list of all nested parentNodes of an element
 * 
 * @param {*} element
 */
 function getParents(element) {
  const parents = [];
  let parent = element.parentNode;
  while (parent) {
    parents.push(parent);
    parent = parent.parentNode;
  }
  return parents;
}

/**
 * Add all snake_cased form element ids to the formTokens list
 * 
 * @param {Array} elements
 */
function memorizeElements(elements) {
  elements.forEach(ele => {
    formTokens.push(snakeCaseWords(shortId(ele.id)));
    optionForHandlerCache[ele.id] = [];
  });
};

function makeChangeHandlers(){
  // Get list of all elements whose ID starts with the bcPrefix
  const allElements = [...document.querySelectorAll(`[id^='${bcPrefix}']`)];
  memorizeElements(allElements);

  allElements.forEach((element) => {
    if (element['type'] == "select-one"){
      let options = [...document.querySelectorAll(`#${element['id']} option`)];
      options.forEach((opt) => {
        let data = getData(opt);
        Object.keys(data).forEach(key => {
          if (key.startsWith('option_for_')) {
            let token = key.replace(/^option_for_/,'');
            addOptionForHandler(idFromToken(token), element.id);
          } else if(key.startsWith('max') || key.startsWith('min')) {
            addMinMaxForHandler(element.id, opt.value, key, data[key]);
          } else if(key.startsWith('set')) {
            addSetHandler(element.id, opt.value, key, data[key]);
          } else if(key.startsWith('hide')) {
            addHideHandler(element.id, opt.value, key, data[key]);
          }
        });
      });
    }
  });
};

function addHideHandler(optionId, option, key,  configValue) {
  const changeId = idFromToken(key.replace(/^hide_/,''));

  if(hideLookup[optionId] === undefined) hideLookup[optionId] = new Table(changeId, 'option_value');
  const table = hideLookup[optionId];
  table.put(changeId, option, configValue);

  if(hideHandlerCache[optionId] === undefined) hideHandlerCache[optionId] = [];

  if(!hideHandlerCache[optionId].includes(changeId)) {
    const changeElement = document.getElementById(optionId);

    changeElement.addEventListener('change', (event) => {
      updateVisibility(event, changeId);
    });

    hideHandlerCache[optionId].push(changeId);
  }

  updateVisibility({ target: document.getElementById(optionId) }, changeId);
}

/**
 *
 * @param {*} subjectId batch_connect_session_context_node_type
 * @param {*} option gpu
 * @param {*} key maxNumCoresForClusterAnnieOakley
 * @param {*} configValue 42
 *
 * node_type:
 *   widget: select
 *   options:
 *    - [
 *        'gpu',
 *        data-max-num-cores-for-cluster-annie-oakley: 42
 *      ]
 */
function addMinMaxForHandler(subjectId, option, key, configValue) {
  subjectId = String(subjectId || '');
  configValue = parseInt(configValue);

  const configObj = parseMinMaxFor(key);
  const objectId = configObj['subjectId'];
  // this is the id of the target object we're setting the min/max for.
  // if it's undefined - there's nothing to do, it was likely configured wrong.
  if (objectId === undefined) return;

  const secondDimId = configObj['predicateId'];
  const secondDimValue = configObj['predicateValue'];

  // several subjects can try to change the object, so the table lookup key has to have both
  const lookupKey = `${subjectId}_${objectId}`;
  if(minMaxLookup[lookupKey] === undefined) minMaxLookup[lookupKey] = new Table(subjectId, secondDimId);
  const table = minMaxLookup[lookupKey];
  table.put(option, secondDimValue, {[minOrMax(key)] : configValue });

  let cacheKey = `${objectId}_${subjectId}_${secondDimId}`;
  if(!minMaxHandlerCache.includes(cacheKey)) {
    const changeElement = document.getElementById(subjectId);

    changeElement.addEventListener('change', (event) => {
      toggleMinMax(event, objectId, secondDimId);
    });

    minMaxHandlerCache.push(cacheKey);
  }

  cacheKey = `${objectId}_${secondDimId}_${subjectId}`;
  if(secondDimId !== undefined && !minMaxHandlerCache.includes(cacheKey)){
    const secondEle = document.getElementById(secondDimId);

    secondEle.addEventListener('change', (event) => {
      toggleMinMax(event, objectId, subjectId);
    });

    minMaxHandlerCache.push(cacheKey);
  }

  toggleMinMax({ target: document.querySelector(`#${subjectId}`) }, objectId, secondDimId);
}

/**
 *
 * @param {*} optionId batch_connect_session_context_classroom
 * @param {*} option 'PHY_9000'
 * @param {*} key setAccount
 * @param {*} configValue 'phy3005'
 *
 * classroom:
 *   widget: select
 *   options:
 *    - [
 *        'Physics Maximum', 'PHY_9000',
 *        data-set-account: 'phy3005'
 *      ]
 */
function addSetHandler(optionId, option, key, configValue) {
  const k = key.replace(/^set_/,'');
  const id = String(idFromToken(k));
  if(id === 'undefined') return;

  // id is account. optionId is classroom
  let cacheKey = `${id}_${optionId}`
  if(setValueLookup[cacheKey] === undefined) setValueLookup[cacheKey] = new Table(optionId, undefined);
  const table = setValueLookup[cacheKey];
  table.put(option, undefined, configValue);

  if(!setHandlerCache.includes(cacheKey)) {
    const changeElement = document.getElementById(optionId);

    changeElement.addEventListener('change', (event) => {
      setValue(event, id);
    });

    setHandlerCache.push(cacheKey);
  }

  setValue({ target: document.querySelector(`#${optionId}`) }, id);
}

function setValue(event, changeId) {
  const chosenVal = event.target.value;
  const cacheKey = `${changeId}_${event.target['id']}`
  const table = setValueLookup[cacheKey];
  if (table === undefined) return;

  const changeVal = table.get(chosenVal, undefined);

  if(changeVal !== undefined) {
    document.getElementById(changeId).value = changeVal;
  }
}

/**
 *
 *  This is a simple table class to describe the relationship between
 *  two different element types as a table with named columns.
 *
 *  table.get('gpu','owens') would return the value shown.
 *
 *      'oakley'   |                    |                |
 *      'owens'    | { min: 3, max: 42} |                |
 *                 |  'gpu'             |   'hugemem'    |
 *
 * In the simple case, it's a 1d vector instead of a 2d matrix. This
 * allows for, say, gpu to have the same min & max across clusters.
 */
class Table {
  constructor(x, y) {
    // FIXME: probably need to make Vector class? Wouldn't want to add a flag to the constructor.
    // we don't use x or y internally, though x is used externally.
    this.x = x;
    this.xIdxLookup = {};

    this.y = y;
    this.yIdxLookup = {};
    this.table = y === undefined ? [] : [[]];
  }

  put(x, y, value) {
    if(!x) return;
    x = snakeCaseWords(x);
    y = snakeCaseWords(y);

    if(this.xIdxLookup[x] === undefined) this.xIdxLookup[x] = Object.keys(this.xIdxLookup).length;
    if(y && this.yIdxLookup[y] === undefined) this.yIdxLookup[y] = Object.keys(this.yIdxLookup).length;

    const xIdx = this.xIdxLookup[x];
    const yIdx = this.yIdxLookup[y];

    if(this.table[xIdx] === undefined ){
      this.table[xIdx] = y === undefined ? undefined : [];
    }

    // if y's index is defined, then it's a 2d matrix. Otherwise a 1d vector.
    if(yIdx === undefined) {
      if(this.table[xIdx] === undefined){
        this.table[xIdx] = value;
      } else {
        const prev = this.table[xIdx];
        const newer = value;
        if(typeof newer == 'string' && typeof prev == 'string'){
          this.table[xIdx] = newer;
        } else {
          this.table[xIdx] = Object.assign(prev, newer);
        }
      }
    } else {
      if(this.table[xIdx][yIdx] === undefined){
        this.table[xIdx][yIdx] = value;
      } else {
        const prev = this.table[xIdx][yIdx];
        const newer = value;
        if(typeof newer == 'string' && typeof prev == 'string'){
          this.table[xIdx][yIdx] = newer;
        } else {
          this.table[xIdx][yIdx] = Object.assign(prev, newer);
        }
      }
    }
  }

  get(x, y) {
    const xIdx = this.xIdxLookup[snakeCaseWords(x)];
    const yIdx = this.yIdxLookup[snakeCaseWords(y)];

    if(this.table[xIdx] === undefined){
      return undefined;
    } else if(y === undefined){
      return this.table[xIdx];
    } else {
      return this.table[xIdx][yIdx];
    }
  }
}

/**
 * Update the visibility of `changeId` based on the
 * event and what's in the hideLookup table.
 */
function updateVisibility(event, changeId) {
  const val = event.target.value;
  const id = event.target['id'];
  let changeElement = undefined;
  getParents(document.getElementById(changeId)).forEach(parent => {
    if(parent.classList.contains('form-group')) {
      changeElement = parent;
      return false;
    }
  });

  if (changeElement === undefined || changeElement.length <= 0) return;

  // safe to access directly?
  const hide = hideLookup[id].get(changeId, val);
  if(hide === undefined && !initializing) {
    changeElement.style.display = '';
  }else if(hide === true) {
    changeElement.style.display = 'none';
  }
}

/**
 * Update the min & max values of `changeId` based on the
 * event, the `otherId` and the settings in minMaxLookup table.
 */
function toggleMinMax(event, changeId, otherId) {
  let x = undefined, y = undefined;

  // many subjects can change the object, so we have to find the correct table
  // in the form <subject>_<object>
  let lookupKey = `${event.target['id']}_${changeId}`;
  if(minMaxLookup[lookupKey] === undefined) {
    lookupKey = `${otherId}_${changeId}`;
  }

  const table = minMaxLookup[lookupKey];

  // in the example of cluster & node_type, either element can trigger a change
  // so let's figure out the axis' based on the change element's id.
  if(event.target.id == table.x) {
    x = snakeCaseWords(event.target.value);
    y = snakeCaseWords(document.getElementById(otherId).value);
  } else {
    x = snakeCaseWords(document.getElementById(otherId).value);
    y = snakeCaseWords(event.target.value);
  }

  const changeElement = document.getElementById(changeId);
  const mm = table.get(x, y);
  const prev = {
    min: parseInt(changeElement.min),
    max: parseInt(changeElement.max),
  };

  [ 'max', 'min' ].forEach((dim) => {
    if(mm && mm[dim] !== undefined) {
      changeElement[dim] = mm[dim];
    }
  });

  const val = clamp(parseInt(changeElement.value), prev, mm)
  if (val !== undefined) {
    changeElement.value = val;
  }
}

function clamp(currentValue, previous, next) {
  if(next === undefined){
    return undefined;

  // you've set the boundary, so when you go to the next value - keep it at the next's boundary
  } else if(currentValue === previous['min']) {
    return next['min'];
  } else if(currentValue === previous['max']) {
    return next['max'];

  // otherwise you could be up or down shifting to fit within the next's boundaries
  } else if(currentValue <= next['min']) {
    return next['min'];
  } else if(currentValue >= next['max']) {
    return next['max'];
  } else {
    return undefined;
  }
}

function addOptionForHandler(causeId, targetId) {
  const changeId = String(causeId || '');

  if(changeId.length == 0 || optionForHandlerCache[causeId].includes(targetId)) {
    // nothing to do. invalid causeId or we already have a handler between the 2
    return;
  }

  let causeElement = document.getElementById(causeId);
  
  if(targetId && causeElement) {
    // cache the fact that there's a new handler here
    optionForHandlerCache[causeId].push(targetId);

    causeElement.addEventListener('change', (event) => {
      toggleOptionsFor(event, targetId);
    });

    // fake an event to initialize
    toggleOptionsFor({ target: document.getElementById(causeId) }, targetId);
  }
};

/**
 *
 * @param {*} key minNumCoresForClusterAnnieOakley
 * @returns
 *
 *  {
 *    'subjectId': 'batch_connect_session_context_num_cores',
 *    'predicateId': 'batch_connect_session_context_cluster',
 *    'predicateValue': 'annie_oakley'
 *  }
 */
function parseMinMaxFor(key) {
  let k = undefined;
  let predicateId = undefined;
  let predicateValue = undefined;
  let subjectId = undefined;

  if(key.startsWith('min')) {
    k = key.replace(/^min_/,'');
  } else if(key.startsWith('max')) {
    k = key.replace(/^max_/, '')
  }

  //trying to parse maxNumCoresForClusterOwens
  const tokens = k.match(/^(\w+)_for_(\w+)$/);

  if(tokens == null) {
    // the key is likely just maxNumCores with no For clause
    subjectId = idFromToken(k);

  } else if(tokens.length == 3) {
    const subject = tokens[1];
    const predicateFull = tokens[2];
    subjectId = idFromToken(subject);

    const predicateTokens = predicateFull.split('_');
    if(predicateTokens && predicateTokens.length >= 2) {

      // if there are only 2 tokens then it's like 'ClusterOwens' which is easy
      if(predicateTokens.length == 2) {
        predicateId = idFromToken(predicateTokens[0]);
        predicateValue = predicateTokens[1];

      // else it's like NodeTypeFooBar, so it's a little more difficult
      } else {
        let tokenString = '';
        let done = false;
        predicateTokens.forEach((pt, idx) => {
          if (done) return;

          tokenString = `${tokenString}${pt}`
          let tokenId = idFromToken(tokenString);
          if(tokenId !== undefined) {
            done = true;
            predicateId = tokenId;
            predicateValue = predicateTokens.slice(idx+1).join('');
          }
        })
      }
    }
  }

  return {
    'subjectId': subjectId,
    'predicateId': predicateId,
    'predicateValue': snakeCaseWords(predicateValue),
  }
}

function minOrMax(key) {
  if(key.startsWith('min')){
    return 'min';
  } else if(key.startsWith('max')){
    return 'max';
  } else {
    return null;
  }
}

/**
 * Turn a snake cased token into a form element id
 *
 * @example
 * NodeType -> batch_connect_session_context_node_type
 *
 * @param {*} str
 * @returns
 */
function idFromToken(str) {
  elements = formTokens.map((token) => {
    let match = str.match(`^${token}{1}`);

    if (match && match.length >= 1) {
      let ele = snakeCaseWords(match[0]);
      return bcElement(ele);
    }
  }).filter((id) => {
    return id !== undefined;
  });

  if(elements.length == 0) {
    return undefined;
  }else if(elements.length == 1) {
    return elements[0];

  // you matched multiple things. For example you're searching for
  // ClusterFilesystem and matched against both 'Cluster' and 'ClusterFilesystem'.
  // The correrct element id ends with cluster_filesystem.
  } else if(elements.length > 1) {
    const snake_case_str = snakeCaseWords(str);
    return elements.filter((element) => {
      return element.endsWith(snake_case_str);
    })[0];
  }
}


/**
 * Extract the option for out of an option for directive.
 *
 * @example
 *  optionForClusterOakley -> Cluster
 *
 * @param {*} str
 * @returns - the option for string
 */
function optionForFromToken(str) {
  return formTokens.map((token) => {
    let match = str.match(`^option_for_${token}`);

    if (match && match.length >= 1) {
      return token;
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
 function toggleOptionsFor(_event, elementId) {
  const options = [...document.querySelectorAll(`#${elementId} option`)];
  let hideSelectedValue = undefined;

  options.forEach(option => {
    let data = getData(option);
    let hide = false;

    // even though an event occured - an option may be hidden based on the value of
    // something else entirely. We're going to hide this option if _any_ of the
    // option-for- directives apply.
    for (let key of Object.keys(data)) {
      let optionFor = optionForFromToken(key);
      let optionForId = idFromToken(key.replace(/^option_for_/,''));

      // it's some other directive type, so just keep going and/or not real
      if(!key.startsWith('option_for_') || optionForId === undefined) {
        continue;
      }

      let optionForValue = snakeCaseWords(document.getElementById(optionForId).value);

      hide = data[`option_for_${optionFor}_${optionForValue}`] === 'false';
      if (hide === true) {
        break;
      }
    };

    if(hide) {
      option.style.display = 'none';
      option.disabled = true;

      if(option.selected) {
        option.selected = false;
        hideSelectedValue = option.text();
      }
    } else {
      option.style.display = '';
      option.disabled = false;
    }
  });

  // now that we've hidden/shown everything, let's choose what should now
  // be the current selected value.
  // if you've hidden what _was_ selected.
  if(hideSelectedValue !== undefined) {
    let others = [...document.querySelectorAll(`#${elementId} option[value='${hideSelectedValue}']`)];
    let newSelectedOption = undefined;

    // You have hidden what _was_ selected, so try to find a duplicate option that is visible
    if(others.length > 1) {
      others.forEach(ele => {
        if(ele.style.display === '') {
          newSelectedOption = ele;
          return;
        }
      });
    }

    // no duplciates are visible, so just pick the first visible option
    if (newSelectedOption === undefined) {
      others = document.querySelectorAll(`#${elementId} option`);
      others.forEach(ele => {
        if(newSelectedOption === undefined && ele.style.display === '') {
          newSelectedOption = ele;
        }
      });
    }

    if (newSelectedOption !== undefined) {
      newSelectedOption.selected = true;
    }
  }

  // now that we're done, propogate this change to data-set or data-hide handlers
  document.getElementById(elementId).dispatchEvent((new Event('change', { bubbles: true })));
};

document.addEventListener('DOMContentLoaded', () => {
  makeChangeHandlers();
  attachPathSelectors();
  initializing = false;
});