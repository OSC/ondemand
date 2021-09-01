

const bcPrefix = 'batch_connect_session_context';

function bcElement(name) {
  return `${bcPrefix}_${name.toLowerCase()}`;
};


const bcItemRex = new RegExp(`${bcPrefix}_([\\w\\-]+)`);
// const bcItemRex = /optionFor([A-Z][a-z]+){1}([\w]+)/;


// here the simple name for 'batch_connect_session_context_cluster'
// is just 'cluster'.
function idToSimpleName(elementId) {
  match = elementId.match(bcItemRex);
  console.log(`match is ${match}`);

  if (match.length >= 1) {
    return match[1];
  } else {
    return '';
  }
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
  var camelCase = "";
  var capitalize = true;

  str.split('').forEach((c) => {
    if (capitalize) {
      camelCase += c.toUpperCase();
      capitalize = false;
    } else if(c == '-') {
      capitalize = true;
    } else {
      camelCase += c;
    }
  });

  return camelCase;
}

function makeChangeHandlers(){
  allElements = $(`[id^=${bcPrefix}]`);

  allElements.each((_i, element) => {
    if (element['type'] == "select-one"){
      optionSearch = `#${element['id']} option`;
      options = $(optionSearch);
      options.each((_i, opt) => {
          // the variable 'opt' is just a data structure, not a jQuery result. 
          // it has no attr, data, show or hide methods so we have to query
          // for it again
          data = $(`${optionSearch}[value='${opt.value}']`).data();
          keys = Object.keys(data);
          if(keys.length !== 0) {
            keys.forEach((key) => {
              tokens = optionTokens(key);
              if(tokens.length >= 3) {
                console.log(`looking for #${bcElement(tokens[1])}`);
                console.log(tokens);
                addChangeHandler(bcElement(tokens[1]), element['id']);
              }
            });
          }
      });
    }
  });
};

function addChangeHandler(cause, effect) {
  console.log(`adding change handler for ${cause} and ${effect}`);
  causeElement = $(`#${cause}`);
  console.log(`adding change handler to #${cause}`);
  // TODO: fails if you can't find the cause 
  causeElement.on('change', (event) => {
    toggleOptionsFor(event, effect);
  });

  console.log(`looking to target #${cause}`);
  //trigger a face change to initialze the effect
  toggleOptionsFor(
    { target: document.querySelector(`#${cause}`) },
    effect
  );
};

const tokenRex = /optionFor([A-Z][a-z]+){1}([\w\-]+)/;

/**
 @example

  optionForClusterFoo -> 
    [0] optionForClusterFoo
    [1] Cluster
    [2] Foo
 
  @param {string} data - the string to tokenize

  function is small, kept for the docs.
 */
function optionTokens(data) {
  return data.match(tokenRex);
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

  console.log(`changing options for ${optionFor}`);

  options.each(function(_i, option) {
    // the variable 'option' is just a data structure. it has no attr, data, show
    // or hide methods so we have to query for it again
    let optionElement = $(`#${elementId} option[value='${option.value}']`);
    console.log(`data: ${optionElement.data()}`)
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

function optionForEvent(target){
  simpleName = idToSimpleName(target['id']);
  return mountainCaseWords(simpleName);
};

jQuery(function(){
  makeChangeHandlers();
});
