'use strict';

// these are initialized in makeChangeHandlers
var idPrefix = undefined;
var shortNameRex = undefined;

// @example ['NodeType', 'Cluster']
const formTokens = [];

// simple lookup table to indicate that the change handler is setup between two
// elements. I.e., {'cluster': [ 'node_type' ] } means that changes to cluster
// trigger changes to node_type
const optionForHandlerCache = {};
const exclusiveOptionForHandlerCache = {};


// simples array of string ids for elements that have a handler
const minMaxHandlerCache = [];
const setHandlerCache = [];
// hide handler cache is a map in the form '{ from: [hideThing1, hideThing2] }'
const hideHandlerCache = {};
const labelHandlerCache = {};

// Lookup tables for setting min & max values
// for different directives.
const minMaxLookup = {};
const setValueLookup = {};
const hideLookup = {};
const labelLookup = {};

// the regular expression for mountain casing
const mcRex = /[-_]([a-z])|([_-][0-9])|([\/])/g;

// whether we're still initializing or not
let initializing = true;

function idWithPrefix(name) {
  return `${idPrefix}_${name.toLowerCase()}`;
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
 * simplest case it just capitalizes.
 *
 * There is a special case where seperators are followed numbers. In this case
 * The seperator is kept as a hyphen because that's how jQuery expects it.
 *
 * @param      {string}  str     The word string to mountain case
 *
 * @example  given 'foo' this returns 'Foo'
 * @example  given 'foo-bar' this returns 'FooBar'
 * @example  given 'physics_1234' this returns 'Physics-1234'
 */
// Convert dashed to camelCase
function mountainCaseWords(str) {
  const lower = str.toLowerCase();
  const first = lower.charAt(0).toUpperCase();
  const rest = lower.slice(1).replace(mcRex, function(_all, letter, prefixedNumber, slash) {
    if(letter){
      return letter.toUpperCase();
    }else if(prefixedNumber){
      return prefixedNumber.replace('_','-');
    }else if(slash){
      return '_';
    }
  });

  return  `${first}${rest}`;
}

/**
 * Format passed string to snake_case. All characters become lowercase. Existing
 * underscores are unchanged and dashes become underscores. Underscores are added 
 * before locations where an uppercase character is followed by a lowercase character.
 *
 * @param      {string}  str     The word string to snake case
 *
 * @example  given 'MountainCase' this returns 'mountain_case'
 * @example  given 'camelCase' this returns 'camel_case'
 * @example  given 'OSC_JUPYTER' this returns 'osc_jupyter'
 */
function snakeCaseWords(str) {
  if(str === undefined) return undefined;

  // find all the captial case words and if none are found, we'll just bascially
  // return the same string.
  const rex = /([A-Z]{1}[a-z]*[0-9]*)|([^-_]+)/g;
  const words = str.match(rex);

  // filter out emtpy matches to avoid having a _ at the end.
  return words.filter(word => word != '').map(word => word.toLowerCase()).join('_');
}

/**
 *
 * @param {Array} elements
 */
function memorizeElements(elements) {
  elements.each((_i, ele) => {
    formTokens.push(mountainCaseWords(shortId(ele['id'])));
  });
};

function makeChangeHandlers(prefix){

  // initialize some global variables.
  idPrefix = prefix;
  shortNameRex = new RegExp(`${idPrefix}_([\\w\\-]+)`);

  const allElements = $(`[id^=${idPrefix}]`);
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
              if(key.startsWith('optionFor')) {
                let token = key.replace(/^optionFor/,'');
                addOptionForHandler(idFromToken(token), element['id']);
              } else if (key.startsWith('exclusiveOptionFor')) {
                let token = key.replace(/^exclusiveOptionFor/, '');
                addExclusiveOptionForHandler(idFromToken(token), element['id']);
              } else if(key.startsWith('max') || key.startsWith('min')) {
                addMinMaxForHandler(element['id'], opt.value, key, data[key]);
              } else if(key.startsWith('set')) {
                addSetHandler(element['id'], opt.value, key, data[key]);
              } else if(key.startsWith('hide')) {
                addHideHandler(element['id'], opt.value, key, data[key]);
              } else if(key.startsWith('label')) {
                addLabelHandler(element['id'], opt.value, key, data[key]);
              }
            });
          }
      });
    } else if(element['type'] == "checkbox") {
      let data = $(element).data();
      let keys = Object.keys(data);
      if(keys.length !== 0) {
        keys.forEach((key) => {
          if(key.startsWith('hide')) {
            let tokens = parseCheckedWhen(key);
            if(tokens !== undefined){
              addHideHandler(element['id'], tokens['value'], tokens['key'], data[key]);
            }
          }
        });
      }
    }
  });

  initializing = false;
};

function addHideHandler(optionId, option, key, configValue) {
  const changeId = idFromToken(key.replace(/^hide/,''));

  if(hideLookup[optionId] === undefined) hideLookup[optionId] = new Table(changeId, undefined);
  const table = hideLookup[optionId];
  table.put(changeId, option, configValue);

  if(hideHandlerCache[optionId] === undefined) hideHandlerCache[optionId] = [];

  if(!hideHandlerCache[optionId].includes(changeId)) {
    const changeElement = $(`#${optionId}`);

    changeElement.on('change', (event) => {
      updateVisibility(event, changeId);
    });

    hideHandlerCache[optionId].push(changeId);
  }

  updateVisibility({ target: document.querySelector(`#${optionId}`) }, changeId);
};

function newLabel(changeElement, key) {
  const selectedOptionLabelIndex = changeElement[0].selectedIndex;
  const selectedOptionLabel = changeElement[0].options[selectedOptionLabelIndex];
  return selectedOptionLabel.dataset[key];
};

function updateLabel(changeId, changeElement, key) {
  $(`label[for="${changeId}"]`)[0].innerHTML = newLabel(changeElement, key);
}

function addLabelHandler(optionId, option, key, configValue) {
  const changeId = idFromToken(key.replace(/^label/, ''));
  const changeElement = $(`#${optionId}`);

  if(labelLookup[optionId] === undefined) labelLookup[optionId] = new Table(changeId, undefined);
  const table = labelLookup[optionId];
  table.put(changeId, option, configValue);

  if(labelHandlerCache[optionId] === undefined) labelHandlerCache[optionId] = [];

  if(!labelHandlerCache[optionId].includes(changeId)) {
    changeElement.on('change', (event) => {
      updateLabel(changeId, changeElement, key);
    });
  };

  updateLabel(changeId, changeElement, key);
};

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
function addMinMaxForHandler(subjectId, option, key,  configValue) {
  subjectId = String(subjectId || '');
  configValue = parseInt(configValue);

  const configObj = parseMinMaxFor(key);
  const objectId = configObj['subjectId'];
  // this is the id of the target object we're setting the min/max for.
  // if it's undefined - there's nothing to do, it was likely configured wrong.
  if(objectId === undefined) return;

  const secondDimId = configObj['predicateId'];
  const secondDimValue = configObj['predicateValue'];

  // several subjects can try to change the object, so the table lookup key has to have both
  const lookupKey = `${subjectId}_${objectId}`;
  if(minMaxLookup[lookupKey] === undefined) minMaxLookup[lookupKey] = new Table(subjectId, secondDimId);
  const table = minMaxLookup[lookupKey];
  table.put(option, secondDimValue, {[minOrMax(key)] : configValue });

  let cacheKey = `${objectId}_${subjectId}_${secondDimId}`;
  if(!minMaxHandlerCache.includes(cacheKey)) {
    const changeElement = $(`#${subjectId}`);

    changeElement.on('change', (event) => {
      toggleMinMax(event, objectId, secondDimId);
    });

    minMaxHandlerCache.push(cacheKey);
  }

  cacheKey = `${objectId}_${secondDimId}_${subjectId}`;
  if(secondDimId !== undefined && !minMaxHandlerCache.includes(cacheKey)){
    const secondEle = $(`#${secondDimId}`);

    secondEle.on('change', (event) => {
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
  const k = key.replace(/^set/,'');
  const id = String(idFromToken(k));
  if(id === 'undefined') return;

  // id is account. optionId is classroom
  let cacheKey = `${id}_${optionId}`
  if(setValueLookup[cacheKey] === undefined) setValueLookup[cacheKey] = new Table(optionId, undefined);
  const table = setValueLookup[cacheKey];
  table.put(option, undefined, configValue);

  if(!setHandlerCache.includes(cacheKey)) {
    const changeElement = $(`#${optionId}`);

    changeElement.on('change', (event) => {
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
    const element = document.getElementById(changeId);
    if(element['type'] == 'checkbox') {
      setCheckboxValue(element, changeVal);
    } else {
      element.value = changeVal;
    }
  }
}

function setCheckboxValue(checkbox, value) {
  const positiveValue = checkbox.value;
  if(value == positiveValue) {
    checkbox.checked = true;
  } else {
    checkbox.checked = false;
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
    }else if(y === undefined){
      return this.table[xIdx];
    }else {
      return this.table[xIdx][yIdx];
    }
  }
}

/**
 * Update the visibility of `changeId` based on the
 * event and what's in the hideLookup table.
 */
function updateVisibility(event, changeId) {
  const val = valueFromEvent(event);
  const id = event.target['id'];
  let changeElement = undefined;
  
  $(`#${changeId}`).parents().each(function(_i, parent) {
    var classListValues = parent.classList.values();
    for (const val of classListValues) {
      // TODO: Using 'mb-3' here because 'form-group' was removed
      // from Bootstrap 5 and replaced with 'mb-3' - however, this
      // is a grid class which could (??) apply to parent elements
      // in unpredictable parts of the chain - test for & resolve
      if (val.match('mb-3')) {
        changeElement = $(parent);
      }
    }
  });

  if (changeElement === undefined || changeElement.length <= 0) return;

  // safe to access directly?
  const hide = hideLookup[id].get(changeId, val);
  if((hide === false) || (hide === undefined && !initializing)) {
    changeElement.show();
  }else if(hide === true) {
    changeElement.hide();
  }
}

// extract the value from the event. With checkbox being
// handleded specially.
function valueFromEvent(event) {
  if(event.target['type'] == 'checkbox') {
    return event.target.checked ? 'checked' : 'unchecked';
  } else {
    return event.target.value;
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
  if(event.target['id'] == table.x) {
    x = snakeCaseWords(event.target.value);
    y = snakeCaseWords($(`#${otherId}`).val());
  } else {
    y = snakeCaseWords(event.target.value);
    x = snakeCaseWords($(`#${otherId}`).val());
  }

  const changeElement = $(`#${changeId}`);
  const mm = table.get(x, y);
  const prev = {
    min: parseInt(changeElement.attr('min')),
    max: parseInt(changeElement.attr('max')),
  };

  [ 'max', 'min' ].forEach((dim) => {
    if(mm && mm[dim] !== undefined) {
      changeElement.attr(dim, mm[dim]);
    }
  });

  const val = clamp(parseInt(changeElement.val()), prev, mm)
  if (val !== undefined) {
    changeElement.attr('value', val);
    changeElement.val(val);
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

function sharedOptionForHandler(causeId, targetId, optionForType) {
  const changeId = String(causeId || '');
  let handlerCache = null;

  if (optionForType == 'optionFor') {
    if (optionForHandlerCache[causeId] == undefined) optionForHandlerCache[causeId] = [];
    handlerCache = optionForHandlerCache;
  } else if (optionForType == 'exclusiveOptionFor') {
    if (exclusiveOptionForHandlerCache[causeId] == undefined) exclusiveOptionForHandlerCache[causeId] = [];
    handlerCache = exclusiveOptionForHandlerCache;
  }
  
  if(changeId.length == 0 || handlerCache[causeId].includes(targetId)) {
    // nothing to do. invalid causeId or we already have a handler between the 2
    return;
  }

  let causeElement = $(`#${causeId}`);

  if(targetId && causeElement) {
    // cache the fact that there's a new handler here
    handlerCache[causeId].push(targetId);

    causeElement.on('change', (event) => {
      if (optionForType == 'exclusiveOptionFor') {
        toggleExclusiveOptionsFor(event, targetId);
      } else if (optionForType == 'optionFor') {
        toggleOptionsFor(event, targetId);
      }
    });

    // fake an event to initialize
    if (optionForType == 'exclusiveOptionFor') {
      toggleExclusiveOptionsFor({ target: document.querySelector(`#${causeId}`) }, targetId);
    } else if (optionForType == 'optionFor') {
      toggleOptionsFor({ target: document.querySelector(`#${causeId}`) }, targetId);
    }
  }
}

function addOptionForHandler(causeId, targetId) {
  sharedOptionForHandler(causeId, targetId, 'optionFor');
};

function addExclusiveOptionForHandler(causeId, targetId) {
  sharedOptionForHandler(causeId, targetId, 'exclusiveOptionFor');
};

function parseCheckedWhen(key) {
  const tokens = key.match(/^hide(\w+)When(\w+)$/);

  if(tokens !== undefined && tokens.length && tokens.length == 3) {
    return {
      'key': tokens[1],
      'value': tokens[2].toLowerCase() == 'checked' ? 'checked' : 'unchecked'
    };
  } else {
    return undefined;
  }
}

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
    k = key.replace(/^min/,'');
  } else if(key.startsWith('max')) {
    k = key.replace(/^max/, '')
  }

  //trying to parse maxNumCoresForClusterOwens
  const tokens = k.match(/^(\w+)For(\w+)$/);

  if(tokens == null) {
    // the key is likely just maxNumCores with no For clause
    subjectId = idFromToken(k);

  } else if(tokens.length == 3) {
    const subject = tokens[1];
    const predicateFull = tokens[2];
    subjectId = idFromToken(subject);

    const predicateTokens = predicateFull.split(/(?=[A-Z])/);
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
          if(done) { return; }

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
 * Turn a MountainCase token into a form element id
 *
 * @example
 *  NodeType -> batch_connect_session_context_node_type
 *
 * @param {*} str
 * @returns
 */
function idFromToken(str) {
  elements = formTokens.map((token) => {
    let match = str.match(`^${token}{1}`);

    if (match && match.length >= 1) {
      let ele = snakeCaseWords(match[0]);
      return idWithPrefix(ele);
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
 *  exclusiveOptionForClusterOakley -> Cluster
 *
 * @param {*} str
 * @returns - the option for string
 */
function sharedOptionForFromToken(str, optionForType) {  
  return formTokens.map((token) => {
    let match = str.match(`^${optionForType}${token}`);

    if (match && match.length >= 1) {
      return token;
    }
  }).filter((id) => {
    return id !== undefined;
  })[0];
}

function optionForFromToken(str) {
  return sharedOptionForFromToken(str, 'optionFor');
}

function exclusiveOptionForFromToken(str) {
  return sharedOptionForFromToken(str, 'exclusiveOptionFor');
}

function sharedToggleOptionsFor(_event, elementId, contextStr) {
  const options = [...document.querySelectorAll(`#${elementId} option`)];
  let hideSelectedValue = undefined;

  options.forEach(option => {
    let hide = false;

    // even though an event occured - an option may be hidden based on the value of
    // something else entirely. We're going to hide this option if _any_ of the
    // option-for- directives apply.
    for (let key of Object.keys(option.dataset)) {
      let optionFor = '';

      if (contextStr == 'optionFor') {
        optionFor = optionForFromToken(key);
      } else if (contextStr == 'exclusiveOptionFor') {
        optionFor = exclusiveOptionForFromToken(key);
      }
      let optionForId = idFromToken(key.replace(new RegExp(`^${contextStr}`),''));

      // it's some other directive type, so just keep going and/or not real
      if(!key.startsWith(contextStr) || optionForId === undefined) {
        continue;
      }

      let optionForValue = mountainCaseWords(document.getElementById(optionForId).value);
      // handle special case where the very first token here is a number.
      // browsers expect a prefix of hyphens as if it's the next token.
      if (optionForValue.match(/^\d/)) {
        optionForValue = `-${optionForValue}`;
      }

      if (contextStr == 'optionFor') {
        hide = option.dataset[`optionFor${optionFor}${optionForValue}`] === 'false';
      } else if (contextStr == 'exclusiveOptionFor') {
        hide = !(option.dataset[`exclusiveOptionFor${optionFor}${optionForValue}`] === 'true')
      }

      if (hide) {
        break;
      }
    };

    if(hide) {
      if(option.selected) {
        option.selected = false;
        hideSelectedValue = option.textContent;
      }

      option.style.display = 'none';
      option.disabled = true;
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
}

function toggleOptionsFor(_event, elementId) {
  sharedToggleOptionsFor(_event, elementId, 'optionFor');
}

function toggleExclusiveOptionsFor(_event, elementId) {
  sharedToggleOptionsFor(_event, elementId, 'exclusiveOptionFor');
};

export {
  makeChangeHandlers
}
