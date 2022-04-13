"use strict";
(() => {
  // app/javascript/packs/batch_connect.js
  var bcPrefix = "batch_connect_session_context";
  var shortNameRex = new RegExp(`${bcPrefix}_([\\w\\-]+)`);
  var formTokens = [];
  var optionForHandlerCache = {};
  var minMaxHandlerCache = [];
  var setHandlerCache = [];
  var hideHandlerCache = {};
  var minMaxLookup = {};
  var setValueLookup = {};
  var hideLookup = {};
  var mcRex = /[-_]([a-z])|([_-][0-9])/g;
  function bcElement(name) {
    return `${bcPrefix}_${name.toLowerCase()}`;
  }
  function shortId(elementId) {
    const match = elementId.match(shortNameRex);
    if (match.length >= 1) {
      return match[1];
    } else {
      return "";
    }
    ;
  }
  function mountainCaseWords(str) {
    const lower = str.toLowerCase();
    const first = lower.charAt(0).toUpperCase();
    const rest = lower.slice(1).replace(mcRex, function(_all, letter, prefixedNumber) {
      return letter ? letter.toUpperCase() : prefixedNumber.replace("_", "-");
    });
    return `${first}${rest}`;
  }
  function snakeCaseWords(str) {
    if (str === void 0)
      return void 0;
    let snakeCase = "";
    let first = true;
    str.split("").forEach((c) => {
      if (first) {
        first = false;
        snakeCase += c.toLowerCase();
      } else if (c === "-" || c === "_") {
        snakeCase += "_";
      } else if (c == c.toUpperCase() && !(c >= "0" && c <= "9")) {
        snakeCase += `_${c.toLowerCase()}`;
      } else {
        snakeCase += c;
      }
    });
    return snakeCase;
  }
  function memorizeElements(elements) {
    elements.each((_i, ele) => {
      formTokens.push(mountainCaseWords(shortId(ele["id"])));
      optionForHandlerCache[ele["id"]] = [];
    });
  }
  function makeChangeHandlers() {
    const allElements = $(`[id^=${bcPrefix}]`);
    memorizeElements(allElements);
    allElements.each((_i, element) => {
      if (element["type"] == "select-one") {
        let optionSearch = `#${element["id"]} option`;
        let options = $(optionSearch);
        options.each((_i2, opt) => {
          let data = $(`${optionSearch}[value='${opt.value}']`).data();
          let keys = Object.keys(data);
          if (keys.length !== 0) {
            keys.forEach((key) => {
              if (key.startsWith("optionFor")) {
                let token = key.replace(/^optionFor/, "");
                addOptionForHandler(idFromToken(token), element["id"]);
              } else if (key.startsWith("max") || key.startsWith("min")) {
                addMinMaxForHandler(element["id"], opt.value, key, data[key]);
              } else if (key.startsWith("set")) {
                addSetHandler(element["id"], opt.value, key, data[key]);
              } else if (key.startsWith("hide")) {
                addHideHandler(element["id"], opt.value, key, data[key]);
              }
            });
          }
        });
      }
    });
  }
  function addHideHandler(optionId, option, key, configValue) {
    const changeId = idFromToken(key.replace(/^hide/, ""));
    if (hideLookup[optionId] === void 0)
      hideLookup[optionId] = new Table(changeId, "option_value");
    const table = hideLookup[optionId];
    table.put(changeId, option, configValue);
    if (hideHandlerCache[optionId] === void 0)
      hideHandlerCache[optionId] = [];
    if (!hideHandlerCache[optionId].includes(changeId)) {
      const changeElement = $(`#${optionId}`);
      changeElement.on("change", (event) => {
        updateVisibility(event, changeId);
      });
      hideHandlerCache[optionId].push(changeId);
    }
    updateVisibility({ target: document.querySelector(`#${optionId}`) }, changeId);
  }
  function addMinMaxForHandler(optionId, option, key, configValue) {
    optionId = String(optionId || "");
    const configObj = parseMinMaxFor(key);
    const id = configObj["subjectId"];
    if (id === void 0)
      return;
    const secondDimId = configObj["predicateId"];
    const secondDimValue = configObj["predicateValue"];
    if (minMaxLookup[id] === void 0)
      minMaxLookup[id] = new Table(optionId, secondDimId);
    const table = minMaxLookup[id];
    table.put(option, secondDimValue, { [minOrMax(key)]: configValue });
    let cacheKey = `${optionId}_${secondDimId}`;
    if (!minMaxHandlerCache.includes(cacheKey)) {
      const changeElement = $(`#${optionId}`);
      changeElement.on("change", (event) => {
        toggleMinMax(event, id, secondDimId);
      });
      minMaxHandlerCache.push(cacheKey);
    }
    cacheKey = `${secondDimId}_${optionId}`;
    if (secondDimId !== void 0 && !minMaxHandlerCache.includes(cacheKey)) {
      const secondEle = $(`#${secondDimId}`);
      secondEle.on("change", (event) => {
        toggleMinMax(event, id, optionId);
      });
      minMaxHandlerCache.push(cacheKey);
    }
  }
  function addSetHandler(optionId, option, key, configValue) {
    const k = key.replace(/^set/, "");
    const id = String(idFromToken(k));
    if (id === "undefined")
      return;
    let cacheKey = `${id}_${optionId}`;
    if (setValueLookup[cacheKey] === void 0)
      setValueLookup[cacheKey] = new Table(optionId, void 0);
    const table = setValueLookup[cacheKey];
    table.put(option, void 0, configValue);
    if (!setHandlerCache.includes(cacheKey)) {
      const changeElement = $(`#${optionId}`);
      changeElement.on("change", (event) => {
        setValue(event, id);
      });
      setHandlerCache.push(cacheKey);
    }
    setValue({ target: document.querySelector(`#${optionId}`) }, id);
  }
  function setValue(event, changeId) {
    const chosenVal = event.target.value;
    const cacheKey = `${changeId}_${event.target["id"]}`;
    const table = setValueLookup[cacheKey];
    if (table === void 0)
      return;
    const changeVal = table.get(chosenVal, void 0);
    if (changeVal !== void 0) {
      const innerElement = $(`#${changeId}`);
      innerElement.attr("value", changeVal);
      innerElement.val(changeVal);
    }
  }
  var Table = class {
    constructor(x, y) {
      this.x = x;
      this.xIdxLookup = {};
      this.y = y;
      this.yIdxLookup = {};
      this.table = y === void 0 ? [] : [[]];
    }
    put(x, y, value) {
      if (!x)
        return;
      x = snakeCaseWords(x);
      y = snakeCaseWords(y);
      if (this.xIdxLookup[x] === void 0)
        this.xIdxLookup[x] = Object.keys(this.xIdxLookup).length;
      if (y && this.yIdxLookup[y] === void 0)
        this.yIdxLookup[y] = Object.keys(this.yIdxLookup).length;
      const xIdx = this.xIdxLookup[x];
      const yIdx = this.yIdxLookup[y];
      if (this.table[xIdx] === void 0) {
        this.table[xIdx] = y === void 0 ? void 0 : [];
      }
      if (yIdx === void 0) {
        if (this.table[xIdx] === void 0) {
          this.table[xIdx] = value;
        } else {
          const prev = this.table[xIdx];
          const newer = value;
          this.table[xIdx] = Object.assign(prev, newer);
        }
      } else {
        if (this.table[xIdx][yIdx] === void 0) {
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
      if (this.table[xIdx] === void 0) {
        return void 0;
      } else if (y === void 0) {
        return this.table[xIdx];
      } else {
        return this.table[xIdx][yIdx];
      }
    }
  };
  function updateVisibility(event, changeId) {
    const val = event.target.value;
    const id = event.target["id"];
    const changeElement = $(`#${changeId}`).parent();
    if (changeElement.length <= 0)
      return;
    const hide = hideLookup[id].get(changeId, val);
    if (hide === void 0) {
      changeElement.show();
    } else if (hide === true) {
      changeElement.hide();
    }
  }
  function toggleMinMax(event, changeId, otherId) {
    let x = void 0, y = void 0;
    if (event.target["id"] == minMaxLookup[changeId].x) {
      x = snakeCaseWords(event.target.value);
      y = snakeCaseWords($(`#${otherId}`).val());
    } else {
      y = snakeCaseWords(event.target.value);
      x = snakeCaseWords($(`#${otherId}`).val());
    }
    const changeElement = $(`#${changeId}`);
    const mm = minMaxLookup[changeId].get(x, y);
    const prev = {
      min: changeElement.attr("min"),
      max: changeElement.attr("max")
    };
    ["max", "min"].forEach((dim) => {
      if (mm && mm[dim] !== void 0) {
        changeElement.attr(dim, mm[dim]);
      }
    });
    const val = clamp(changeElement.val(), prev, mm);
    if (val !== void 0) {
      changeElement.attr("value", val);
      changeElement.val(val);
    }
  }
  function clamp(currentValue, previous, next) {
    if (next === void 0) {
      return void 0;
    } else if (previous && previous["max"] && currentValue == previous["max"]) {
      return next["max"];
    } else if (previous && previous["min"] && currentValue == previous["min"]) {
      return next["min"];
    } else if (next["max"] && currentValue >= next["max"]) {
      return next["max"];
    } else if (next["min"] && currentValue <= next["min"]) {
      return next["min"];
    } else {
      return void 0;
    }
  }
  function addOptionForHandler(causeId, targetId) {
    const changeId = String(causeId || "");
    if (changeId.length == 0 || optionForHandlerCache[causeId].includes(targetId)) {
      return;
    }
    let causeElement = $(`#${causeId}`);
    if (targetId && causeElement) {
      optionForHandlerCache[causeId].push(targetId);
      causeElement.on("change", (event) => {
        toggleOptionsFor(event, targetId);
      });
      toggleOptionsFor({ target: document.querySelector(`#${causeId}`) }, targetId);
    }
  }
  function parseMinMaxFor(key) {
    let k = void 0;
    let predicateId = void 0;
    let predicateValue = void 0;
    let subjectId = void 0;
    if (key.startsWith("min")) {
      k = key.replace(/^min/, "");
    } else if (key.startsWith("max")) {
      k = key.replace(/^max/, "");
    }
    const tokens = k.match(/^(\w+)For(\w+)$/);
    if (tokens == null) {
      subjectId = idFromToken(k);
    } else if (tokens.length == 3) {
      const subject = tokens[1];
      const predicateFull = tokens[2];
      subjectId = idFromToken(subject);
      const predicateTokens = predicateFull.split(/(?=[A-Z])/);
      if (predicateTokens && predicateTokens.length >= 2) {
        if (predicateTokens.length == 2) {
          predicateId = idFromToken(predicateTokens[0]);
          predicateValue = predicateTokens[1];
        } else {
          let tokenString = "";
          let done = false;
          predicateTokens.forEach((pt, idx) => {
            if (done) {
              return;
            }
            tokenString = `${tokenString}${pt}`;
            let tokenId = idFromToken(tokenString);
            if (tokenId !== void 0) {
              done = true;
              predicateId = tokenId;
              predicateValue = predicateTokens.slice(idx + 1).join("");
            }
          });
        }
      }
    }
    return {
      "subjectId": subjectId,
      "predicateId": predicateId,
      "predicateValue": snakeCaseWords(predicateValue)
    };
  }
  function minOrMax(key) {
    if (key.startsWith("min")) {
      return "min";
    } else if (key.startsWith("max")) {
      return "max";
    } else {
      return null;
    }
  }
  function idFromToken(str) {
    return formTokens.map((token) => {
      let match = str.match(`^${token}{1}`);
      if (match && match.length >= 1) {
        let ele = snakeCaseWords(match[0]);
        return bcElement(ele);
      }
    }).filter((id) => {
      return id !== void 0;
    })[0];
  }
  function toggleOptionsFor(event, elementId) {
    const options = $(`#${elementId} option`);
    const optionTo = mountainCaseWords(event.target.value);
    const optionFor = optionForEvent(event.target);
    options.each(function(_i, option) {
      let optionElement = $(`#${elementId} option[value='${option.value}']`);
      let data = optionElement.data();
      let hide = data[`optionFor${optionFor}${optionTo}`] === false;
      if (hide) {
        optionElement.hide();
        if (optionElement.prop("selected")) {
          optionElement.prop("selected", false);
          if (optionElement.next()) {
            optionElement.next().prop("selected", true);
          }
        }
      } else {
        optionElement.show();
      }
    });
  }
  function optionForEvent(target) {
    let simpleName = shortId(target["id"]);
    return mountainCaseWords(simpleName);
  }
  jQuery(function() {
    makeChangeHandlers();
  });
})();
//# sourceMappingURL=batch_connect.js.map
