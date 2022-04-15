'use strict';

const bcPrefix = 'batch_connect_session_context';
const shortNameRex = new RegExp(`${bcPrefix}_([\\w\\-]+)`);
const tokenRex = /([A-Z][a-z]+){1}([\w\-]+)/;

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

// the regular expression for mountain casing
const mcRex = /[-_]([a-z])|([_-][0-9])/g;

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
  const rest = lower.slice(1).replace(mcRex, function(_all, letter, prefixedNumber) {
    return letter ? letter.toUpperCase() : prefixedNumber.replace('_','-');
  });

  return  `${first}${rest}`;
}

function snakeCaseWords(str) {
  if(str === undefined) return undefined;

  let snakeCase = "";
  let first = true;

  str.split('').forEach((c) => {
    if (first) {
      first = false;
      snakeCase += c.toLowerCase();
    } else if(c === '-' || c === '_') {
      snakeCase += '_';
    } else if(c == c.toUpperCase() && !(c >= '0' && c <= '9')) {
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
    formTokens.push(mountainCaseWords(shortId(ele['id'])));
    optionForHandlerCache[ele['id']] = [];
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
              if(key.startsWith('optionFor')) {
                let token = key.replace(/^optionFor/,'');
                addOptionForHandler(idFromToken(token), element['id']);
              } else if(key.startsWith('max') || key.startsWith('min')) {
                addMinMaxForHandler(element['id'], opt.value, key, data[key]);
              } else if(key.startsWith('set')) {
                addSetHandler(element['id'], opt.value, key, data[key]);
              } else if(key.startsWith('hide')) {
                addHideHandler(element['id'], opt.value, key, data[key]);
              }
            });
          }
      });
    }
  });
};

function addHideHandler(optionId, option, key,  configValue) {
  const changeId = idFromToken(key.replace(/^hide/,''));

  if(hideLookup[optionId] === undefined) hideLookup[optionId] = new Table(changeId, 'option_value');
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
}

/**
 *
 * @param {*} optionId batch_connect_session_context_node_type
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
function addMinMaxForHandler(optionId, option, key,  configValue) {
  optionId = String(optionId || '');

  const configObj = parseMinMaxFor(key);
  const id = configObj['subjectId'];
  // this is the id of the target object we're setting the min/max for.
  // if it's undefined - there's nothing to do, it was likely configured wrong.
  if(id === undefined) return;

  const secondDimId = configObj['predicateId'];
  const secondDimValue = configObj['predicateValue'];

  if(minMaxLookup[id] === undefined) minMaxLookup[id] = new Table(optionId, secondDimId);
  const table = minMaxLookup[id];
  table.put(option, secondDimValue, {[minOrMax(key)] : configValue });

  let cacheKey = `${optionId}_${secondDimId}`;
  if(!minMaxHandlerCache.includes(cacheKey)) {
    const changeElement = $(`#${optionId}`);

    changeElement.on('change', (event) => {
      toggleMinMax(event, id, secondDimId);
    });

    minMaxHandlerCache.push(cacheKey);
  }

  cacheKey = `${secondDimId}_${optionId}`;
  if(secondDimId !== undefined && !minMaxHandlerCache.includes(cacheKey)){
    const secondEle = $(`#${secondDimId}`);

    secondEle.on('change', (event) => {
      toggleMinMax(event, id, optionId);
    });

    minMaxHandlerCache.push(cacheKey);
  }

  toggleMinMax({ target: document.querySelector(`#${optionId}`) }, id, secondDimId);
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
function addSetHandler(optionId, option, key,  configValue) {
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
    const innerElement = $(`#${changeId}`);
    innerElement.attr('value', changeVal);
    innerElement.val(changeVal);
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
        this.table[xIdx] = Object.assign(prev, newer);
      }
    } else {
      if(this.table[xIdx][yIdx] === undefined){
        this.table[xIdx][yIdx] = value;
      } else {
        const prev = this.table[xIdx][yIdx];
        const newer = value;
        this.table[xIdx][yIdx] = Object.assign(prev, newer);
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
  const val = event.target.value;
  const id = event.target['id'];
  const changeElement = $(`#${changeId}`).parent();

  if (changeElement.length <= 0) return;

  // safe to access directly?
  const hide = hideLookup[id].get(changeId, val);
  if(hide === undefined) {
    changeElement.show();
  }else if(hide === true) {
    changeElement.hide();
  }
}

/**
 * Update the min & max values of `changeId` based on the
 * event, the `otherId` and the settings in minMaxLookup table.
 */
function toggleMinMax(event, changeId, otherId) {
  let x = undefined, y = undefined;

  // in the example of cluster & node_type, either element can trigger a change
  // so let's figure out the axis' based on the change element's id.
  if(event.target['id'] == minMaxLookup[changeId].x) {
    x = snakeCaseWords(event.target.value);
    y = snakeCaseWords($(`#${otherId}`).val());
  } else {
    y = snakeCaseWords(event.target.value);
    x = snakeCaseWords($(`#${otherId}`).val());
  }

  const changeElement = $(`#${changeId}`);
  const mm = minMaxLookup[changeId].get(x, y);
  const prev = {
    min: changeElement.attr('min'),
    max: changeElement.attr('max'),
  };

  [ 'max', 'min' ].forEach((dim) => {
    if(mm && mm[dim] !== undefined) {
      changeElement.attr(dim, mm[dim]);
    }
  });

  const val = clamp(changeElement.val(), prev, mm)
  if (val !== undefined) {
    changeElement.attr('value', val);
    changeElement.val(val);
  }
}

function clamp(currentValue, previous, next) {
  if(next === undefined){
    return undefined;

  // you've set the boundary, so when you go to the next value - keep it at the next's boundary
  } else if(previous && previous['max'] && currentValue == previous['max']) {
    return next['max'];
  } else if(previous && previous['min'] && currentValue == previous['min']) {
    return next['min'];

  // otherwise you could be up or down shifting to fit within the next's boundaries
  } else if(next['max'] && currentValue >= next['max']) {
    return next['max'];
  } else if(next['min'] && currentValue <= next['min']) {
    return next['min'];
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

  let causeElement = $(`#${causeId}`);

  if(targetId && causeElement) {
    // cache the fact that there's a new handler here
    optionForHandlerCache[causeId].push(targetId);

    causeElement.on('change', (event) => {
      toggleOptionsFor(event, targetId);
    });

    // fake an event to initialize
    toggleOptionsFor({ target: document.querySelector(`#${causeId}`) }, targetId);
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
  return formTokens.map((token) => {
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
