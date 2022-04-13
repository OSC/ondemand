"use strict";
(() => {
  var __create = Object.create;
  var __defProp = Object.defineProperty;
  var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
  var __getOwnPropNames = Object.getOwnPropertyNames;
  var __getProtoOf = Object.getPrototypeOf;
  var __hasOwnProp = Object.prototype.hasOwnProperty;
  var __commonJS = (cb, mod) => function __require() {
    return mod || (0, cb[__getOwnPropNames(cb)[0]])((mod = { exports: {} }).exports, mod), mod.exports;
  };
  var __copyProps = (to, from, except, desc) => {
    if (from && typeof from === "object" || typeof from === "function") {
      for (let key of __getOwnPropNames(from))
        if (!__hasOwnProp.call(to, key) && key !== except)
          __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
    }
    return to;
  };
  var __toESM = (mod, isNodeMode, target) => (target = mod != null ? __create(__getProtoOf(mod)) : {}, __copyProps(isNodeMode || !mod || !mod.__esModule ? __defProp(target, "default", { value: mod, enumerable: true }) : target, mod));

  // node_modules/oboe/dist/oboe-browser.js
  var require_oboe_browser = __commonJS({
    "node_modules/oboe/dist/oboe-browser.js"(exports, module) {
      (function webpackUniversalModuleDefinition(root, factory) {
        if (typeof exports === "object" && typeof module === "object")
          module.exports = factory();
        else if (typeof define === "function" && define.amd)
          define("oboe", [], factory);
        else if (typeof exports === "object")
          exports["oboe"] = factory();
        else
          root["oboe"] = factory();
      })(typeof self !== "undefined" ? self : exports, function() {
        return function(modules) {
          var installedModules = {};
          function __webpack_require__(moduleId) {
            if (installedModules[moduleId]) {
              return installedModules[moduleId].exports;
            }
            var module2 = installedModules[moduleId] = {
              i: moduleId,
              l: false,
              exports: {}
            };
            modules[moduleId].call(module2.exports, module2, module2.exports, __webpack_require__);
            module2.l = true;
            return module2.exports;
          }
          __webpack_require__.m = modules;
          __webpack_require__.c = installedModules;
          __webpack_require__.d = function(exports2, name, getter) {
            if (!__webpack_require__.o(exports2, name)) {
              Object.defineProperty(exports2, name, {
                configurable: false,
                enumerable: true,
                get: getter
              });
            }
          };
          __webpack_require__.n = function(module2) {
            var getter = module2 && module2.__esModule ? function getDefault() {
              return module2["default"];
            } : function getModuleExports() {
              return module2;
            };
            __webpack_require__.d(getter, "a", getter);
            return getter;
          };
          __webpack_require__.o = function(object, property) {
            return Object.prototype.hasOwnProperty.call(object, property);
          };
          __webpack_require__.p = "";
          return __webpack_require__(__webpack_require__.s = 7);
        }([
          function(module2, __webpack_exports__, __webpack_require__) {
            "use strict";
            __webpack_require__.d(__webpack_exports__, "j", function() {
              return partialComplete;
            });
            __webpack_require__.d(__webpack_exports__, "d", function() {
              return compose2;
            });
            __webpack_require__.d(__webpack_exports__, "c", function() {
              return attr;
            });
            __webpack_require__.d(__webpack_exports__, "h", function() {
              return lazyUnion;
            });
            __webpack_require__.d(__webpack_exports__, "b", function() {
              return apply;
            });
            __webpack_require__.d(__webpack_exports__, "k", function() {
              return varArgs;
            });
            __webpack_require__.d(__webpack_exports__, "e", function() {
              return flip;
            });
            __webpack_require__.d(__webpack_exports__, "g", function() {
              return lazyIntersection;
            });
            __webpack_require__.d(__webpack_exports__, "i", function() {
              return noop;
            });
            __webpack_require__.d(__webpack_exports__, "a", function() {
              return always;
            });
            __webpack_require__.d(__webpack_exports__, "f", function() {
              return functor;
            });
            var __WEBPACK_IMPORTED_MODULE_0__lists__ = __webpack_require__(1);
            var partialComplete = varArgs(function(fn, args) {
              var numBoundArgs = args.length;
              return varArgs(function(callArgs) {
                for (var i = 0; i < callArgs.length; i++) {
                  args[numBoundArgs + i] = callArgs[i];
                }
                args.length = numBoundArgs + callArgs.length;
                return fn.apply(this, args);
              });
            });
            var compose = varArgs(function(fns) {
              var fnsList = Object(__WEBPACK_IMPORTED_MODULE_0__lists__["c"])(fns);
              function next(params, curFn) {
                return [apply(params, curFn)];
              }
              return varArgs(function(startParams) {
                return Object(__WEBPACK_IMPORTED_MODULE_0__lists__["f"])(next, startParams, fnsList)[0];
              });
            });
            function compose2(f1, f2) {
              return function() {
                return f1.call(this, f2.apply(this, arguments));
              };
            }
            function attr(key) {
              return function(o) {
                return o[key];
              };
            }
            var lazyUnion = varArgs(function(fns) {
              return varArgs(function(params) {
                var maybeValue;
                for (var i = 0; i < attr("length")(fns); i++) {
                  maybeValue = apply(params, fns[i]);
                  if (maybeValue) {
                    return maybeValue;
                  }
                }
              });
            });
            function apply(args, fn) {
              return fn.apply(void 0, args);
            }
            function varArgs(fn) {
              var numberOfFixedArguments = fn.length - 1;
              var slice = Array.prototype.slice;
              if (numberOfFixedArguments === 0) {
                return function() {
                  return fn.call(this, slice.call(arguments));
                };
              } else if (numberOfFixedArguments === 1) {
                return function() {
                  return fn.call(this, arguments[0], slice.call(arguments, 1));
                };
              }
              var argsHolder = Array(fn.length);
              return function() {
                for (var i = 0; i < numberOfFixedArguments; i++) {
                  argsHolder[i] = arguments[i];
                }
                argsHolder[numberOfFixedArguments] = slice.call(arguments, numberOfFixedArguments);
                return fn.apply(this, argsHolder);
              };
            }
            function flip(fn) {
              return function(a, b) {
                return fn(b, a);
              };
            }
            function lazyIntersection(fn1, fn2) {
              return function(param) {
                return fn1(param) && fn2(param);
              };
            }
            function noop() {
            }
            function always() {
              return true;
            }
            function functor(val) {
              return function() {
                return val;
              };
            }
          },
          function(module2, __webpack_exports__, __webpack_require__) {
            "use strict";
            __webpack_require__.d(__webpack_exports__, "d", function() {
              return cons;
            });
            __webpack_require__.d(__webpack_exports__, "g", function() {
              return head;
            });
            __webpack_require__.d(__webpack_exports__, "l", function() {
              return tail;
            });
            __webpack_require__.d(__webpack_exports__, "c", function() {
              return arrayAsList;
            });
            __webpack_require__.d(__webpack_exports__, "h", function() {
              return list;
            });
            __webpack_require__.d(__webpack_exports__, "i", function() {
              return listAsArray;
            });
            __webpack_require__.d(__webpack_exports__, "j", function() {
              return map;
            });
            __webpack_require__.d(__webpack_exports__, "f", function() {
              return foldR;
            });
            __webpack_require__.d(__webpack_exports__, "m", function() {
              return without;
            });
            __webpack_require__.d(__webpack_exports__, "a", function() {
              return all;
            });
            __webpack_require__.d(__webpack_exports__, "b", function() {
              return applyEach;
            });
            __webpack_require__.d(__webpack_exports__, "k", function() {
              return reverseList;
            });
            __webpack_require__.d(__webpack_exports__, "e", function() {
              return first;
            });
            var __WEBPACK_IMPORTED_MODULE_0__functional__ = __webpack_require__(0);
            function cons(x, xs) {
              return [x, xs];
            }
            var emptyList = null;
            var head = Object(__WEBPACK_IMPORTED_MODULE_0__functional__["c"])(0);
            var tail = Object(__WEBPACK_IMPORTED_MODULE_0__functional__["c"])(1);
            function arrayAsList(inputArray) {
              return reverseList(inputArray.reduce(Object(__WEBPACK_IMPORTED_MODULE_0__functional__["e"])(cons), emptyList));
            }
            var list = Object(__WEBPACK_IMPORTED_MODULE_0__functional__["k"])(arrayAsList);
            function listAsArray(list2) {
              return foldR(function(arraySoFar, listItem) {
                arraySoFar.unshift(listItem);
                return arraySoFar;
              }, [], list2);
            }
            function map(fn, list2) {
              return list2 ? cons(fn(head(list2)), map(fn, tail(list2))) : emptyList;
            }
            function foldR(fn, startValue, list2) {
              return list2 ? fn(foldR(fn, startValue, tail(list2)), head(list2)) : startValue;
            }
            function foldR1(fn, list2) {
              return tail(list2) ? fn(foldR1(fn, tail(list2)), head(list2)) : head(list2);
            }
            function without(list2, test, removedFn) {
              return withoutInner(list2, removedFn || __WEBPACK_IMPORTED_MODULE_0__functional__["i"]);
              function withoutInner(subList, removedFn2) {
                return subList ? test(head(subList)) ? (removedFn2(head(subList)), tail(subList)) : cons(head(subList), withoutInner(tail(subList), removedFn2)) : emptyList;
              }
            }
            function all(fn, list2) {
              return !list2 || fn(head(list2)) && all(fn, tail(list2));
            }
            function applyEach(fnList, args) {
              if (fnList) {
                head(fnList).apply(null, args);
                applyEach(tail(fnList), args);
              }
            }
            function reverseList(list2) {
              function reverseInner(list3, reversedAlready) {
                if (!list3) {
                  return reversedAlready;
                }
                return reverseInner(tail(list3), cons(head(list3), reversedAlready));
              }
              return reverseInner(list2, emptyList);
            }
            function first(test, list2) {
              return list2 && (test(head(list2)) ? head(list2) : first(test, tail(list2)));
            }
          },
          function(module2, __webpack_exports__, __webpack_require__) {
            "use strict";
            __webpack_require__.d(__webpack_exports__, "c", function() {
              return isOfType;
            });
            __webpack_require__.d(__webpack_exports__, "e", function() {
              return len;
            });
            __webpack_require__.d(__webpack_exports__, "d", function() {
              return isString;
            });
            __webpack_require__.d(__webpack_exports__, "a", function() {
              return defined;
            });
            __webpack_require__.d(__webpack_exports__, "b", function() {
              return hasAllProperties;
            });
            var __WEBPACK_IMPORTED_MODULE_0__lists__ = __webpack_require__(1);
            var __WEBPACK_IMPORTED_MODULE_1__functional__ = __webpack_require__(0);
            function isOfType(T, maybeSomething) {
              return maybeSomething && maybeSomething.constructor === T;
            }
            var len = Object(__WEBPACK_IMPORTED_MODULE_1__functional__["c"])("length");
            var isString = Object(__WEBPACK_IMPORTED_MODULE_1__functional__["j"])(isOfType, String);
            function defined(value) {
              return value !== void 0;
            }
            function hasAllProperties(fieldList, o) {
              return o instanceof Object && Object(__WEBPACK_IMPORTED_MODULE_0__lists__["a"])(function(field) {
                return field in o;
              }, fieldList);
            }
          },
          function(module2, __webpack_exports__, __webpack_require__) {
            "use strict";
            __webpack_require__.d(__webpack_exports__, "f", function() {
              return NODE_OPENED;
            });
            __webpack_require__.d(__webpack_exports__, "d", function() {
              return NODE_CLOSED;
            });
            __webpack_require__.d(__webpack_exports__, "g", function() {
              return NODE_SWAP;
            });
            __webpack_require__.d(__webpack_exports__, "e", function() {
              return NODE_DROP;
            });
            __webpack_require__.d(__webpack_exports__, "b", function() {
              return FAIL_EVENT;
            });
            __webpack_require__.d(__webpack_exports__, "h", function() {
              return ROOT_NODE_FOUND;
            });
            __webpack_require__.d(__webpack_exports__, "i", function() {
              return ROOT_PATH_FOUND;
            });
            __webpack_require__.d(__webpack_exports__, "c", function() {
              return HTTP_START;
            });
            __webpack_require__.d(__webpack_exports__, "m", function() {
              return STREAM_DATA;
            });
            __webpack_require__.d(__webpack_exports__, "n", function() {
              return STREAM_END;
            });
            __webpack_require__.d(__webpack_exports__, "a", function() {
              return ABORTING;
            });
            __webpack_require__.d(__webpack_exports__, "j", function() {
              return SAX_KEY;
            });
            __webpack_require__.d(__webpack_exports__, "l", function() {
              return SAX_VALUE_OPEN;
            });
            __webpack_require__.d(__webpack_exports__, "k", function() {
              return SAX_VALUE_CLOSE;
            });
            __webpack_require__.d(__webpack_exports__, "o", function() {
              return errorReport;
            });
            var _S = 1;
            var NODE_OPENED = _S++;
            var NODE_CLOSED = _S++;
            var NODE_SWAP = _S++;
            var NODE_DROP = _S++;
            var FAIL_EVENT = "fail";
            var ROOT_NODE_FOUND = _S++;
            var ROOT_PATH_FOUND = _S++;
            var HTTP_START = "start";
            var STREAM_DATA = "data";
            var STREAM_END = "end";
            var ABORTING = _S++;
            var SAX_KEY = _S++;
            var SAX_VALUE_OPEN = _S++;
            var SAX_VALUE_CLOSE = _S++;
            function errorReport(statusCode, body, error) {
              try {
                var jsonBody = JSON.parse(body);
              } catch (e) {
              }
              return {
                statusCode,
                body,
                jsonBody,
                thrown: error
              };
            }
          },
          function(module2, __webpack_exports__, __webpack_require__) {
            "use strict";
            __webpack_require__.d(__webpack_exports__, "b", function() {
              return namedNode;
            });
            __webpack_require__.d(__webpack_exports__, "a", function() {
              return keyOf;
            });
            __webpack_require__.d(__webpack_exports__, "c", function() {
              return nodeOf;
            });
            var __WEBPACK_IMPORTED_MODULE_0__functional__ = __webpack_require__(0);
            function namedNode(key, node) {
              return { key, node };
            }
            var keyOf = Object(__WEBPACK_IMPORTED_MODULE_0__functional__["c"])("key");
            var nodeOf = Object(__WEBPACK_IMPORTED_MODULE_0__functional__["c"])("node");
          },
          function(module2, __webpack_exports__, __webpack_require__) {
            "use strict";
            __webpack_require__.d(__webpack_exports__, "a", function() {
              return oboe2;
            });
            var __WEBPACK_IMPORTED_MODULE_0__lists__ = __webpack_require__(1);
            var __WEBPACK_IMPORTED_MODULE_1__functional__ = __webpack_require__(0);
            var __WEBPACK_IMPORTED_MODULE_2__util__ = __webpack_require__(2);
            var __WEBPACK_IMPORTED_MODULE_3__defaults__ = __webpack_require__(8);
            var __WEBPACK_IMPORTED_MODULE_4__wire__ = __webpack_require__(9);
            function oboe2(arg1) {
              var nodeStreamMethodNames = Object(__WEBPACK_IMPORTED_MODULE_0__lists__["h"])("resume", "pause", "pipe");
              var isStream = Object(__WEBPACK_IMPORTED_MODULE_1__functional__["j"])(__WEBPACK_IMPORTED_MODULE_2__util__["b"], nodeStreamMethodNames);
              if (arg1) {
                if (isStream(arg1) || Object(__WEBPACK_IMPORTED_MODULE_2__util__["d"])(arg1)) {
                  return Object(__WEBPACK_IMPORTED_MODULE_3__defaults__["a"])(__WEBPACK_IMPORTED_MODULE_4__wire__["a"], arg1);
                } else {
                  return Object(__WEBPACK_IMPORTED_MODULE_3__defaults__["a"])(__WEBPACK_IMPORTED_MODULE_4__wire__["a"], arg1.url, arg1.method, arg1.body, arg1.headers, arg1.withCredentials, arg1.cached);
                }
              } else {
                return Object(__WEBPACK_IMPORTED_MODULE_4__wire__["a"])();
              }
            }
            oboe2.drop = function() {
              return oboe2.drop;
            };
          },
          function(module2, __webpack_exports__, __webpack_require__) {
            "use strict";
            __webpack_require__.d(__webpack_exports__, "b", function() {
              return incrementalContentBuilder;
            });
            __webpack_require__.d(__webpack_exports__, "a", function() {
              return ROOT_PATH;
            });
            var __WEBPACK_IMPORTED_MODULE_0__events__ = __webpack_require__(3);
            var __WEBPACK_IMPORTED_MODULE_1__ascent__ = __webpack_require__(4);
            var __WEBPACK_IMPORTED_MODULE_2__util__ = __webpack_require__(2);
            var __WEBPACK_IMPORTED_MODULE_3__lists__ = __webpack_require__(1);
            var ROOT_PATH = {};
            function incrementalContentBuilder(oboeBus) {
              var emitNodeOpened = oboeBus(__WEBPACK_IMPORTED_MODULE_0__events__["f"]).emit;
              var emitNodeClosed = oboeBus(__WEBPACK_IMPORTED_MODULE_0__events__["d"]).emit;
              var emitRootOpened = oboeBus(__WEBPACK_IMPORTED_MODULE_0__events__["i"]).emit;
              var emitRootClosed = oboeBus(__WEBPACK_IMPORTED_MODULE_0__events__["h"]).emit;
              function arrayIndicesAreKeys(possiblyInconsistentAscent, newDeepestNode) {
                var parentNode = Object(__WEBPACK_IMPORTED_MODULE_1__ascent__["c"])(Object(__WEBPACK_IMPORTED_MODULE_3__lists__["g"])(possiblyInconsistentAscent));
                return Object(__WEBPACK_IMPORTED_MODULE_2__util__["c"])(Array, parentNode) ? keyFound(possiblyInconsistentAscent, Object(__WEBPACK_IMPORTED_MODULE_2__util__["e"])(parentNode), newDeepestNode) : possiblyInconsistentAscent;
              }
              function nodeOpened(ascent, newDeepestNode) {
                if (!ascent) {
                  emitRootOpened(newDeepestNode);
                  return keyFound(ascent, ROOT_PATH, newDeepestNode);
                }
                var arrayConsistentAscent = arrayIndicesAreKeys(ascent, newDeepestNode);
                var ancestorBranches = Object(__WEBPACK_IMPORTED_MODULE_3__lists__["l"])(arrayConsistentAscent);
                var previouslyUnmappedName = Object(__WEBPACK_IMPORTED_MODULE_1__ascent__["a"])(Object(__WEBPACK_IMPORTED_MODULE_3__lists__["g"])(arrayConsistentAscent));
                appendBuiltContent(ancestorBranches, previouslyUnmappedName, newDeepestNode);
                return Object(__WEBPACK_IMPORTED_MODULE_3__lists__["d"])(Object(__WEBPACK_IMPORTED_MODULE_1__ascent__["b"])(previouslyUnmappedName, newDeepestNode), ancestorBranches);
              }
              function appendBuiltContent(ancestorBranches, key, node) {
                Object(__WEBPACK_IMPORTED_MODULE_1__ascent__["c"])(Object(__WEBPACK_IMPORTED_MODULE_3__lists__["g"])(ancestorBranches))[key] = node;
              }
              function keyFound(ascent, newDeepestName, maybeNewDeepestNode) {
                if (ascent) {
                  appendBuiltContent(ascent, newDeepestName, maybeNewDeepestNode);
                }
                var ascentWithNewPath = Object(__WEBPACK_IMPORTED_MODULE_3__lists__["d"])(Object(__WEBPACK_IMPORTED_MODULE_1__ascent__["b"])(newDeepestName, maybeNewDeepestNode), ascent);
                emitNodeOpened(ascentWithNewPath);
                return ascentWithNewPath;
              }
              function nodeClosed(ascent) {
                emitNodeClosed(ascent);
                return Object(__WEBPACK_IMPORTED_MODULE_3__lists__["l"])(ascent) || emitRootClosed(Object(__WEBPACK_IMPORTED_MODULE_1__ascent__["c"])(Object(__WEBPACK_IMPORTED_MODULE_3__lists__["g"])(ascent)));
              }
              var contentBuilderHandlers = {};
              contentBuilderHandlers[__WEBPACK_IMPORTED_MODULE_0__events__["l"]] = nodeOpened;
              contentBuilderHandlers[__WEBPACK_IMPORTED_MODULE_0__events__["k"]] = nodeClosed;
              contentBuilderHandlers[__WEBPACK_IMPORTED_MODULE_0__events__["j"]] = keyFound;
              return contentBuilderHandlers;
            }
          },
          function(module2, __webpack_exports__, __webpack_require__) {
            "use strict";
            Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
            var __WEBPACK_IMPORTED_MODULE_0__publicApi__ = __webpack_require__(5);
            __webpack_exports__["default"] = __WEBPACK_IMPORTED_MODULE_0__publicApi__["a"];
          },
          function(module2, __webpack_exports__, __webpack_require__) {
            "use strict";
            __webpack_require__.d(__webpack_exports__, "a", function() {
              return applyDefaults;
            });
            var __WEBPACK_IMPORTED_MODULE_0__util__ = __webpack_require__(2);
            function applyDefaults(passthrough, url, httpMethodName, body, headers, withCredentials, cached) {
              headers = headers ? JSON.parse(JSON.stringify(headers)) : {};
              if (body) {
                if (!Object(__WEBPACK_IMPORTED_MODULE_0__util__["d"])(body)) {
                  body = JSON.stringify(body);
                  headers["Content-Type"] = headers["Content-Type"] || "application/json";
                }
                headers["Content-Length"] = headers["Content-Length"] || body.length;
              } else {
                body = null;
              }
              function modifiedUrl(baseUrl, cached2) {
                if (cached2 === false) {
                  if (baseUrl.indexOf("?") === -1) {
                    baseUrl += "?";
                  } else {
                    baseUrl += "&";
                  }
                  baseUrl += "_=" + new Date().getTime();
                }
                return baseUrl;
              }
              return passthrough(httpMethodName || "GET", modifiedUrl(url, cached), body, headers, withCredentials || false);
            }
          },
          function(module2, __webpack_exports__, __webpack_require__) {
            "use strict";
            __webpack_require__.d(__webpack_exports__, "a", function() {
              return wire;
            });
            var __WEBPACK_IMPORTED_MODULE_0__pubSub__ = __webpack_require__(10);
            var __WEBPACK_IMPORTED_MODULE_1__ascentManager__ = __webpack_require__(12);
            var __WEBPACK_IMPORTED_MODULE_2__incrementalContentBuilder__ = __webpack_require__(6);
            var __WEBPACK_IMPORTED_MODULE_3__patternAdapter__ = __webpack_require__(13);
            var __WEBPACK_IMPORTED_MODULE_4__jsonPath__ = __webpack_require__(14);
            var __WEBPACK_IMPORTED_MODULE_5__instanceApi__ = __webpack_require__(16);
            var __WEBPACK_IMPORTED_MODULE_6__libs_clarinet__ = __webpack_require__(17);
            var __WEBPACK_IMPORTED_MODULE_7__streamingHttp_node__ = __webpack_require__(18);
            function wire(httpMethodName, contentSource, body, headers, withCredentials) {
              var oboeBus = Object(__WEBPACK_IMPORTED_MODULE_0__pubSub__["a"])();
              if (contentSource) {
                Object(__WEBPACK_IMPORTED_MODULE_7__streamingHttp_node__["b"])(oboeBus, Object(__WEBPACK_IMPORTED_MODULE_7__streamingHttp_node__["a"])(), httpMethodName, contentSource, body, headers, withCredentials);
              }
              Object(__WEBPACK_IMPORTED_MODULE_6__libs_clarinet__["a"])(oboeBus);
              Object(__WEBPACK_IMPORTED_MODULE_1__ascentManager__["a"])(oboeBus, Object(__WEBPACK_IMPORTED_MODULE_2__incrementalContentBuilder__["b"])(oboeBus));
              Object(__WEBPACK_IMPORTED_MODULE_3__patternAdapter__["a"])(oboeBus, __WEBPACK_IMPORTED_MODULE_4__jsonPath__["a"]);
              return Object(__WEBPACK_IMPORTED_MODULE_5__instanceApi__["a"])(oboeBus, contentSource);
            }
          },
          function(module2, __webpack_exports__, __webpack_require__) {
            "use strict";
            __webpack_require__.d(__webpack_exports__, "a", function() {
              return pubSub;
            });
            var __WEBPACK_IMPORTED_MODULE_0__singleEventPubSub__ = __webpack_require__(11);
            var __WEBPACK_IMPORTED_MODULE_1__functional__ = __webpack_require__(0);
            function pubSub() {
              var singles = {};
              var newListener = newSingle("newListener");
              var removeListener = newSingle("removeListener");
              function newSingle(eventName) {
                singles[eventName] = Object(__WEBPACK_IMPORTED_MODULE_0__singleEventPubSub__["a"])(eventName, newListener, removeListener);
                return singles[eventName];
              }
              function pubSubInstance(eventName) {
                return singles[eventName] || newSingle(eventName);
              }
              ["emit", "on", "un"].forEach(function(methodName) {
                pubSubInstance[methodName] = Object(__WEBPACK_IMPORTED_MODULE_1__functional__["k"])(function(eventName, parameters) {
                  Object(__WEBPACK_IMPORTED_MODULE_1__functional__["b"])(parameters, pubSubInstance(eventName)[methodName]);
                });
              });
              return pubSubInstance;
            }
          },
          function(module2, __webpack_exports__, __webpack_require__) {
            "use strict";
            __webpack_require__.d(__webpack_exports__, "a", function() {
              return singleEventPubSub;
            });
            var __WEBPACK_IMPORTED_MODULE_0__lists__ = __webpack_require__(1);
            var __WEBPACK_IMPORTED_MODULE_1__util__ = __webpack_require__(2);
            var __WEBPACK_IMPORTED_MODULE_2__functional__ = __webpack_require__(0);
            function singleEventPubSub(eventType, newListener, removeListener) {
              var listenerTupleList, listenerList;
              function hasId(id) {
                return function(tuple) {
                  return tuple.id === id;
                };
              }
              return {
                on: function(listener, listenerId) {
                  var tuple = {
                    listener,
                    id: listenerId || listener
                  };
                  if (newListener) {
                    newListener.emit(eventType, listener, tuple.id);
                  }
                  listenerTupleList = Object(__WEBPACK_IMPORTED_MODULE_0__lists__["d"])(tuple, listenerTupleList);
                  listenerList = Object(__WEBPACK_IMPORTED_MODULE_0__lists__["d"])(listener, listenerList);
                  return this;
                },
                emit: function() {
                  Object(__WEBPACK_IMPORTED_MODULE_0__lists__["b"])(listenerList, arguments);
                },
                un: function(listenerId) {
                  var removed;
                  listenerTupleList = Object(__WEBPACK_IMPORTED_MODULE_0__lists__["m"])(listenerTupleList, hasId(listenerId), function(tuple) {
                    removed = tuple;
                  });
                  if (removed) {
                    listenerList = Object(__WEBPACK_IMPORTED_MODULE_0__lists__["m"])(listenerList, function(listener) {
                      return listener === removed.listener;
                    });
                    if (removeListener) {
                      removeListener.emit(eventType, removed.listener, removed.id);
                    }
                  }
                },
                listeners: function() {
                  return listenerList;
                },
                hasListener: function(listenerId) {
                  var test = listenerId ? hasId(listenerId) : __WEBPACK_IMPORTED_MODULE_2__functional__["a"];
                  return Object(__WEBPACK_IMPORTED_MODULE_1__util__["a"])(Object(__WEBPACK_IMPORTED_MODULE_0__lists__["e"])(test, listenerTupleList));
                }
              };
            }
          },
          function(module2, __webpack_exports__, __webpack_require__) {
            "use strict";
            __webpack_require__.d(__webpack_exports__, "a", function() {
              return ascentManager;
            });
            var __WEBPACK_IMPORTED_MODULE_0__ascent__ = __webpack_require__(4);
            var __WEBPACK_IMPORTED_MODULE_1__events__ = __webpack_require__(3);
            var __WEBPACK_IMPORTED_MODULE_2__lists__ = __webpack_require__(1);
            function ascentManager(oboeBus, handlers) {
              "use strict";
              var listenerId = {};
              var ascent;
              function stateAfter(handler) {
                return function(param) {
                  ascent = handler(ascent, param);
                };
              }
              for (var eventName in handlers) {
                oboeBus(eventName).on(stateAfter(handlers[eventName]), listenerId);
              }
              oboeBus(__WEBPACK_IMPORTED_MODULE_1__events__["g"]).on(function(newNode) {
                var oldHead = Object(__WEBPACK_IMPORTED_MODULE_2__lists__["g"])(ascent);
                var key = Object(__WEBPACK_IMPORTED_MODULE_0__ascent__["a"])(oldHead);
                var ancestors = Object(__WEBPACK_IMPORTED_MODULE_2__lists__["l"])(ascent);
                var parentNode;
                if (ancestors) {
                  parentNode = Object(__WEBPACK_IMPORTED_MODULE_0__ascent__["c"])(Object(__WEBPACK_IMPORTED_MODULE_2__lists__["g"])(ancestors));
                  parentNode[key] = newNode;
                }
              });
              oboeBus(__WEBPACK_IMPORTED_MODULE_1__events__["e"]).on(function() {
                var oldHead = Object(__WEBPACK_IMPORTED_MODULE_2__lists__["g"])(ascent);
                var key = Object(__WEBPACK_IMPORTED_MODULE_0__ascent__["a"])(oldHead);
                var ancestors = Object(__WEBPACK_IMPORTED_MODULE_2__lists__["l"])(ascent);
                var parentNode;
                if (ancestors) {
                  parentNode = Object(__WEBPACK_IMPORTED_MODULE_0__ascent__["c"])(Object(__WEBPACK_IMPORTED_MODULE_2__lists__["g"])(ancestors));
                  delete parentNode[key];
                }
              });
              oboeBus(__WEBPACK_IMPORTED_MODULE_1__events__["a"]).on(function() {
                for (var eventName2 in handlers) {
                  oboeBus(eventName2).un(listenerId);
                }
              });
            }
          },
          function(module2, __webpack_exports__, __webpack_require__) {
            "use strict";
            __webpack_require__.d(__webpack_exports__, "a", function() {
              return patternAdapter;
            });
            var __WEBPACK_IMPORTED_MODULE_0__events__ = __webpack_require__(3);
            var __WEBPACK_IMPORTED_MODULE_1__lists__ = __webpack_require__(1);
            var __WEBPACK_IMPORTED_MODULE_2__ascent__ = __webpack_require__(4);
            function patternAdapter(oboeBus, jsonPathCompiler) {
              var predicateEventMap = {
                node: oboeBus(__WEBPACK_IMPORTED_MODULE_0__events__["d"]),
                path: oboeBus(__WEBPACK_IMPORTED_MODULE_0__events__["f"])
              };
              function emitMatchingNode(emitMatch, node, ascent) {
                var descent = Object(__WEBPACK_IMPORTED_MODULE_1__lists__["k"])(ascent);
                emitMatch(node, Object(__WEBPACK_IMPORTED_MODULE_1__lists__["i"])(Object(__WEBPACK_IMPORTED_MODULE_1__lists__["l"])(Object(__WEBPACK_IMPORTED_MODULE_1__lists__["j"])(__WEBPACK_IMPORTED_MODULE_2__ascent__["a"], descent))), Object(__WEBPACK_IMPORTED_MODULE_1__lists__["i"])(Object(__WEBPACK_IMPORTED_MODULE_1__lists__["j"])(__WEBPACK_IMPORTED_MODULE_2__ascent__["c"], descent)));
              }
              function addUnderlyingListener(fullEventName, predicateEvent, compiledJsonPath) {
                var emitMatch = oboeBus(fullEventName).emit;
                predicateEvent.on(function(ascent) {
                  var maybeMatchingMapping = compiledJsonPath(ascent);
                  if (maybeMatchingMapping !== false) {
                    emitMatchingNode(emitMatch, Object(__WEBPACK_IMPORTED_MODULE_2__ascent__["c"])(maybeMatchingMapping), ascent);
                  }
                }, fullEventName);
                oboeBus("removeListener").on(function(removedEventName) {
                  if (removedEventName === fullEventName) {
                    if (!oboeBus(removedEventName).listeners()) {
                      predicateEvent.un(fullEventName);
                    }
                  }
                });
              }
              oboeBus("newListener").on(function(fullEventName) {
                var match = /(node|path):(.*)/.exec(fullEventName);
                if (match) {
                  var predicateEvent = predicateEventMap[match[1]];
                  if (!predicateEvent.hasListener(fullEventName)) {
                    addUnderlyingListener(fullEventName, predicateEvent, jsonPathCompiler(match[2]));
                  }
                }
              });
            }
          },
          function(module2, __webpack_exports__, __webpack_require__) {
            "use strict";
            __webpack_require__.d(__webpack_exports__, "a", function() {
              return jsonPathCompiler;
            });
            var __WEBPACK_IMPORTED_MODULE_0__functional__ = __webpack_require__(0);
            var __WEBPACK_IMPORTED_MODULE_1__lists__ = __webpack_require__(1);
            var __WEBPACK_IMPORTED_MODULE_2__ascent__ = __webpack_require__(4);
            var __WEBPACK_IMPORTED_MODULE_3__util__ = __webpack_require__(2);
            var __WEBPACK_IMPORTED_MODULE_4__incrementalContentBuilder__ = __webpack_require__(6);
            var __WEBPACK_IMPORTED_MODULE_5__jsonPathSyntax__ = __webpack_require__(15);
            var jsonPathCompiler = Object(__WEBPACK_IMPORTED_MODULE_5__jsonPathSyntax__["a"])(function(pathNodeSyntax, doubleDotSyntax, dotSyntax, bangSyntax, emptySyntax) {
              var CAPTURING_INDEX = 1;
              var NAME_INDEX = 2;
              var FIELD_LIST_INDEX = 3;
              var headKey = Object(__WEBPACK_IMPORTED_MODULE_0__functional__["d"])(__WEBPACK_IMPORTED_MODULE_2__ascent__["a"], __WEBPACK_IMPORTED_MODULE_1__lists__["g"]);
              var headNode = Object(__WEBPACK_IMPORTED_MODULE_0__functional__["d"])(__WEBPACK_IMPORTED_MODULE_2__ascent__["c"], __WEBPACK_IMPORTED_MODULE_1__lists__["g"]);
              function nameClause(previousExpr, detection) {
                var name = detection[NAME_INDEX];
                var matchesName = !name || name === "*" ? __WEBPACK_IMPORTED_MODULE_0__functional__["a"] : function(ascent) {
                  return String(headKey(ascent)) === name;
                };
                return Object(__WEBPACK_IMPORTED_MODULE_0__functional__["g"])(matchesName, previousExpr);
              }
              function duckTypeClause(previousExpr, detection) {
                var fieldListStr = detection[FIELD_LIST_INDEX];
                if (!fieldListStr) {
                  return previousExpr;
                }
                var hasAllrequiredFields = Object(__WEBPACK_IMPORTED_MODULE_0__functional__["j"])(__WEBPACK_IMPORTED_MODULE_3__util__["b"], Object(__WEBPACK_IMPORTED_MODULE_1__lists__["c"])(fieldListStr.split(/\W+/)));
                var isMatch = Object(__WEBPACK_IMPORTED_MODULE_0__functional__["d"])(hasAllrequiredFields, headNode);
                return Object(__WEBPACK_IMPORTED_MODULE_0__functional__["g"])(isMatch, previousExpr);
              }
              function capture(previousExpr, detection) {
                var capturing = !!detection[CAPTURING_INDEX];
                if (!capturing) {
                  return previousExpr;
                }
                return Object(__WEBPACK_IMPORTED_MODULE_0__functional__["g"])(previousExpr, __WEBPACK_IMPORTED_MODULE_1__lists__["g"]);
              }
              function skip1(previousExpr) {
                if (previousExpr === __WEBPACK_IMPORTED_MODULE_0__functional__["a"]) {
                  return __WEBPACK_IMPORTED_MODULE_0__functional__["a"];
                }
                function notAtRoot(ascent) {
                  return headKey(ascent) !== __WEBPACK_IMPORTED_MODULE_4__incrementalContentBuilder__["a"];
                }
                return Object(__WEBPACK_IMPORTED_MODULE_0__functional__["g"])(notAtRoot, Object(__WEBPACK_IMPORTED_MODULE_0__functional__["d"])(previousExpr, __WEBPACK_IMPORTED_MODULE_1__lists__["l"]));
              }
              function skipMany(previousExpr) {
                if (previousExpr === __WEBPACK_IMPORTED_MODULE_0__functional__["a"]) {
                  return __WEBPACK_IMPORTED_MODULE_0__functional__["a"];
                }
                var terminalCaseWhenArrivingAtRoot = rootExpr();
                var terminalCaseWhenPreviousExpressionIsSatisfied = previousExpr;
                var recursiveCase = skip1(function(ascent) {
                  return cases(ascent);
                });
                var cases = Object(__WEBPACK_IMPORTED_MODULE_0__functional__["h"])(terminalCaseWhenArrivingAtRoot, terminalCaseWhenPreviousExpressionIsSatisfied, recursiveCase);
                return cases;
              }
              function rootExpr() {
                return function(ascent) {
                  return headKey(ascent) === __WEBPACK_IMPORTED_MODULE_4__incrementalContentBuilder__["a"];
                };
              }
              function statementExpr(lastClause) {
                return function(ascent) {
                  var exprMatch = lastClause(ascent);
                  return exprMatch === true ? Object(__WEBPACK_IMPORTED_MODULE_1__lists__["g"])(ascent) : exprMatch;
                };
              }
              function expressionsReader(exprs, parserGeneratedSoFar, detection) {
                return Object(__WEBPACK_IMPORTED_MODULE_1__lists__["f"])(function(parserGeneratedSoFar2, expr) {
                  return expr(parserGeneratedSoFar2, detection);
                }, parserGeneratedSoFar, exprs);
              }
              function generateClauseReaderIfTokenFound(tokenDetector, clauseEvaluatorGenerators, jsonPath, parserGeneratedSoFar, onSuccess) {
                var detected = tokenDetector(jsonPath);
                if (detected) {
                  var compiledParser = expressionsReader(clauseEvaluatorGenerators, parserGeneratedSoFar, detected);
                  var remainingUnparsedJsonPath = jsonPath.substr(Object(__WEBPACK_IMPORTED_MODULE_3__util__["e"])(detected[0]));
                  return onSuccess(remainingUnparsedJsonPath, compiledParser);
                }
              }
              function clauseMatcher(tokenDetector, exprs) {
                return Object(__WEBPACK_IMPORTED_MODULE_0__functional__["j"])(generateClauseReaderIfTokenFound, tokenDetector, exprs);
              }
              var clauseForJsonPath = Object(__WEBPACK_IMPORTED_MODULE_0__functional__["h"])(clauseMatcher(pathNodeSyntax, Object(__WEBPACK_IMPORTED_MODULE_1__lists__["h"])(capture, duckTypeClause, nameClause, skip1)), clauseMatcher(doubleDotSyntax, Object(__WEBPACK_IMPORTED_MODULE_1__lists__["h"])(skipMany)), clauseMatcher(dotSyntax, Object(__WEBPACK_IMPORTED_MODULE_1__lists__["h"])()), clauseMatcher(bangSyntax, Object(__WEBPACK_IMPORTED_MODULE_1__lists__["h"])(capture, rootExpr)), clauseMatcher(emptySyntax, Object(__WEBPACK_IMPORTED_MODULE_1__lists__["h"])(statementExpr)), function(jsonPath) {
                throw Error('"' + jsonPath + '" could not be tokenised');
              });
              function returnFoundParser(_remainingJsonPath, compiledParser) {
                return compiledParser;
              }
              function compileJsonPathToFunction(uncompiledJsonPath, parserGeneratedSoFar) {
                var onFind = uncompiledJsonPath ? compileJsonPathToFunction : returnFoundParser;
                return clauseForJsonPath(uncompiledJsonPath, parserGeneratedSoFar, onFind);
              }
              return function(jsonPath) {
                try {
                  return compileJsonPathToFunction(jsonPath, __WEBPACK_IMPORTED_MODULE_0__functional__["a"]);
                } catch (e) {
                  throw Error('Could not compile "' + jsonPath + '" because ' + e.message);
                }
              };
            });
          },
          function(module2, __webpack_exports__, __webpack_require__) {
            "use strict";
            __webpack_require__.d(__webpack_exports__, "a", function() {
              return jsonPathSyntax;
            });
            var __WEBPACK_IMPORTED_MODULE_0__functional__ = __webpack_require__(0);
            var jsonPathSyntax = function() {
              var regexDescriptor = function regexDescriptor2(regex) {
                return regex.exec.bind(regex);
              };
              var jsonPathClause = Object(__WEBPACK_IMPORTED_MODULE_0__functional__["k"])(function(componentRegexes) {
                componentRegexes.unshift(/^/);
                return regexDescriptor(RegExp(componentRegexes.map(Object(__WEBPACK_IMPORTED_MODULE_0__functional__["c"])("source")).join("")));
              });
              var possiblyCapturing = /(\$?)/;
              var namedNode = /([\w-_]+|\*)/;
              var namePlaceholder = /()/;
              var nodeInArrayNotation = /\["([^"]+)"\]/;
              var numberedNodeInArrayNotation = /\[(\d+|\*)\]/;
              var fieldList = /{([\w ]*?)}/;
              var optionalFieldList = /(?:{([\w ]*?)})?/;
              var jsonPathNamedNodeInObjectNotation = jsonPathClause(possiblyCapturing, namedNode, optionalFieldList);
              var jsonPathNamedNodeInArrayNotation = jsonPathClause(possiblyCapturing, nodeInArrayNotation, optionalFieldList);
              var jsonPathNumberedNodeInArrayNotation = jsonPathClause(possiblyCapturing, numberedNodeInArrayNotation, optionalFieldList);
              var jsonPathPureDuckTyping = jsonPathClause(possiblyCapturing, namePlaceholder, fieldList);
              var jsonPathDoubleDot = jsonPathClause(/\.\./);
              var jsonPathDot = jsonPathClause(/\./);
              var jsonPathBang = jsonPathClause(possiblyCapturing, /!/);
              var emptyString = jsonPathClause(/$/);
              return function(fn) {
                return fn(Object(__WEBPACK_IMPORTED_MODULE_0__functional__["h"])(jsonPathNamedNodeInObjectNotation, jsonPathNamedNodeInArrayNotation, jsonPathNumberedNodeInArrayNotation, jsonPathPureDuckTyping), jsonPathDoubleDot, jsonPathDot, jsonPathBang, emptyString);
              };
            }();
          },
          function(module2, __webpack_exports__, __webpack_require__) {
            "use strict";
            __webpack_require__.d(__webpack_exports__, "a", function() {
              return instanceApi;
            });
            var __WEBPACK_IMPORTED_MODULE_0__events__ = __webpack_require__(3);
            var __WEBPACK_IMPORTED_MODULE_1__functional__ = __webpack_require__(0);
            var __WEBPACK_IMPORTED_MODULE_2__util__ = __webpack_require__(2);
            var __WEBPACK_IMPORTED_MODULE_3__publicApi__ = __webpack_require__(5);
            function instanceApi(oboeBus, contentSource) {
              var oboeApi;
              var fullyQualifiedNamePattern = /^(node|path):./;
              var rootNodeFinishedEvent = oboeBus(__WEBPACK_IMPORTED_MODULE_0__events__["h"]);
              var emitNodeDrop = oboeBus(__WEBPACK_IMPORTED_MODULE_0__events__["e"]).emit;
              var emitNodeSwap = oboeBus(__WEBPACK_IMPORTED_MODULE_0__events__["g"]).emit;
              var addListener = Object(__WEBPACK_IMPORTED_MODULE_1__functional__["k"])(function(eventId, parameters) {
                if (oboeApi[eventId]) {
                  Object(__WEBPACK_IMPORTED_MODULE_1__functional__["b"])(parameters, oboeApi[eventId]);
                } else {
                  var event = oboeBus(eventId);
                  var listener = parameters[0];
                  if (fullyQualifiedNamePattern.test(eventId)) {
                    addForgettableCallback(event, wrapCallbackToSwapNodeIfSomethingReturned(listener));
                  } else {
                    event.on(listener);
                  }
                }
                return oboeApi;
              });
              var removeListener = function(eventId, p2, p3) {
                if (eventId === "done") {
                  rootNodeFinishedEvent.un(p2);
                } else if (eventId === "node" || eventId === "path") {
                  oboeBus.un(eventId + ":" + p2, p3);
                } else {
                  var listener = p2;
                  oboeBus(eventId).un(listener);
                }
                return oboeApi;
              };
              function addProtectedCallback(eventName, callback) {
                oboeBus(eventName).on(protectedCallback(callback), callback);
                return oboeApi;
              }
              function addForgettableCallback(event, callback, listenerId) {
                listenerId = listenerId || callback;
                var safeCallback = protectedCallback(callback);
                event.on(function() {
                  var discard = false;
                  oboeApi.forget = function() {
                    discard = true;
                  };
                  Object(__WEBPACK_IMPORTED_MODULE_1__functional__["b"])(arguments, safeCallback);
                  delete oboeApi.forget;
                  if (discard) {
                    event.un(listenerId);
                  }
                }, listenerId);
                return oboeApi;
              }
              function protectedCallback(callback) {
                return function() {
                  try {
                    return callback.apply(oboeApi, arguments);
                  } catch (e) {
                    setTimeout(function() {
                      throw new Error(e.message);
                    });
                  }
                };
              }
              function fullyQualifiedPatternMatchEvent(type, pattern) {
                return oboeBus(type + ":" + pattern);
              }
              function wrapCallbackToSwapNodeIfSomethingReturned(callback) {
                return function() {
                  var returnValueFromCallback = callback.apply(this, arguments);
                  if (Object(__WEBPACK_IMPORTED_MODULE_2__util__["a"])(returnValueFromCallback)) {
                    if (returnValueFromCallback === __WEBPACK_IMPORTED_MODULE_3__publicApi__["a"].drop) {
                      emitNodeDrop();
                    } else {
                      emitNodeSwap(returnValueFromCallback);
                    }
                  }
                };
              }
              function addSingleNodeOrPathListener(eventId, pattern, callback) {
                var effectiveCallback;
                if (eventId === "node") {
                  effectiveCallback = wrapCallbackToSwapNodeIfSomethingReturned(callback);
                } else {
                  effectiveCallback = callback;
                }
                addForgettableCallback(fullyQualifiedPatternMatchEvent(eventId, pattern), effectiveCallback, callback);
              }
              function addMultipleNodeOrPathListeners(eventId, listenerMap) {
                for (var pattern in listenerMap) {
                  addSingleNodeOrPathListener(eventId, pattern, listenerMap[pattern]);
                }
              }
              function addNodeOrPathListenerApi(eventId, jsonPathOrListenerMap, callback) {
                if (Object(__WEBPACK_IMPORTED_MODULE_2__util__["d"])(jsonPathOrListenerMap)) {
                  addSingleNodeOrPathListener(eventId, jsonPathOrListenerMap, callback);
                } else {
                  addMultipleNodeOrPathListeners(eventId, jsonPathOrListenerMap);
                }
                return oboeApi;
              }
              oboeBus(__WEBPACK_IMPORTED_MODULE_0__events__["i"]).on(function(rootNode) {
                oboeApi.root = Object(__WEBPACK_IMPORTED_MODULE_1__functional__["f"])(rootNode);
              });
              oboeBus(__WEBPACK_IMPORTED_MODULE_0__events__["c"]).on(function(_statusCode, headers) {
                oboeApi.header = function(name) {
                  return name ? headers[name] : headers;
                };
              });
              oboeApi = {
                on: addListener,
                addListener,
                removeListener,
                emit: oboeBus.emit,
                node: Object(__WEBPACK_IMPORTED_MODULE_1__functional__["j"])(addNodeOrPathListenerApi, "node"),
                path: Object(__WEBPACK_IMPORTED_MODULE_1__functional__["j"])(addNodeOrPathListenerApi, "path"),
                done: Object(__WEBPACK_IMPORTED_MODULE_1__functional__["j"])(addForgettableCallback, rootNodeFinishedEvent),
                start: Object(__WEBPACK_IMPORTED_MODULE_1__functional__["j"])(addProtectedCallback, __WEBPACK_IMPORTED_MODULE_0__events__["c"]),
                fail: oboeBus(__WEBPACK_IMPORTED_MODULE_0__events__["b"]).on,
                abort: oboeBus(__WEBPACK_IMPORTED_MODULE_0__events__["a"]).emit,
                header: __WEBPACK_IMPORTED_MODULE_1__functional__["i"],
                root: __WEBPACK_IMPORTED_MODULE_1__functional__["i"],
                source: contentSource
              };
              return oboeApi;
            }
          },
          function(module2, __webpack_exports__, __webpack_require__) {
            "use strict";
            __webpack_require__.d(__webpack_exports__, "a", function() {
              return clarinet;
            });
            var __WEBPACK_IMPORTED_MODULE_0__events__ = __webpack_require__(3);
            function clarinet(eventBus) {
              "use strict";
              var emitSaxKey = eventBus(__WEBPACK_IMPORTED_MODULE_0__events__["j"]).emit;
              var emitValueOpen = eventBus(__WEBPACK_IMPORTED_MODULE_0__events__["l"]).emit;
              var emitValueClose = eventBus(__WEBPACK_IMPORTED_MODULE_0__events__["k"]).emit;
              var emitFail = eventBus(__WEBPACK_IMPORTED_MODULE_0__events__["b"]).emit;
              var MAX_BUFFER_LENGTH = 64 * 1024;
              var stringTokenPattern = /[\\"\n]/g;
              var _n = 0;
              var BEGIN = _n++;
              var VALUE = _n++;
              var OPEN_OBJECT = _n++;
              var CLOSE_OBJECT = _n++;
              var OPEN_ARRAY = _n++;
              var CLOSE_ARRAY = _n++;
              var STRING = _n++;
              var OPEN_KEY = _n++;
              var CLOSE_KEY = _n++;
              var TRUE = _n++;
              var TRUE2 = _n++;
              var TRUE3 = _n++;
              var FALSE = _n++;
              var FALSE2 = _n++;
              var FALSE3 = _n++;
              var FALSE4 = _n++;
              var NULL = _n++;
              var NULL2 = _n++;
              var NULL3 = _n++;
              var NUMBER_DECIMAL_POINT = _n++;
              var NUMBER_DIGIT = _n;
              var bufferCheckPosition = MAX_BUFFER_LENGTH;
              var latestError;
              var c;
              var p;
              var textNode;
              var numberNode = "";
              var slashed = false;
              var closed = false;
              var state = BEGIN;
              var stack = [];
              var unicodeS = null;
              var unicodeI = 0;
              var depth = 0;
              var position = 0;
              var column = 0;
              var line = 1;
              function checkBufferLength() {
                var maxActual = 0;
                if (textNode !== void 0 && textNode.length > MAX_BUFFER_LENGTH) {
                  emitError("Max buffer length exceeded: textNode");
                  maxActual = Math.max(maxActual, textNode.length);
                }
                if (numberNode.length > MAX_BUFFER_LENGTH) {
                  emitError("Max buffer length exceeded: numberNode");
                  maxActual = Math.max(maxActual, numberNode.length);
                }
                bufferCheckPosition = MAX_BUFFER_LENGTH - maxActual + position;
              }
              eventBus(__WEBPACK_IMPORTED_MODULE_0__events__["m"]).on(handleData);
              eventBus(__WEBPACK_IMPORTED_MODULE_0__events__["n"]).on(handleStreamEnd);
              function emitError(errorString) {
                if (textNode !== void 0) {
                  emitValueOpen(textNode);
                  emitValueClose();
                  textNode = void 0;
                }
                latestError = Error(errorString + "\nLn: " + line + "\nCol: " + column + "\nChr: " + c);
                emitFail(Object(__WEBPACK_IMPORTED_MODULE_0__events__["o"])(void 0, void 0, latestError));
              }
              function handleStreamEnd() {
                if (state === BEGIN) {
                  emitValueOpen({});
                  emitValueClose();
                  closed = true;
                  return;
                }
                if (state !== VALUE || depth !== 0) {
                  emitError("Unexpected end");
                }
                if (textNode !== void 0) {
                  emitValueOpen(textNode);
                  emitValueClose();
                  textNode = void 0;
                }
                closed = true;
              }
              function whitespace(c2) {
                return c2 === "\r" || c2 === "\n" || c2 === " " || c2 === "	";
              }
              function handleData(chunk) {
                if (latestError) {
                  return;
                }
                if (closed) {
                  return emitError("Cannot write after close");
                }
                var i = 0;
                c = chunk[0];
                while (c) {
                  if (i > 0) {
                    p = c;
                  }
                  c = chunk[i++];
                  if (!c)
                    break;
                  position++;
                  if (c === "\n") {
                    line++;
                    column = 0;
                  } else
                    column++;
                  switch (state) {
                    case BEGIN:
                      if (c === "{")
                        state = OPEN_OBJECT;
                      else if (c === "[")
                        state = OPEN_ARRAY;
                      else if (!whitespace(c)) {
                        return emitError("Non-whitespace before {[.");
                      }
                      continue;
                    case OPEN_KEY:
                    case OPEN_OBJECT:
                      if (whitespace(c))
                        continue;
                      if (state === OPEN_KEY)
                        stack.push(CLOSE_KEY);
                      else {
                        if (c === "}") {
                          emitValueOpen({});
                          emitValueClose();
                          state = stack.pop() || VALUE;
                          continue;
                        } else
                          stack.push(CLOSE_OBJECT);
                      }
                      if (c === '"') {
                        state = STRING;
                      } else {
                        return emitError('Malformed object key should start with " ');
                      }
                      continue;
                    case CLOSE_KEY:
                    case CLOSE_OBJECT:
                      if (whitespace(c))
                        continue;
                      if (c === ":") {
                        if (state === CLOSE_OBJECT) {
                          stack.push(CLOSE_OBJECT);
                          if (textNode !== void 0) {
                            emitValueOpen({});
                            emitSaxKey(textNode);
                            textNode = void 0;
                          }
                          depth++;
                        } else {
                          if (textNode !== void 0) {
                            emitSaxKey(textNode);
                            textNode = void 0;
                          }
                        }
                        state = VALUE;
                      } else if (c === "}") {
                        if (textNode !== void 0) {
                          emitValueOpen(textNode);
                          emitValueClose();
                          textNode = void 0;
                        }
                        emitValueClose();
                        depth--;
                        state = stack.pop() || VALUE;
                      } else if (c === ",") {
                        if (state === CLOSE_OBJECT) {
                          stack.push(CLOSE_OBJECT);
                        }
                        if (textNode !== void 0) {
                          emitValueOpen(textNode);
                          emitValueClose();
                          textNode = void 0;
                        }
                        state = OPEN_KEY;
                      } else {
                        return emitError("Bad object");
                      }
                      continue;
                    case OPEN_ARRAY:
                    case VALUE:
                      if (whitespace(c))
                        continue;
                      if (state === OPEN_ARRAY) {
                        emitValueOpen([]);
                        depth++;
                        state = VALUE;
                        if (c === "]") {
                          emitValueClose();
                          depth--;
                          state = stack.pop() || VALUE;
                          continue;
                        } else {
                          stack.push(CLOSE_ARRAY);
                        }
                      }
                      if (c === '"')
                        state = STRING;
                      else if (c === "{")
                        state = OPEN_OBJECT;
                      else if (c === "[")
                        state = OPEN_ARRAY;
                      else if (c === "t")
                        state = TRUE;
                      else if (c === "f")
                        state = FALSE;
                      else if (c === "n")
                        state = NULL;
                      else if (c === "-") {
                        numberNode += c;
                      } else if (c === "0") {
                        numberNode += c;
                        state = NUMBER_DIGIT;
                      } else if ("123456789".indexOf(c) !== -1) {
                        numberNode += c;
                        state = NUMBER_DIGIT;
                      } else {
                        return emitError("Bad value");
                      }
                      continue;
                    case CLOSE_ARRAY:
                      if (c === ",") {
                        stack.push(CLOSE_ARRAY);
                        if (textNode !== void 0) {
                          emitValueOpen(textNode);
                          emitValueClose();
                          textNode = void 0;
                        }
                        state = VALUE;
                      } else if (c === "]") {
                        if (textNode !== void 0) {
                          emitValueOpen(textNode);
                          emitValueClose();
                          textNode = void 0;
                        }
                        emitValueClose();
                        depth--;
                        state = stack.pop() || VALUE;
                      } else if (whitespace(c)) {
                        continue;
                      } else {
                        return emitError("Bad array");
                      }
                      continue;
                    case STRING:
                      if (textNode === void 0) {
                        textNode = "";
                      }
                      var starti = i - 1;
                      STRING_BIGLOOP:
                        while (true) {
                          while (unicodeI > 0) {
                            unicodeS += c;
                            c = chunk.charAt(i++);
                            if (unicodeI === 4) {
                              textNode += String.fromCharCode(parseInt(unicodeS, 16));
                              unicodeI = 0;
                              starti = i - 1;
                            } else {
                              unicodeI++;
                            }
                            if (!c)
                              break STRING_BIGLOOP;
                          }
                          if (c === '"' && !slashed) {
                            state = stack.pop() || VALUE;
                            textNode += chunk.substring(starti, i - 1);
                            break;
                          }
                          if (c === "\\" && !slashed) {
                            slashed = true;
                            textNode += chunk.substring(starti, i - 1);
                            c = chunk.charAt(i++);
                            if (!c)
                              break;
                          }
                          if (slashed) {
                            slashed = false;
                            if (c === "n") {
                              textNode += "\n";
                            } else if (c === "r") {
                              textNode += "\r";
                            } else if (c === "t") {
                              textNode += "	";
                            } else if (c === "f") {
                              textNode += "\f";
                            } else if (c === "b") {
                              textNode += "\b";
                            } else if (c === "u") {
                              unicodeI = 1;
                              unicodeS = "";
                            } else {
                              textNode += c;
                            }
                            c = chunk.charAt(i++);
                            starti = i - 1;
                            if (!c)
                              break;
                            else
                              continue;
                          }
                          stringTokenPattern.lastIndex = i;
                          var reResult = stringTokenPattern.exec(chunk);
                          if (!reResult) {
                            i = chunk.length + 1;
                            textNode += chunk.substring(starti, i - 1);
                            break;
                          }
                          i = reResult.index + 1;
                          c = chunk.charAt(reResult.index);
                          if (!c) {
                            textNode += chunk.substring(starti, i - 1);
                            break;
                          }
                        }
                      continue;
                    case TRUE:
                      if (!c)
                        continue;
                      if (c === "r")
                        state = TRUE2;
                      else {
                        return emitError("Invalid true started with t" + c);
                      }
                      continue;
                    case TRUE2:
                      if (!c)
                        continue;
                      if (c === "u")
                        state = TRUE3;
                      else {
                        return emitError("Invalid true started with tr" + c);
                      }
                      continue;
                    case TRUE3:
                      if (!c)
                        continue;
                      if (c === "e") {
                        emitValueOpen(true);
                        emitValueClose();
                        state = stack.pop() || VALUE;
                      } else {
                        return emitError("Invalid true started with tru" + c);
                      }
                      continue;
                    case FALSE:
                      if (!c)
                        continue;
                      if (c === "a")
                        state = FALSE2;
                      else {
                        return emitError("Invalid false started with f" + c);
                      }
                      continue;
                    case FALSE2:
                      if (!c)
                        continue;
                      if (c === "l")
                        state = FALSE3;
                      else {
                        return emitError("Invalid false started with fa" + c);
                      }
                      continue;
                    case FALSE3:
                      if (!c)
                        continue;
                      if (c === "s")
                        state = FALSE4;
                      else {
                        return emitError("Invalid false started with fal" + c);
                      }
                      continue;
                    case FALSE4:
                      if (!c)
                        continue;
                      if (c === "e") {
                        emitValueOpen(false);
                        emitValueClose();
                        state = stack.pop() || VALUE;
                      } else {
                        return emitError("Invalid false started with fals" + c);
                      }
                      continue;
                    case NULL:
                      if (!c)
                        continue;
                      if (c === "u")
                        state = NULL2;
                      else {
                        return emitError("Invalid null started with n" + c);
                      }
                      continue;
                    case NULL2:
                      if (!c)
                        continue;
                      if (c === "l")
                        state = NULL3;
                      else {
                        return emitError("Invalid null started with nu" + c);
                      }
                      continue;
                    case NULL3:
                      if (!c)
                        continue;
                      if (c === "l") {
                        emitValueOpen(null);
                        emitValueClose();
                        state = stack.pop() || VALUE;
                      } else {
                        return emitError("Invalid null started with nul" + c);
                      }
                      continue;
                    case NUMBER_DECIMAL_POINT:
                      if (c === ".") {
                        numberNode += c;
                        state = NUMBER_DIGIT;
                      } else {
                        return emitError("Leading zero not followed by .");
                      }
                      continue;
                    case NUMBER_DIGIT:
                      if ("0123456789".indexOf(c) !== -1)
                        numberNode += c;
                      else if (c === ".") {
                        if (numberNode.indexOf(".") !== -1) {
                          return emitError("Invalid number has two dots");
                        }
                        numberNode += c;
                      } else if (c === "e" || c === "E") {
                        if (numberNode.indexOf("e") !== -1 || numberNode.indexOf("E") !== -1) {
                          return emitError("Invalid number has two exponential");
                        }
                        numberNode += c;
                      } else if (c === "+" || c === "-") {
                        if (!(p === "e" || p === "E")) {
                          return emitError("Invalid symbol in number");
                        }
                        numberNode += c;
                      } else {
                        if (numberNode) {
                          emitValueOpen(parseFloat(numberNode));
                          emitValueClose();
                          numberNode = "";
                        }
                        i--;
                        state = stack.pop() || VALUE;
                      }
                      continue;
                    default:
                      return emitError("Unknown state: " + state);
                  }
                }
                if (position >= bufferCheckPosition) {
                  checkBufferLength();
                }
              }
            }
          },
          function(module2, __webpack_exports__, __webpack_require__) {
            "use strict";
            __webpack_require__.d(__webpack_exports__, "a", function() {
              return httpTransport;
            });
            __webpack_require__.d(__webpack_exports__, "b", function() {
              return streamingHttp;
            });
            var __WEBPACK_IMPORTED_MODULE_0__detectCrossOrigin_browser__ = __webpack_require__(19);
            var __WEBPACK_IMPORTED_MODULE_1__events__ = __webpack_require__(3);
            var __WEBPACK_IMPORTED_MODULE_2__util__ = __webpack_require__(2);
            var __WEBPACK_IMPORTED_MODULE_3__parseResponseHeaders_browser__ = __webpack_require__(20);
            var __WEBPACK_IMPORTED_MODULE_4__functional__ = __webpack_require__(0);
            function httpTransport() {
              return new XMLHttpRequest();
            }
            function streamingHttp(oboeBus, xhr, method, url, data, headers, withCredentials) {
              "use strict";
              var emitStreamData = oboeBus(__WEBPACK_IMPORTED_MODULE_1__events__["m"]).emit;
              var emitFail = oboeBus(__WEBPACK_IMPORTED_MODULE_1__events__["b"]).emit;
              var numberOfCharsAlreadyGivenToCallback = 0;
              var stillToSendStartEvent = true;
              oboeBus(__WEBPACK_IMPORTED_MODULE_1__events__["a"]).on(function() {
                xhr.onreadystatechange = null;
                xhr.abort();
              });
              function handleProgress() {
                if (String(xhr.status)[0] === "2") {
                  var textSoFar = xhr.responseText;
                  var newText = (" " + textSoFar.substr(numberOfCharsAlreadyGivenToCallback)).substr(1);
                  if (newText) {
                    emitStreamData(newText);
                  }
                  numberOfCharsAlreadyGivenToCallback = Object(__WEBPACK_IMPORTED_MODULE_2__util__["e"])(textSoFar);
                }
              }
              if ("onprogress" in xhr) {
                xhr.onprogress = handleProgress;
              }
              function sendStartIfNotAlready(xhr2) {
                try {
                  stillToSendStartEvent && oboeBus(__WEBPACK_IMPORTED_MODULE_1__events__["c"]).emit(xhr2.status, Object(__WEBPACK_IMPORTED_MODULE_3__parseResponseHeaders_browser__["a"])(xhr2.getAllResponseHeaders()));
                  stillToSendStartEvent = false;
                } catch (e) {
                }
              }
              xhr.onreadystatechange = function() {
                switch (xhr.readyState) {
                  case 2:
                  case 3:
                    return sendStartIfNotAlready(xhr);
                  case 4:
                    sendStartIfNotAlready(xhr);
                    var successful = String(xhr.status)[0] === "2";
                    if (successful) {
                      handleProgress();
                      oboeBus(__WEBPACK_IMPORTED_MODULE_1__events__["n"]).emit();
                    } else {
                      emitFail(Object(__WEBPACK_IMPORTED_MODULE_1__events__["o"])(xhr.status, xhr.responseText));
                    }
                }
              };
              try {
                xhr.open(method, url, true);
                for (var headerName in headers) {
                  xhr.setRequestHeader(headerName, headers[headerName]);
                }
                if (!Object(__WEBPACK_IMPORTED_MODULE_0__detectCrossOrigin_browser__["a"])(window.location, Object(__WEBPACK_IMPORTED_MODULE_0__detectCrossOrigin_browser__["b"])(url))) {
                  xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
                }
                xhr.withCredentials = withCredentials;
                xhr.send(data);
              } catch (e) {
                window.setTimeout(Object(__WEBPACK_IMPORTED_MODULE_4__functional__["j"])(emitFail, Object(__WEBPACK_IMPORTED_MODULE_1__events__["o"])(void 0, void 0, e)), 0);
              }
            }
          },
          function(module2, __webpack_exports__, __webpack_require__) {
            "use strict";
            __webpack_require__.d(__webpack_exports__, "a", function() {
              return isCrossOrigin;
            });
            __webpack_require__.d(__webpack_exports__, "b", function() {
              return parseUrlOrigin;
            });
            function isCrossOrigin(pageLocation, ajaxHost) {
              function defaultPort(protocol) {
                return { "http:": 80, "https:": 443 }[protocol];
              }
              function portOf(location2) {
                return String(location2.port || defaultPort(location2.protocol || pageLocation.protocol));
              }
              return !!(ajaxHost.protocol && ajaxHost.protocol !== pageLocation.protocol || ajaxHost.host && ajaxHost.host !== pageLocation.host || ajaxHost.host && portOf(ajaxHost) !== portOf(pageLocation));
            }
            function parseUrlOrigin(url) {
              var URL_HOST_PATTERN = /(\w+:)?(?:\/\/)([\w.-]+)?(?::(\d+))?\/?/;
              var urlHostMatch = URL_HOST_PATTERN.exec(url) || [];
              return {
                protocol: urlHostMatch[1] || "",
                host: urlHostMatch[2] || "",
                port: urlHostMatch[3] || ""
              };
            }
          },
          function(module2, __webpack_exports__, __webpack_require__) {
            "use strict";
            __webpack_require__.d(__webpack_exports__, "a", function() {
              return parseResponseHeaders;
            });
            function parseResponseHeaders(headerStr) {
              var headers = {};
              headerStr && headerStr.split("\r\n").forEach(function(headerPair) {
                var index = headerPair.indexOf(": ");
                headers[headerPair.substring(0, index)] = headerPair.substring(index + 2);
              });
              return headers;
            }
          }
        ])["default"];
      });
    }
  });

  // node_modules/jquery/dist/jquery.js
  var require_jquery = __commonJS({
    "node_modules/jquery/dist/jquery.js"(exports, module) {
      (function(global, factory) {
        "use strict";
        if (typeof module === "object" && typeof module.exports === "object") {
          module.exports = global.document ? factory(global, true) : function(w) {
            if (!w.document) {
              throw new Error("jQuery requires a window with a document");
            }
            return factory(w);
          };
        } else {
          factory(global);
        }
      })(typeof window !== "undefined" ? window : exports, function(window2, noGlobal) {
        "use strict";
        var arr = [];
        var getProto = Object.getPrototypeOf;
        var slice = arr.slice;
        var flat = arr.flat ? function(array) {
          return arr.flat.call(array);
        } : function(array) {
          return arr.concat.apply([], array);
        };
        var push = arr.push;
        var indexOf = arr.indexOf;
        var class2type = {};
        var toString = class2type.toString;
        var hasOwn = class2type.hasOwnProperty;
        var fnToString = hasOwn.toString;
        var ObjectFunctionString = fnToString.call(Object);
        var support = {};
        var isFunction = function isFunction2(obj) {
          return typeof obj === "function" && typeof obj.nodeType !== "number" && typeof obj.item !== "function";
        };
        var isWindow = function isWindow2(obj) {
          return obj != null && obj === obj.window;
        };
        var document2 = window2.document;
        var preservedScriptAttributes = {
          type: true,
          src: true,
          nonce: true,
          noModule: true
        };
        function DOMEval(code, node, doc) {
          doc = doc || document2;
          var i, val, script = doc.createElement("script");
          script.text = code;
          if (node) {
            for (i in preservedScriptAttributes) {
              val = node[i] || node.getAttribute && node.getAttribute(i);
              if (val) {
                script.setAttribute(i, val);
              }
            }
          }
          doc.head.appendChild(script).parentNode.removeChild(script);
        }
        function toType(obj) {
          if (obj == null) {
            return obj + "";
          }
          return typeof obj === "object" || typeof obj === "function" ? class2type[toString.call(obj)] || "object" : typeof obj;
        }
        var version = "3.6.0", jQuery2 = function(selector, context) {
          return new jQuery2.fn.init(selector, context);
        };
        jQuery2.fn = jQuery2.prototype = {
          jquery: version,
          constructor: jQuery2,
          length: 0,
          toArray: function() {
            return slice.call(this);
          },
          get: function(num) {
            if (num == null) {
              return slice.call(this);
            }
            return num < 0 ? this[num + this.length] : this[num];
          },
          pushStack: function(elems) {
            var ret = jQuery2.merge(this.constructor(), elems);
            ret.prevObject = this;
            return ret;
          },
          each: function(callback) {
            return jQuery2.each(this, callback);
          },
          map: function(callback) {
            return this.pushStack(jQuery2.map(this, function(elem, i) {
              return callback.call(elem, i, elem);
            }));
          },
          slice: function() {
            return this.pushStack(slice.apply(this, arguments));
          },
          first: function() {
            return this.eq(0);
          },
          last: function() {
            return this.eq(-1);
          },
          even: function() {
            return this.pushStack(jQuery2.grep(this, function(_elem, i) {
              return (i + 1) % 2;
            }));
          },
          odd: function() {
            return this.pushStack(jQuery2.grep(this, function(_elem, i) {
              return i % 2;
            }));
          },
          eq: function(i) {
            var len = this.length, j = +i + (i < 0 ? len : 0);
            return this.pushStack(j >= 0 && j < len ? [this[j]] : []);
          },
          end: function() {
            return this.prevObject || this.constructor();
          },
          push,
          sort: arr.sort,
          splice: arr.splice
        };
        jQuery2.extend = jQuery2.fn.extend = function() {
          var options, name, src, copy, copyIsArray, clone, target = arguments[0] || {}, i = 1, length = arguments.length, deep = false;
          if (typeof target === "boolean") {
            deep = target;
            target = arguments[i] || {};
            i++;
          }
          if (typeof target !== "object" && !isFunction(target)) {
            target = {};
          }
          if (i === length) {
            target = this;
            i--;
          }
          for (; i < length; i++) {
            if ((options = arguments[i]) != null) {
              for (name in options) {
                copy = options[name];
                if (name === "__proto__" || target === copy) {
                  continue;
                }
                if (deep && copy && (jQuery2.isPlainObject(copy) || (copyIsArray = Array.isArray(copy)))) {
                  src = target[name];
                  if (copyIsArray && !Array.isArray(src)) {
                    clone = [];
                  } else if (!copyIsArray && !jQuery2.isPlainObject(src)) {
                    clone = {};
                  } else {
                    clone = src;
                  }
                  copyIsArray = false;
                  target[name] = jQuery2.extend(deep, clone, copy);
                } else if (copy !== void 0) {
                  target[name] = copy;
                }
              }
            }
          }
          return target;
        };
        jQuery2.extend({
          expando: "jQuery" + (version + Math.random()).replace(/\D/g, ""),
          isReady: true,
          error: function(msg) {
            throw new Error(msg);
          },
          noop: function() {
          },
          isPlainObject: function(obj) {
            var proto, Ctor;
            if (!obj || toString.call(obj) !== "[object Object]") {
              return false;
            }
            proto = getProto(obj);
            if (!proto) {
              return true;
            }
            Ctor = hasOwn.call(proto, "constructor") && proto.constructor;
            return typeof Ctor === "function" && fnToString.call(Ctor) === ObjectFunctionString;
          },
          isEmptyObject: function(obj) {
            var name;
            for (name in obj) {
              return false;
            }
            return true;
          },
          globalEval: function(code, options, doc) {
            DOMEval(code, { nonce: options && options.nonce }, doc);
          },
          each: function(obj, callback) {
            var length, i = 0;
            if (isArrayLike(obj)) {
              length = obj.length;
              for (; i < length; i++) {
                if (callback.call(obj[i], i, obj[i]) === false) {
                  break;
                }
              }
            } else {
              for (i in obj) {
                if (callback.call(obj[i], i, obj[i]) === false) {
                  break;
                }
              }
            }
            return obj;
          },
          makeArray: function(arr2, results) {
            var ret = results || [];
            if (arr2 != null) {
              if (isArrayLike(Object(arr2))) {
                jQuery2.merge(ret, typeof arr2 === "string" ? [arr2] : arr2);
              } else {
                push.call(ret, arr2);
              }
            }
            return ret;
          },
          inArray: function(elem, arr2, i) {
            return arr2 == null ? -1 : indexOf.call(arr2, elem, i);
          },
          merge: function(first, second) {
            var len = +second.length, j = 0, i = first.length;
            for (; j < len; j++) {
              first[i++] = second[j];
            }
            first.length = i;
            return first;
          },
          grep: function(elems, callback, invert) {
            var callbackInverse, matches = [], i = 0, length = elems.length, callbackExpect = !invert;
            for (; i < length; i++) {
              callbackInverse = !callback(elems[i], i);
              if (callbackInverse !== callbackExpect) {
                matches.push(elems[i]);
              }
            }
            return matches;
          },
          map: function(elems, callback, arg) {
            var length, value, i = 0, ret = [];
            if (isArrayLike(elems)) {
              length = elems.length;
              for (; i < length; i++) {
                value = callback(elems[i], i, arg);
                if (value != null) {
                  ret.push(value);
                }
              }
            } else {
              for (i in elems) {
                value = callback(elems[i], i, arg);
                if (value != null) {
                  ret.push(value);
                }
              }
            }
            return flat(ret);
          },
          guid: 1,
          support
        });
        if (typeof Symbol === "function") {
          jQuery2.fn[Symbol.iterator] = arr[Symbol.iterator];
        }
        jQuery2.each("Boolean Number String Function Array Date RegExp Object Error Symbol".split(" "), function(_i, name) {
          class2type["[object " + name + "]"] = name.toLowerCase();
        });
        function isArrayLike(obj) {
          var length = !!obj && "length" in obj && obj.length, type = toType(obj);
          if (isFunction(obj) || isWindow(obj)) {
            return false;
          }
          return type === "array" || length === 0 || typeof length === "number" && length > 0 && length - 1 in obj;
        }
        var Sizzle = function(window3) {
          var i, support2, Expr, getText, isXML, tokenize, compile, select, outermostContext, sortInput, hasDuplicate, setDocument, document3, docElem, documentIsHTML, rbuggyQSA, rbuggyMatches, matches, contains, expando = "sizzle" + 1 * new Date(), preferredDoc = window3.document, dirruns = 0, done = 0, classCache = createCache(), tokenCache = createCache(), compilerCache = createCache(), nonnativeSelectorCache = createCache(), sortOrder = function(a, b) {
            if (a === b) {
              hasDuplicate = true;
            }
            return 0;
          }, hasOwn2 = {}.hasOwnProperty, arr2 = [], pop = arr2.pop, pushNative = arr2.push, push2 = arr2.push, slice2 = arr2.slice, indexOf2 = function(list, elem) {
            var i2 = 0, len = list.length;
            for (; i2 < len; i2++) {
              if (list[i2] === elem) {
                return i2;
              }
            }
            return -1;
          }, booleans = "checked|selected|async|autofocus|autoplay|controls|defer|disabled|hidden|ismap|loop|multiple|open|readonly|required|scoped", whitespace = "[\\x20\\t\\r\\n\\f]", identifier = "(?:\\\\[\\da-fA-F]{1,6}" + whitespace + "?|\\\\[^\\r\\n\\f]|[\\w-]|[^\0-\\x7f])+", attributes = "\\[" + whitespace + "*(" + identifier + ")(?:" + whitespace + "*([*^$|!~]?=)" + whitespace + `*(?:'((?:\\\\.|[^\\\\'])*)'|"((?:\\\\.|[^\\\\"])*)"|(` + identifier + "))|)" + whitespace + "*\\]", pseudos = ":(" + identifier + `)(?:\\((('((?:\\\\.|[^\\\\'])*)'|"((?:\\\\.|[^\\\\"])*)")|((?:\\\\.|[^\\\\()[\\]]|` + attributes + ")*)|.*)\\)|)", rwhitespace = new RegExp(whitespace + "+", "g"), rtrim2 = new RegExp("^" + whitespace + "+|((?:^|[^\\\\])(?:\\\\.)*)" + whitespace + "+$", "g"), rcomma = new RegExp("^" + whitespace + "*," + whitespace + "*"), rcombinators = new RegExp("^" + whitespace + "*([>+~]|" + whitespace + ")" + whitespace + "*"), rdescend = new RegExp(whitespace + "|>"), rpseudo = new RegExp(pseudos), ridentifier = new RegExp("^" + identifier + "$"), matchExpr = {
            "ID": new RegExp("^#(" + identifier + ")"),
            "CLASS": new RegExp("^\\.(" + identifier + ")"),
            "TAG": new RegExp("^(" + identifier + "|[*])"),
            "ATTR": new RegExp("^" + attributes),
            "PSEUDO": new RegExp("^" + pseudos),
            "CHILD": new RegExp("^:(only|first|last|nth|nth-last)-(child|of-type)(?:\\(" + whitespace + "*(even|odd|(([+-]|)(\\d*)n|)" + whitespace + "*(?:([+-]|)" + whitespace + "*(\\d+)|))" + whitespace + "*\\)|)", "i"),
            "bool": new RegExp("^(?:" + booleans + ")$", "i"),
            "needsContext": new RegExp("^" + whitespace + "*[>+~]|:(even|odd|eq|gt|lt|nth|first|last)(?:\\(" + whitespace + "*((?:-\\d)?\\d*)" + whitespace + "*\\)|)(?=[^-]|$)", "i")
          }, rhtml2 = /HTML$/i, rinputs = /^(?:input|select|textarea|button)$/i, rheader = /^h\d$/i, rnative = /^[^{]+\{\s*\[native \w/, rquickExpr2 = /^(?:#([\w-]+)|(\w+)|\.([\w-]+))$/, rsibling = /[+~]/, runescape = new RegExp("\\\\[\\da-fA-F]{1,6}" + whitespace + "?|\\\\([^\\r\\n\\f])", "g"), funescape = function(escape, nonHex) {
            var high = "0x" + escape.slice(1) - 65536;
            return nonHex ? nonHex : high < 0 ? String.fromCharCode(high + 65536) : String.fromCharCode(high >> 10 | 55296, high & 1023 | 56320);
          }, rcssescape = /([\0-\x1f\x7f]|^-?\d)|^-$|[^\0-\x1f\x7f-\uFFFF\w-]/g, fcssescape = function(ch, asCodePoint) {
            if (asCodePoint) {
              if (ch === "\0") {
                return "\uFFFD";
              }
              return ch.slice(0, -1) + "\\" + ch.charCodeAt(ch.length - 1).toString(16) + " ";
            }
            return "\\" + ch;
          }, unloadHandler = function() {
            setDocument();
          }, inDisabledFieldset = addCombinator(function(elem) {
            return elem.disabled === true && elem.nodeName.toLowerCase() === "fieldset";
          }, { dir: "parentNode", next: "legend" });
          try {
            push2.apply(arr2 = slice2.call(preferredDoc.childNodes), preferredDoc.childNodes);
            arr2[preferredDoc.childNodes.length].nodeType;
          } catch (e) {
            push2 = {
              apply: arr2.length ? function(target, els) {
                pushNative.apply(target, slice2.call(els));
              } : function(target, els) {
                var j = target.length, i2 = 0;
                while (target[j++] = els[i2++]) {
                }
                target.length = j - 1;
              }
            };
          }
          function Sizzle2(selector, context, results, seed) {
            var m, i2, elem, nid, match, groups, newSelector, newContext = context && context.ownerDocument, nodeType = context ? context.nodeType : 9;
            results = results || [];
            if (typeof selector !== "string" || !selector || nodeType !== 1 && nodeType !== 9 && nodeType !== 11) {
              return results;
            }
            if (!seed) {
              setDocument(context);
              context = context || document3;
              if (documentIsHTML) {
                if (nodeType !== 11 && (match = rquickExpr2.exec(selector))) {
                  if (m = match[1]) {
                    if (nodeType === 9) {
                      if (elem = context.getElementById(m)) {
                        if (elem.id === m) {
                          results.push(elem);
                          return results;
                        }
                      } else {
                        return results;
                      }
                    } else {
                      if (newContext && (elem = newContext.getElementById(m)) && contains(context, elem) && elem.id === m) {
                        results.push(elem);
                        return results;
                      }
                    }
                  } else if (match[2]) {
                    push2.apply(results, context.getElementsByTagName(selector));
                    return results;
                  } else if ((m = match[3]) && support2.getElementsByClassName && context.getElementsByClassName) {
                    push2.apply(results, context.getElementsByClassName(m));
                    return results;
                  }
                }
                if (support2.qsa && !nonnativeSelectorCache[selector + " "] && (!rbuggyQSA || !rbuggyQSA.test(selector)) && (nodeType !== 1 || context.nodeName.toLowerCase() !== "object")) {
                  newSelector = selector;
                  newContext = context;
                  if (nodeType === 1 && (rdescend.test(selector) || rcombinators.test(selector))) {
                    newContext = rsibling.test(selector) && testContext(context.parentNode) || context;
                    if (newContext !== context || !support2.scope) {
                      if (nid = context.getAttribute("id")) {
                        nid = nid.replace(rcssescape, fcssescape);
                      } else {
                        context.setAttribute("id", nid = expando);
                      }
                    }
                    groups = tokenize(selector);
                    i2 = groups.length;
                    while (i2--) {
                      groups[i2] = (nid ? "#" + nid : ":scope") + " " + toSelector(groups[i2]);
                    }
                    newSelector = groups.join(",");
                  }
                  try {
                    push2.apply(results, newContext.querySelectorAll(newSelector));
                    return results;
                  } catch (qsaError) {
                    nonnativeSelectorCache(selector, true);
                  } finally {
                    if (nid === expando) {
                      context.removeAttribute("id");
                    }
                  }
                }
              }
            }
            return select(selector.replace(rtrim2, "$1"), context, results, seed);
          }
          function createCache() {
            var keys = [];
            function cache(key, value) {
              if (keys.push(key + " ") > Expr.cacheLength) {
                delete cache[keys.shift()];
              }
              return cache[key + " "] = value;
            }
            return cache;
          }
          function markFunction(fn) {
            fn[expando] = true;
            return fn;
          }
          function assert(fn) {
            var el = document3.createElement("fieldset");
            try {
              return !!fn(el);
            } catch (e) {
              return false;
            } finally {
              if (el.parentNode) {
                el.parentNode.removeChild(el);
              }
              el = null;
            }
          }
          function addHandle(attrs, handler) {
            var arr3 = attrs.split("|"), i2 = arr3.length;
            while (i2--) {
              Expr.attrHandle[arr3[i2]] = handler;
            }
          }
          function siblingCheck(a, b) {
            var cur = b && a, diff = cur && a.nodeType === 1 && b.nodeType === 1 && a.sourceIndex - b.sourceIndex;
            if (diff) {
              return diff;
            }
            if (cur) {
              while (cur = cur.nextSibling) {
                if (cur === b) {
                  return -1;
                }
              }
            }
            return a ? 1 : -1;
          }
          function createInputPseudo(type) {
            return function(elem) {
              var name = elem.nodeName.toLowerCase();
              return name === "input" && elem.type === type;
            };
          }
          function createButtonPseudo(type) {
            return function(elem) {
              var name = elem.nodeName.toLowerCase();
              return (name === "input" || name === "button") && elem.type === type;
            };
          }
          function createDisabledPseudo(disabled) {
            return function(elem) {
              if ("form" in elem) {
                if (elem.parentNode && elem.disabled === false) {
                  if ("label" in elem) {
                    if ("label" in elem.parentNode) {
                      return elem.parentNode.disabled === disabled;
                    } else {
                      return elem.disabled === disabled;
                    }
                  }
                  return elem.isDisabled === disabled || elem.isDisabled !== !disabled && inDisabledFieldset(elem) === disabled;
                }
                return elem.disabled === disabled;
              } else if ("label" in elem) {
                return elem.disabled === disabled;
              }
              return false;
            };
          }
          function createPositionalPseudo(fn) {
            return markFunction(function(argument) {
              argument = +argument;
              return markFunction(function(seed, matches2) {
                var j, matchIndexes = fn([], seed.length, argument), i2 = matchIndexes.length;
                while (i2--) {
                  if (seed[j = matchIndexes[i2]]) {
                    seed[j] = !(matches2[j] = seed[j]);
                  }
                }
              });
            });
          }
          function testContext(context) {
            return context && typeof context.getElementsByTagName !== "undefined" && context;
          }
          support2 = Sizzle2.support = {};
          isXML = Sizzle2.isXML = function(elem) {
            var namespace = elem && elem.namespaceURI, docElem2 = elem && (elem.ownerDocument || elem).documentElement;
            return !rhtml2.test(namespace || docElem2 && docElem2.nodeName || "HTML");
          };
          setDocument = Sizzle2.setDocument = function(node) {
            var hasCompare, subWindow, doc = node ? node.ownerDocument || node : preferredDoc;
            if (doc == document3 || doc.nodeType !== 9 || !doc.documentElement) {
              return document3;
            }
            document3 = doc;
            docElem = document3.documentElement;
            documentIsHTML = !isXML(document3);
            if (preferredDoc != document3 && (subWindow = document3.defaultView) && subWindow.top !== subWindow) {
              if (subWindow.addEventListener) {
                subWindow.addEventListener("unload", unloadHandler, false);
              } else if (subWindow.attachEvent) {
                subWindow.attachEvent("onunload", unloadHandler);
              }
            }
            support2.scope = assert(function(el) {
              docElem.appendChild(el).appendChild(document3.createElement("div"));
              return typeof el.querySelectorAll !== "undefined" && !el.querySelectorAll(":scope fieldset div").length;
            });
            support2.attributes = assert(function(el) {
              el.className = "i";
              return !el.getAttribute("className");
            });
            support2.getElementsByTagName = assert(function(el) {
              el.appendChild(document3.createComment(""));
              return !el.getElementsByTagName("*").length;
            });
            support2.getElementsByClassName = rnative.test(document3.getElementsByClassName);
            support2.getById = assert(function(el) {
              docElem.appendChild(el).id = expando;
              return !document3.getElementsByName || !document3.getElementsByName(expando).length;
            });
            if (support2.getById) {
              Expr.filter["ID"] = function(id) {
                var attrId = id.replace(runescape, funescape);
                return function(elem) {
                  return elem.getAttribute("id") === attrId;
                };
              };
              Expr.find["ID"] = function(id, context) {
                if (typeof context.getElementById !== "undefined" && documentIsHTML) {
                  var elem = context.getElementById(id);
                  return elem ? [elem] : [];
                }
              };
            } else {
              Expr.filter["ID"] = function(id) {
                var attrId = id.replace(runescape, funescape);
                return function(elem) {
                  var node2 = typeof elem.getAttributeNode !== "undefined" && elem.getAttributeNode("id");
                  return node2 && node2.value === attrId;
                };
              };
              Expr.find["ID"] = function(id, context) {
                if (typeof context.getElementById !== "undefined" && documentIsHTML) {
                  var node2, i2, elems, elem = context.getElementById(id);
                  if (elem) {
                    node2 = elem.getAttributeNode("id");
                    if (node2 && node2.value === id) {
                      return [elem];
                    }
                    elems = context.getElementsByName(id);
                    i2 = 0;
                    while (elem = elems[i2++]) {
                      node2 = elem.getAttributeNode("id");
                      if (node2 && node2.value === id) {
                        return [elem];
                      }
                    }
                  }
                  return [];
                }
              };
            }
            Expr.find["TAG"] = support2.getElementsByTagName ? function(tag, context) {
              if (typeof context.getElementsByTagName !== "undefined") {
                return context.getElementsByTagName(tag);
              } else if (support2.qsa) {
                return context.querySelectorAll(tag);
              }
            } : function(tag, context) {
              var elem, tmp = [], i2 = 0, results = context.getElementsByTagName(tag);
              if (tag === "*") {
                while (elem = results[i2++]) {
                  if (elem.nodeType === 1) {
                    tmp.push(elem);
                  }
                }
                return tmp;
              }
              return results;
            };
            Expr.find["CLASS"] = support2.getElementsByClassName && function(className, context) {
              if (typeof context.getElementsByClassName !== "undefined" && documentIsHTML) {
                return context.getElementsByClassName(className);
              }
            };
            rbuggyMatches = [];
            rbuggyQSA = [];
            if (support2.qsa = rnative.test(document3.querySelectorAll)) {
              assert(function(el) {
                var input;
                docElem.appendChild(el).innerHTML = "<a id='" + expando + "'></a><select id='" + expando + "-\r\\' msallowcapture=''><option selected=''></option></select>";
                if (el.querySelectorAll("[msallowcapture^='']").length) {
                  rbuggyQSA.push("[*^$]=" + whitespace + `*(?:''|"")`);
                }
                if (!el.querySelectorAll("[selected]").length) {
                  rbuggyQSA.push("\\[" + whitespace + "*(?:value|" + booleans + ")");
                }
                if (!el.querySelectorAll("[id~=" + expando + "-]").length) {
                  rbuggyQSA.push("~=");
                }
                input = document3.createElement("input");
                input.setAttribute("name", "");
                el.appendChild(input);
                if (!el.querySelectorAll("[name='']").length) {
                  rbuggyQSA.push("\\[" + whitespace + "*name" + whitespace + "*=" + whitespace + `*(?:''|"")`);
                }
                if (!el.querySelectorAll(":checked").length) {
                  rbuggyQSA.push(":checked");
                }
                if (!el.querySelectorAll("a#" + expando + "+*").length) {
                  rbuggyQSA.push(".#.+[+~]");
                }
                el.querySelectorAll("\\\f");
                rbuggyQSA.push("[\\r\\n\\f]");
              });
              assert(function(el) {
                el.innerHTML = "<a href='' disabled='disabled'></a><select disabled='disabled'><option/></select>";
                var input = document3.createElement("input");
                input.setAttribute("type", "hidden");
                el.appendChild(input).setAttribute("name", "D");
                if (el.querySelectorAll("[name=d]").length) {
                  rbuggyQSA.push("name" + whitespace + "*[*^$|!~]?=");
                }
                if (el.querySelectorAll(":enabled").length !== 2) {
                  rbuggyQSA.push(":enabled", ":disabled");
                }
                docElem.appendChild(el).disabled = true;
                if (el.querySelectorAll(":disabled").length !== 2) {
                  rbuggyQSA.push(":enabled", ":disabled");
                }
                el.querySelectorAll("*,:x");
                rbuggyQSA.push(",.*:");
              });
            }
            if (support2.matchesSelector = rnative.test(matches = docElem.matches || docElem.webkitMatchesSelector || docElem.mozMatchesSelector || docElem.oMatchesSelector || docElem.msMatchesSelector)) {
              assert(function(el) {
                support2.disconnectedMatch = matches.call(el, "*");
                matches.call(el, "[s!='']:x");
                rbuggyMatches.push("!=", pseudos);
              });
            }
            rbuggyQSA = rbuggyQSA.length && new RegExp(rbuggyQSA.join("|"));
            rbuggyMatches = rbuggyMatches.length && new RegExp(rbuggyMatches.join("|"));
            hasCompare = rnative.test(docElem.compareDocumentPosition);
            contains = hasCompare || rnative.test(docElem.contains) ? function(a, b) {
              var adown = a.nodeType === 9 ? a.documentElement : a, bup = b && b.parentNode;
              return a === bup || !!(bup && bup.nodeType === 1 && (adown.contains ? adown.contains(bup) : a.compareDocumentPosition && a.compareDocumentPosition(bup) & 16));
            } : function(a, b) {
              if (b) {
                while (b = b.parentNode) {
                  if (b === a) {
                    return true;
                  }
                }
              }
              return false;
            };
            sortOrder = hasCompare ? function(a, b) {
              if (a === b) {
                hasDuplicate = true;
                return 0;
              }
              var compare = !a.compareDocumentPosition - !b.compareDocumentPosition;
              if (compare) {
                return compare;
              }
              compare = (a.ownerDocument || a) == (b.ownerDocument || b) ? a.compareDocumentPosition(b) : 1;
              if (compare & 1 || !support2.sortDetached && b.compareDocumentPosition(a) === compare) {
                if (a == document3 || a.ownerDocument == preferredDoc && contains(preferredDoc, a)) {
                  return -1;
                }
                if (b == document3 || b.ownerDocument == preferredDoc && contains(preferredDoc, b)) {
                  return 1;
                }
                return sortInput ? indexOf2(sortInput, a) - indexOf2(sortInput, b) : 0;
              }
              return compare & 4 ? -1 : 1;
            } : function(a, b) {
              if (a === b) {
                hasDuplicate = true;
                return 0;
              }
              var cur, i2 = 0, aup = a.parentNode, bup = b.parentNode, ap = [a], bp = [b];
              if (!aup || !bup) {
                return a == document3 ? -1 : b == document3 ? 1 : aup ? -1 : bup ? 1 : sortInput ? indexOf2(sortInput, a) - indexOf2(sortInput, b) : 0;
              } else if (aup === bup) {
                return siblingCheck(a, b);
              }
              cur = a;
              while (cur = cur.parentNode) {
                ap.unshift(cur);
              }
              cur = b;
              while (cur = cur.parentNode) {
                bp.unshift(cur);
              }
              while (ap[i2] === bp[i2]) {
                i2++;
              }
              return i2 ? siblingCheck(ap[i2], bp[i2]) : ap[i2] == preferredDoc ? -1 : bp[i2] == preferredDoc ? 1 : 0;
            };
            return document3;
          };
          Sizzle2.matches = function(expr, elements) {
            return Sizzle2(expr, null, null, elements);
          };
          Sizzle2.matchesSelector = function(elem, expr) {
            setDocument(elem);
            if (support2.matchesSelector && documentIsHTML && !nonnativeSelectorCache[expr + " "] && (!rbuggyMatches || !rbuggyMatches.test(expr)) && (!rbuggyQSA || !rbuggyQSA.test(expr))) {
              try {
                var ret = matches.call(elem, expr);
                if (ret || support2.disconnectedMatch || elem.document && elem.document.nodeType !== 11) {
                  return ret;
                }
              } catch (e) {
                nonnativeSelectorCache(expr, true);
              }
            }
            return Sizzle2(expr, document3, null, [elem]).length > 0;
          };
          Sizzle2.contains = function(context, elem) {
            if ((context.ownerDocument || context) != document3) {
              setDocument(context);
            }
            return contains(context, elem);
          };
          Sizzle2.attr = function(elem, name) {
            if ((elem.ownerDocument || elem) != document3) {
              setDocument(elem);
            }
            var fn = Expr.attrHandle[name.toLowerCase()], val = fn && hasOwn2.call(Expr.attrHandle, name.toLowerCase()) ? fn(elem, name, !documentIsHTML) : void 0;
            return val !== void 0 ? val : support2.attributes || !documentIsHTML ? elem.getAttribute(name) : (val = elem.getAttributeNode(name)) && val.specified ? val.value : null;
          };
          Sizzle2.escape = function(sel) {
            return (sel + "").replace(rcssescape, fcssescape);
          };
          Sizzle2.error = function(msg) {
            throw new Error("Syntax error, unrecognized expression: " + msg);
          };
          Sizzle2.uniqueSort = function(results) {
            var elem, duplicates = [], j = 0, i2 = 0;
            hasDuplicate = !support2.detectDuplicates;
            sortInput = !support2.sortStable && results.slice(0);
            results.sort(sortOrder);
            if (hasDuplicate) {
              while (elem = results[i2++]) {
                if (elem === results[i2]) {
                  j = duplicates.push(i2);
                }
              }
              while (j--) {
                results.splice(duplicates[j], 1);
              }
            }
            sortInput = null;
            return results;
          };
          getText = Sizzle2.getText = function(elem) {
            var node, ret = "", i2 = 0, nodeType = elem.nodeType;
            if (!nodeType) {
              while (node = elem[i2++]) {
                ret += getText(node);
              }
            } else if (nodeType === 1 || nodeType === 9 || nodeType === 11) {
              if (typeof elem.textContent === "string") {
                return elem.textContent;
              } else {
                for (elem = elem.firstChild; elem; elem = elem.nextSibling) {
                  ret += getText(elem);
                }
              }
            } else if (nodeType === 3 || nodeType === 4) {
              return elem.nodeValue;
            }
            return ret;
          };
          Expr = Sizzle2.selectors = {
            cacheLength: 50,
            createPseudo: markFunction,
            match: matchExpr,
            attrHandle: {},
            find: {},
            relative: {
              ">": { dir: "parentNode", first: true },
              " ": { dir: "parentNode" },
              "+": { dir: "previousSibling", first: true },
              "~": { dir: "previousSibling" }
            },
            preFilter: {
              "ATTR": function(match) {
                match[1] = match[1].replace(runescape, funescape);
                match[3] = (match[3] || match[4] || match[5] || "").replace(runescape, funescape);
                if (match[2] === "~=") {
                  match[3] = " " + match[3] + " ";
                }
                return match.slice(0, 4);
              },
              "CHILD": function(match) {
                match[1] = match[1].toLowerCase();
                if (match[1].slice(0, 3) === "nth") {
                  if (!match[3]) {
                    Sizzle2.error(match[0]);
                  }
                  match[4] = +(match[4] ? match[5] + (match[6] || 1) : 2 * (match[3] === "even" || match[3] === "odd"));
                  match[5] = +(match[7] + match[8] || match[3] === "odd");
                } else if (match[3]) {
                  Sizzle2.error(match[0]);
                }
                return match;
              },
              "PSEUDO": function(match) {
                var excess, unquoted = !match[6] && match[2];
                if (matchExpr["CHILD"].test(match[0])) {
                  return null;
                }
                if (match[3]) {
                  match[2] = match[4] || match[5] || "";
                } else if (unquoted && rpseudo.test(unquoted) && (excess = tokenize(unquoted, true)) && (excess = unquoted.indexOf(")", unquoted.length - excess) - unquoted.length)) {
                  match[0] = match[0].slice(0, excess);
                  match[2] = unquoted.slice(0, excess);
                }
                return match.slice(0, 3);
              }
            },
            filter: {
              "TAG": function(nodeNameSelector) {
                var nodeName2 = nodeNameSelector.replace(runescape, funescape).toLowerCase();
                return nodeNameSelector === "*" ? function() {
                  return true;
                } : function(elem) {
                  return elem.nodeName && elem.nodeName.toLowerCase() === nodeName2;
                };
              },
              "CLASS": function(className) {
                var pattern = classCache[className + " "];
                return pattern || (pattern = new RegExp("(^|" + whitespace + ")" + className + "(" + whitespace + "|$)")) && classCache(className, function(elem) {
                  return pattern.test(typeof elem.className === "string" && elem.className || typeof elem.getAttribute !== "undefined" && elem.getAttribute("class") || "");
                });
              },
              "ATTR": function(name, operator, check) {
                return function(elem) {
                  var result = Sizzle2.attr(elem, name);
                  if (result == null) {
                    return operator === "!=";
                  }
                  if (!operator) {
                    return true;
                  }
                  result += "";
                  return operator === "=" ? result === check : operator === "!=" ? result !== check : operator === "^=" ? check && result.indexOf(check) === 0 : operator === "*=" ? check && result.indexOf(check) > -1 : operator === "$=" ? check && result.slice(-check.length) === check : operator === "~=" ? (" " + result.replace(rwhitespace, " ") + " ").indexOf(check) > -1 : operator === "|=" ? result === check || result.slice(0, check.length + 1) === check + "-" : false;
                };
              },
              "CHILD": function(type, what, _argument, first, last) {
                var simple = type.slice(0, 3) !== "nth", forward = type.slice(-4) !== "last", ofType = what === "of-type";
                return first === 1 && last === 0 ? function(elem) {
                  return !!elem.parentNode;
                } : function(elem, _context, xml) {
                  var cache, uniqueCache, outerCache, node, nodeIndex, start, dir2 = simple !== forward ? "nextSibling" : "previousSibling", parent = elem.parentNode, name = ofType && elem.nodeName.toLowerCase(), useCache = !xml && !ofType, diff = false;
                  if (parent) {
                    if (simple) {
                      while (dir2) {
                        node = elem;
                        while (node = node[dir2]) {
                          if (ofType ? node.nodeName.toLowerCase() === name : node.nodeType === 1) {
                            return false;
                          }
                        }
                        start = dir2 = type === "only" && !start && "nextSibling";
                      }
                      return true;
                    }
                    start = [forward ? parent.firstChild : parent.lastChild];
                    if (forward && useCache) {
                      node = parent;
                      outerCache = node[expando] || (node[expando] = {});
                      uniqueCache = outerCache[node.uniqueID] || (outerCache[node.uniqueID] = {});
                      cache = uniqueCache[type] || [];
                      nodeIndex = cache[0] === dirruns && cache[1];
                      diff = nodeIndex && cache[2];
                      node = nodeIndex && parent.childNodes[nodeIndex];
                      while (node = ++nodeIndex && node && node[dir2] || (diff = nodeIndex = 0) || start.pop()) {
                        if (node.nodeType === 1 && ++diff && node === elem) {
                          uniqueCache[type] = [dirruns, nodeIndex, diff];
                          break;
                        }
                      }
                    } else {
                      if (useCache) {
                        node = elem;
                        outerCache = node[expando] || (node[expando] = {});
                        uniqueCache = outerCache[node.uniqueID] || (outerCache[node.uniqueID] = {});
                        cache = uniqueCache[type] || [];
                        nodeIndex = cache[0] === dirruns && cache[1];
                        diff = nodeIndex;
                      }
                      if (diff === false) {
                        while (node = ++nodeIndex && node && node[dir2] || (diff = nodeIndex = 0) || start.pop()) {
                          if ((ofType ? node.nodeName.toLowerCase() === name : node.nodeType === 1) && ++diff) {
                            if (useCache) {
                              outerCache = node[expando] || (node[expando] = {});
                              uniqueCache = outerCache[node.uniqueID] || (outerCache[node.uniqueID] = {});
                              uniqueCache[type] = [dirruns, diff];
                            }
                            if (node === elem) {
                              break;
                            }
                          }
                        }
                      }
                    }
                    diff -= last;
                    return diff === first || diff % first === 0 && diff / first >= 0;
                  }
                };
              },
              "PSEUDO": function(pseudo, argument) {
                var args, fn = Expr.pseudos[pseudo] || Expr.setFilters[pseudo.toLowerCase()] || Sizzle2.error("unsupported pseudo: " + pseudo);
                if (fn[expando]) {
                  return fn(argument);
                }
                if (fn.length > 1) {
                  args = [pseudo, pseudo, "", argument];
                  return Expr.setFilters.hasOwnProperty(pseudo.toLowerCase()) ? markFunction(function(seed, matches2) {
                    var idx, matched = fn(seed, argument), i2 = matched.length;
                    while (i2--) {
                      idx = indexOf2(seed, matched[i2]);
                      seed[idx] = !(matches2[idx] = matched[i2]);
                    }
                  }) : function(elem) {
                    return fn(elem, 0, args);
                  };
                }
                return fn;
              }
            },
            pseudos: {
              "not": markFunction(function(selector) {
                var input = [], results = [], matcher = compile(selector.replace(rtrim2, "$1"));
                return matcher[expando] ? markFunction(function(seed, matches2, _context, xml) {
                  var elem, unmatched = matcher(seed, null, xml, []), i2 = seed.length;
                  while (i2--) {
                    if (elem = unmatched[i2]) {
                      seed[i2] = !(matches2[i2] = elem);
                    }
                  }
                }) : function(elem, _context, xml) {
                  input[0] = elem;
                  matcher(input, null, xml, results);
                  input[0] = null;
                  return !results.pop();
                };
              }),
              "has": markFunction(function(selector) {
                return function(elem) {
                  return Sizzle2(selector, elem).length > 0;
                };
              }),
              "contains": markFunction(function(text) {
                text = text.replace(runescape, funescape);
                return function(elem) {
                  return (elem.textContent || getText(elem)).indexOf(text) > -1;
                };
              }),
              "lang": markFunction(function(lang) {
                if (!ridentifier.test(lang || "")) {
                  Sizzle2.error("unsupported lang: " + lang);
                }
                lang = lang.replace(runescape, funescape).toLowerCase();
                return function(elem) {
                  var elemLang;
                  do {
                    if (elemLang = documentIsHTML ? elem.lang : elem.getAttribute("xml:lang") || elem.getAttribute("lang")) {
                      elemLang = elemLang.toLowerCase();
                      return elemLang === lang || elemLang.indexOf(lang + "-") === 0;
                    }
                  } while ((elem = elem.parentNode) && elem.nodeType === 1);
                  return false;
                };
              }),
              "target": function(elem) {
                var hash = window3.location && window3.location.hash;
                return hash && hash.slice(1) === elem.id;
              },
              "root": function(elem) {
                return elem === docElem;
              },
              "focus": function(elem) {
                return elem === document3.activeElement && (!document3.hasFocus || document3.hasFocus()) && !!(elem.type || elem.href || ~elem.tabIndex);
              },
              "enabled": createDisabledPseudo(false),
              "disabled": createDisabledPseudo(true),
              "checked": function(elem) {
                var nodeName2 = elem.nodeName.toLowerCase();
                return nodeName2 === "input" && !!elem.checked || nodeName2 === "option" && !!elem.selected;
              },
              "selected": function(elem) {
                if (elem.parentNode) {
                  elem.parentNode.selectedIndex;
                }
                return elem.selected === true;
              },
              "empty": function(elem) {
                for (elem = elem.firstChild; elem; elem = elem.nextSibling) {
                  if (elem.nodeType < 6) {
                    return false;
                  }
                }
                return true;
              },
              "parent": function(elem) {
                return !Expr.pseudos["empty"](elem);
              },
              "header": function(elem) {
                return rheader.test(elem.nodeName);
              },
              "input": function(elem) {
                return rinputs.test(elem.nodeName);
              },
              "button": function(elem) {
                var name = elem.nodeName.toLowerCase();
                return name === "input" && elem.type === "button" || name === "button";
              },
              "text": function(elem) {
                var attr;
                return elem.nodeName.toLowerCase() === "input" && elem.type === "text" && ((attr = elem.getAttribute("type")) == null || attr.toLowerCase() === "text");
              },
              "first": createPositionalPseudo(function() {
                return [0];
              }),
              "last": createPositionalPseudo(function(_matchIndexes, length) {
                return [length - 1];
              }),
              "eq": createPositionalPseudo(function(_matchIndexes, length, argument) {
                return [argument < 0 ? argument + length : argument];
              }),
              "even": createPositionalPseudo(function(matchIndexes, length) {
                var i2 = 0;
                for (; i2 < length; i2 += 2) {
                  matchIndexes.push(i2);
                }
                return matchIndexes;
              }),
              "odd": createPositionalPseudo(function(matchIndexes, length) {
                var i2 = 1;
                for (; i2 < length; i2 += 2) {
                  matchIndexes.push(i2);
                }
                return matchIndexes;
              }),
              "lt": createPositionalPseudo(function(matchIndexes, length, argument) {
                var i2 = argument < 0 ? argument + length : argument > length ? length : argument;
                for (; --i2 >= 0; ) {
                  matchIndexes.push(i2);
                }
                return matchIndexes;
              }),
              "gt": createPositionalPseudo(function(matchIndexes, length, argument) {
                var i2 = argument < 0 ? argument + length : argument;
                for (; ++i2 < length; ) {
                  matchIndexes.push(i2);
                }
                return matchIndexes;
              })
            }
          };
          Expr.pseudos["nth"] = Expr.pseudos["eq"];
          for (i in { radio: true, checkbox: true, file: true, password: true, image: true }) {
            Expr.pseudos[i] = createInputPseudo(i);
          }
          for (i in { submit: true, reset: true }) {
            Expr.pseudos[i] = createButtonPseudo(i);
          }
          function setFilters() {
          }
          setFilters.prototype = Expr.filters = Expr.pseudos;
          Expr.setFilters = new setFilters();
          tokenize = Sizzle2.tokenize = function(selector, parseOnly) {
            var matched, match, tokens, type, soFar, groups, preFilters, cached = tokenCache[selector + " "];
            if (cached) {
              return parseOnly ? 0 : cached.slice(0);
            }
            soFar = selector;
            groups = [];
            preFilters = Expr.preFilter;
            while (soFar) {
              if (!matched || (match = rcomma.exec(soFar))) {
                if (match) {
                  soFar = soFar.slice(match[0].length) || soFar;
                }
                groups.push(tokens = []);
              }
              matched = false;
              if (match = rcombinators.exec(soFar)) {
                matched = match.shift();
                tokens.push({
                  value: matched,
                  type: match[0].replace(rtrim2, " ")
                });
                soFar = soFar.slice(matched.length);
              }
              for (type in Expr.filter) {
                if ((match = matchExpr[type].exec(soFar)) && (!preFilters[type] || (match = preFilters[type](match)))) {
                  matched = match.shift();
                  tokens.push({
                    value: matched,
                    type,
                    matches: match
                  });
                  soFar = soFar.slice(matched.length);
                }
              }
              if (!matched) {
                break;
              }
            }
            return parseOnly ? soFar.length : soFar ? Sizzle2.error(selector) : tokenCache(selector, groups).slice(0);
          };
          function toSelector(tokens) {
            var i2 = 0, len = tokens.length, selector = "";
            for (; i2 < len; i2++) {
              selector += tokens[i2].value;
            }
            return selector;
          }
          function addCombinator(matcher, combinator, base) {
            var dir2 = combinator.dir, skip = combinator.next, key = skip || dir2, checkNonElements = base && key === "parentNode", doneName = done++;
            return combinator.first ? function(elem, context, xml) {
              while (elem = elem[dir2]) {
                if (elem.nodeType === 1 || checkNonElements) {
                  return matcher(elem, context, xml);
                }
              }
              return false;
            } : function(elem, context, xml) {
              var oldCache, uniqueCache, outerCache, newCache = [dirruns, doneName];
              if (xml) {
                while (elem = elem[dir2]) {
                  if (elem.nodeType === 1 || checkNonElements) {
                    if (matcher(elem, context, xml)) {
                      return true;
                    }
                  }
                }
              } else {
                while (elem = elem[dir2]) {
                  if (elem.nodeType === 1 || checkNonElements) {
                    outerCache = elem[expando] || (elem[expando] = {});
                    uniqueCache = outerCache[elem.uniqueID] || (outerCache[elem.uniqueID] = {});
                    if (skip && skip === elem.nodeName.toLowerCase()) {
                      elem = elem[dir2] || elem;
                    } else if ((oldCache = uniqueCache[key]) && oldCache[0] === dirruns && oldCache[1] === doneName) {
                      return newCache[2] = oldCache[2];
                    } else {
                      uniqueCache[key] = newCache;
                      if (newCache[2] = matcher(elem, context, xml)) {
                        return true;
                      }
                    }
                  }
                }
              }
              return false;
            };
          }
          function elementMatcher(matchers) {
            return matchers.length > 1 ? function(elem, context, xml) {
              var i2 = matchers.length;
              while (i2--) {
                if (!matchers[i2](elem, context, xml)) {
                  return false;
                }
              }
              return true;
            } : matchers[0];
          }
          function multipleContexts(selector, contexts, results) {
            var i2 = 0, len = contexts.length;
            for (; i2 < len; i2++) {
              Sizzle2(selector, contexts[i2], results);
            }
            return results;
          }
          function condense(unmatched, map, filter, context, xml) {
            var elem, newUnmatched = [], i2 = 0, len = unmatched.length, mapped = map != null;
            for (; i2 < len; i2++) {
              if (elem = unmatched[i2]) {
                if (!filter || filter(elem, context, xml)) {
                  newUnmatched.push(elem);
                  if (mapped) {
                    map.push(i2);
                  }
                }
              }
            }
            return newUnmatched;
          }
          function setMatcher(preFilter, selector, matcher, postFilter, postFinder, postSelector) {
            if (postFilter && !postFilter[expando]) {
              postFilter = setMatcher(postFilter);
            }
            if (postFinder && !postFinder[expando]) {
              postFinder = setMatcher(postFinder, postSelector);
            }
            return markFunction(function(seed, results, context, xml) {
              var temp, i2, elem, preMap = [], postMap = [], preexisting = results.length, elems = seed || multipleContexts(selector || "*", context.nodeType ? [context] : context, []), matcherIn = preFilter && (seed || !selector) ? condense(elems, preMap, preFilter, context, xml) : elems, matcherOut = matcher ? postFinder || (seed ? preFilter : preexisting || postFilter) ? [] : results : matcherIn;
              if (matcher) {
                matcher(matcherIn, matcherOut, context, xml);
              }
              if (postFilter) {
                temp = condense(matcherOut, postMap);
                postFilter(temp, [], context, xml);
                i2 = temp.length;
                while (i2--) {
                  if (elem = temp[i2]) {
                    matcherOut[postMap[i2]] = !(matcherIn[postMap[i2]] = elem);
                  }
                }
              }
              if (seed) {
                if (postFinder || preFilter) {
                  if (postFinder) {
                    temp = [];
                    i2 = matcherOut.length;
                    while (i2--) {
                      if (elem = matcherOut[i2]) {
                        temp.push(matcherIn[i2] = elem);
                      }
                    }
                    postFinder(null, matcherOut = [], temp, xml);
                  }
                  i2 = matcherOut.length;
                  while (i2--) {
                    if ((elem = matcherOut[i2]) && (temp = postFinder ? indexOf2(seed, elem) : preMap[i2]) > -1) {
                      seed[temp] = !(results[temp] = elem);
                    }
                  }
                }
              } else {
                matcherOut = condense(matcherOut === results ? matcherOut.splice(preexisting, matcherOut.length) : matcherOut);
                if (postFinder) {
                  postFinder(null, results, matcherOut, xml);
                } else {
                  push2.apply(results, matcherOut);
                }
              }
            });
          }
          function matcherFromTokens(tokens) {
            var checkContext, matcher, j, len = tokens.length, leadingRelative = Expr.relative[tokens[0].type], implicitRelative = leadingRelative || Expr.relative[" "], i2 = leadingRelative ? 1 : 0, matchContext = addCombinator(function(elem) {
              return elem === checkContext;
            }, implicitRelative, true), matchAnyContext = addCombinator(function(elem) {
              return indexOf2(checkContext, elem) > -1;
            }, implicitRelative, true), matchers = [function(elem, context, xml) {
              var ret = !leadingRelative && (xml || context !== outermostContext) || ((checkContext = context).nodeType ? matchContext(elem, context, xml) : matchAnyContext(elem, context, xml));
              checkContext = null;
              return ret;
            }];
            for (; i2 < len; i2++) {
              if (matcher = Expr.relative[tokens[i2].type]) {
                matchers = [addCombinator(elementMatcher(matchers), matcher)];
              } else {
                matcher = Expr.filter[tokens[i2].type].apply(null, tokens[i2].matches);
                if (matcher[expando]) {
                  j = ++i2;
                  for (; j < len; j++) {
                    if (Expr.relative[tokens[j].type]) {
                      break;
                    }
                  }
                  return setMatcher(i2 > 1 && elementMatcher(matchers), i2 > 1 && toSelector(tokens.slice(0, i2 - 1).concat({ value: tokens[i2 - 2].type === " " ? "*" : "" })).replace(rtrim2, "$1"), matcher, i2 < j && matcherFromTokens(tokens.slice(i2, j)), j < len && matcherFromTokens(tokens = tokens.slice(j)), j < len && toSelector(tokens));
                }
                matchers.push(matcher);
              }
            }
            return elementMatcher(matchers);
          }
          function matcherFromGroupMatchers(elementMatchers, setMatchers) {
            var bySet = setMatchers.length > 0, byElement = elementMatchers.length > 0, superMatcher = function(seed, context, xml, results, outermost) {
              var elem, j, matcher, matchedCount = 0, i2 = "0", unmatched = seed && [], setMatched = [], contextBackup = outermostContext, elems = seed || byElement && Expr.find["TAG"]("*", outermost), dirrunsUnique = dirruns += contextBackup == null ? 1 : Math.random() || 0.1, len = elems.length;
              if (outermost) {
                outermostContext = context == document3 || context || outermost;
              }
              for (; i2 !== len && (elem = elems[i2]) != null; i2++) {
                if (byElement && elem) {
                  j = 0;
                  if (!context && elem.ownerDocument != document3) {
                    setDocument(elem);
                    xml = !documentIsHTML;
                  }
                  while (matcher = elementMatchers[j++]) {
                    if (matcher(elem, context || document3, xml)) {
                      results.push(elem);
                      break;
                    }
                  }
                  if (outermost) {
                    dirruns = dirrunsUnique;
                  }
                }
                if (bySet) {
                  if (elem = !matcher && elem) {
                    matchedCount--;
                  }
                  if (seed) {
                    unmatched.push(elem);
                  }
                }
              }
              matchedCount += i2;
              if (bySet && i2 !== matchedCount) {
                j = 0;
                while (matcher = setMatchers[j++]) {
                  matcher(unmatched, setMatched, context, xml);
                }
                if (seed) {
                  if (matchedCount > 0) {
                    while (i2--) {
                      if (!(unmatched[i2] || setMatched[i2])) {
                        setMatched[i2] = pop.call(results);
                      }
                    }
                  }
                  setMatched = condense(setMatched);
                }
                push2.apply(results, setMatched);
                if (outermost && !seed && setMatched.length > 0 && matchedCount + setMatchers.length > 1) {
                  Sizzle2.uniqueSort(results);
                }
              }
              if (outermost) {
                dirruns = dirrunsUnique;
                outermostContext = contextBackup;
              }
              return unmatched;
            };
            return bySet ? markFunction(superMatcher) : superMatcher;
          }
          compile = Sizzle2.compile = function(selector, match) {
            var i2, setMatchers = [], elementMatchers = [], cached = compilerCache[selector + " "];
            if (!cached) {
              if (!match) {
                match = tokenize(selector);
              }
              i2 = match.length;
              while (i2--) {
                cached = matcherFromTokens(match[i2]);
                if (cached[expando]) {
                  setMatchers.push(cached);
                } else {
                  elementMatchers.push(cached);
                }
              }
              cached = compilerCache(selector, matcherFromGroupMatchers(elementMatchers, setMatchers));
              cached.selector = selector;
            }
            return cached;
          };
          select = Sizzle2.select = function(selector, context, results, seed) {
            var i2, tokens, token, type, find, compiled = typeof selector === "function" && selector, match = !seed && tokenize(selector = compiled.selector || selector);
            results = results || [];
            if (match.length === 1) {
              tokens = match[0] = match[0].slice(0);
              if (tokens.length > 2 && (token = tokens[0]).type === "ID" && context.nodeType === 9 && documentIsHTML && Expr.relative[tokens[1].type]) {
                context = (Expr.find["ID"](token.matches[0].replace(runescape, funescape), context) || [])[0];
                if (!context) {
                  return results;
                } else if (compiled) {
                  context = context.parentNode;
                }
                selector = selector.slice(tokens.shift().value.length);
              }
              i2 = matchExpr["needsContext"].test(selector) ? 0 : tokens.length;
              while (i2--) {
                token = tokens[i2];
                if (Expr.relative[type = token.type]) {
                  break;
                }
                if (find = Expr.find[type]) {
                  if (seed = find(token.matches[0].replace(runescape, funescape), rsibling.test(tokens[0].type) && testContext(context.parentNode) || context)) {
                    tokens.splice(i2, 1);
                    selector = seed.length && toSelector(tokens);
                    if (!selector) {
                      push2.apply(results, seed);
                      return results;
                    }
                    break;
                  }
                }
              }
            }
            (compiled || compile(selector, match))(seed, context, !documentIsHTML, results, !context || rsibling.test(selector) && testContext(context.parentNode) || context);
            return results;
          };
          support2.sortStable = expando.split("").sort(sortOrder).join("") === expando;
          support2.detectDuplicates = !!hasDuplicate;
          setDocument();
          support2.sortDetached = assert(function(el) {
            return el.compareDocumentPosition(document3.createElement("fieldset")) & 1;
          });
          if (!assert(function(el) {
            el.innerHTML = "<a href='#'></a>";
            return el.firstChild.getAttribute("href") === "#";
          })) {
            addHandle("type|href|height|width", function(elem, name, isXML2) {
              if (!isXML2) {
                return elem.getAttribute(name, name.toLowerCase() === "type" ? 1 : 2);
              }
            });
          }
          if (!support2.attributes || !assert(function(el) {
            el.innerHTML = "<input/>";
            el.firstChild.setAttribute("value", "");
            return el.firstChild.getAttribute("value") === "";
          })) {
            addHandle("value", function(elem, _name, isXML2) {
              if (!isXML2 && elem.nodeName.toLowerCase() === "input") {
                return elem.defaultValue;
              }
            });
          }
          if (!assert(function(el) {
            return el.getAttribute("disabled") == null;
          })) {
            addHandle(booleans, function(elem, name, isXML2) {
              var val;
              if (!isXML2) {
                return elem[name] === true ? name.toLowerCase() : (val = elem.getAttributeNode(name)) && val.specified ? val.value : null;
              }
            });
          }
          return Sizzle2;
        }(window2);
        jQuery2.find = Sizzle;
        jQuery2.expr = Sizzle.selectors;
        jQuery2.expr[":"] = jQuery2.expr.pseudos;
        jQuery2.uniqueSort = jQuery2.unique = Sizzle.uniqueSort;
        jQuery2.text = Sizzle.getText;
        jQuery2.isXMLDoc = Sizzle.isXML;
        jQuery2.contains = Sizzle.contains;
        jQuery2.escapeSelector = Sizzle.escape;
        var dir = function(elem, dir2, until) {
          var matched = [], truncate = until !== void 0;
          while ((elem = elem[dir2]) && elem.nodeType !== 9) {
            if (elem.nodeType === 1) {
              if (truncate && jQuery2(elem).is(until)) {
                break;
              }
              matched.push(elem);
            }
          }
          return matched;
        };
        var siblings = function(n, elem) {
          var matched = [];
          for (; n; n = n.nextSibling) {
            if (n.nodeType === 1 && n !== elem) {
              matched.push(n);
            }
          }
          return matched;
        };
        var rneedsContext = jQuery2.expr.match.needsContext;
        function nodeName(elem, name) {
          return elem.nodeName && elem.nodeName.toLowerCase() === name.toLowerCase();
        }
        var rsingleTag = /^<([a-z][^\/\0>:\x20\t\r\n\f]*)[\x20\t\r\n\f]*\/?>(?:<\/\1>|)$/i;
        function winnow(elements, qualifier, not) {
          if (isFunction(qualifier)) {
            return jQuery2.grep(elements, function(elem, i) {
              return !!qualifier.call(elem, i, elem) !== not;
            });
          }
          if (qualifier.nodeType) {
            return jQuery2.grep(elements, function(elem) {
              return elem === qualifier !== not;
            });
          }
          if (typeof qualifier !== "string") {
            return jQuery2.grep(elements, function(elem) {
              return indexOf.call(qualifier, elem) > -1 !== not;
            });
          }
          return jQuery2.filter(qualifier, elements, not);
        }
        jQuery2.filter = function(expr, elems, not) {
          var elem = elems[0];
          if (not) {
            expr = ":not(" + expr + ")";
          }
          if (elems.length === 1 && elem.nodeType === 1) {
            return jQuery2.find.matchesSelector(elem, expr) ? [elem] : [];
          }
          return jQuery2.find.matches(expr, jQuery2.grep(elems, function(elem2) {
            return elem2.nodeType === 1;
          }));
        };
        jQuery2.fn.extend({
          find: function(selector) {
            var i, ret, len = this.length, self2 = this;
            if (typeof selector !== "string") {
              return this.pushStack(jQuery2(selector).filter(function() {
                for (i = 0; i < len; i++) {
                  if (jQuery2.contains(self2[i], this)) {
                    return true;
                  }
                }
              }));
            }
            ret = this.pushStack([]);
            for (i = 0; i < len; i++) {
              jQuery2.find(selector, self2[i], ret);
            }
            return len > 1 ? jQuery2.uniqueSort(ret) : ret;
          },
          filter: function(selector) {
            return this.pushStack(winnow(this, selector || [], false));
          },
          not: function(selector) {
            return this.pushStack(winnow(this, selector || [], true));
          },
          is: function(selector) {
            return !!winnow(this, typeof selector === "string" && rneedsContext.test(selector) ? jQuery2(selector) : selector || [], false).length;
          }
        });
        var rootjQuery, rquickExpr = /^(?:\s*(<[\w\W]+>)[^>]*|#([\w-]+))$/, init = jQuery2.fn.init = function(selector, context, root) {
          var match, elem;
          if (!selector) {
            return this;
          }
          root = root || rootjQuery;
          if (typeof selector === "string") {
            if (selector[0] === "<" && selector[selector.length - 1] === ">" && selector.length >= 3) {
              match = [null, selector, null];
            } else {
              match = rquickExpr.exec(selector);
            }
            if (match && (match[1] || !context)) {
              if (match[1]) {
                context = context instanceof jQuery2 ? context[0] : context;
                jQuery2.merge(this, jQuery2.parseHTML(match[1], context && context.nodeType ? context.ownerDocument || context : document2, true));
                if (rsingleTag.test(match[1]) && jQuery2.isPlainObject(context)) {
                  for (match in context) {
                    if (isFunction(this[match])) {
                      this[match](context[match]);
                    } else {
                      this.attr(match, context[match]);
                    }
                  }
                }
                return this;
              } else {
                elem = document2.getElementById(match[2]);
                if (elem) {
                  this[0] = elem;
                  this.length = 1;
                }
                return this;
              }
            } else if (!context || context.jquery) {
              return (context || root).find(selector);
            } else {
              return this.constructor(context).find(selector);
            }
          } else if (selector.nodeType) {
            this[0] = selector;
            this.length = 1;
            return this;
          } else if (isFunction(selector)) {
            return root.ready !== void 0 ? root.ready(selector) : selector(jQuery2);
          }
          return jQuery2.makeArray(selector, this);
        };
        init.prototype = jQuery2.fn;
        rootjQuery = jQuery2(document2);
        var rparentsprev = /^(?:parents|prev(?:Until|All))/, guaranteedUnique = {
          children: true,
          contents: true,
          next: true,
          prev: true
        };
        jQuery2.fn.extend({
          has: function(target) {
            var targets = jQuery2(target, this), l = targets.length;
            return this.filter(function() {
              var i = 0;
              for (; i < l; i++) {
                if (jQuery2.contains(this, targets[i])) {
                  return true;
                }
              }
            });
          },
          closest: function(selectors, context) {
            var cur, i = 0, l = this.length, matched = [], targets = typeof selectors !== "string" && jQuery2(selectors);
            if (!rneedsContext.test(selectors)) {
              for (; i < l; i++) {
                for (cur = this[i]; cur && cur !== context; cur = cur.parentNode) {
                  if (cur.nodeType < 11 && (targets ? targets.index(cur) > -1 : cur.nodeType === 1 && jQuery2.find.matchesSelector(cur, selectors))) {
                    matched.push(cur);
                    break;
                  }
                }
              }
            }
            return this.pushStack(matched.length > 1 ? jQuery2.uniqueSort(matched) : matched);
          },
          index: function(elem) {
            if (!elem) {
              return this[0] && this[0].parentNode ? this.first().prevAll().length : -1;
            }
            if (typeof elem === "string") {
              return indexOf.call(jQuery2(elem), this[0]);
            }
            return indexOf.call(this, elem.jquery ? elem[0] : elem);
          },
          add: function(selector, context) {
            return this.pushStack(jQuery2.uniqueSort(jQuery2.merge(this.get(), jQuery2(selector, context))));
          },
          addBack: function(selector) {
            return this.add(selector == null ? this.prevObject : this.prevObject.filter(selector));
          }
        });
        function sibling(cur, dir2) {
          while ((cur = cur[dir2]) && cur.nodeType !== 1) {
          }
          return cur;
        }
        jQuery2.each({
          parent: function(elem) {
            var parent = elem.parentNode;
            return parent && parent.nodeType !== 11 ? parent : null;
          },
          parents: function(elem) {
            return dir(elem, "parentNode");
          },
          parentsUntil: function(elem, _i, until) {
            return dir(elem, "parentNode", until);
          },
          next: function(elem) {
            return sibling(elem, "nextSibling");
          },
          prev: function(elem) {
            return sibling(elem, "previousSibling");
          },
          nextAll: function(elem) {
            return dir(elem, "nextSibling");
          },
          prevAll: function(elem) {
            return dir(elem, "previousSibling");
          },
          nextUntil: function(elem, _i, until) {
            return dir(elem, "nextSibling", until);
          },
          prevUntil: function(elem, _i, until) {
            return dir(elem, "previousSibling", until);
          },
          siblings: function(elem) {
            return siblings((elem.parentNode || {}).firstChild, elem);
          },
          children: function(elem) {
            return siblings(elem.firstChild);
          },
          contents: function(elem) {
            if (elem.contentDocument != null && getProto(elem.contentDocument)) {
              return elem.contentDocument;
            }
            if (nodeName(elem, "template")) {
              elem = elem.content || elem;
            }
            return jQuery2.merge([], elem.childNodes);
          }
        }, function(name, fn) {
          jQuery2.fn[name] = function(until, selector) {
            var matched = jQuery2.map(this, fn, until);
            if (name.slice(-5) !== "Until") {
              selector = until;
            }
            if (selector && typeof selector === "string") {
              matched = jQuery2.filter(selector, matched);
            }
            if (this.length > 1) {
              if (!guaranteedUnique[name]) {
                jQuery2.uniqueSort(matched);
              }
              if (rparentsprev.test(name)) {
                matched.reverse();
              }
            }
            return this.pushStack(matched);
          };
        });
        var rnothtmlwhite = /[^\x20\t\r\n\f]+/g;
        function createOptions(options) {
          var object = {};
          jQuery2.each(options.match(rnothtmlwhite) || [], function(_, flag) {
            object[flag] = true;
          });
          return object;
        }
        jQuery2.Callbacks = function(options) {
          options = typeof options === "string" ? createOptions(options) : jQuery2.extend({}, options);
          var firing, memory, fired, locked, list = [], queue = [], firingIndex = -1, fire = function() {
            locked = locked || options.once;
            fired = firing = true;
            for (; queue.length; firingIndex = -1) {
              memory = queue.shift();
              while (++firingIndex < list.length) {
                if (list[firingIndex].apply(memory[0], memory[1]) === false && options.stopOnFalse) {
                  firingIndex = list.length;
                  memory = false;
                }
              }
            }
            if (!options.memory) {
              memory = false;
            }
            firing = false;
            if (locked) {
              if (memory) {
                list = [];
              } else {
                list = "";
              }
            }
          }, self2 = {
            add: function() {
              if (list) {
                if (memory && !firing) {
                  firingIndex = list.length - 1;
                  queue.push(memory);
                }
                (function add(args) {
                  jQuery2.each(args, function(_, arg) {
                    if (isFunction(arg)) {
                      if (!options.unique || !self2.has(arg)) {
                        list.push(arg);
                      }
                    } else if (arg && arg.length && toType(arg) !== "string") {
                      add(arg);
                    }
                  });
                })(arguments);
                if (memory && !firing) {
                  fire();
                }
              }
              return this;
            },
            remove: function() {
              jQuery2.each(arguments, function(_, arg) {
                var index;
                while ((index = jQuery2.inArray(arg, list, index)) > -1) {
                  list.splice(index, 1);
                  if (index <= firingIndex) {
                    firingIndex--;
                  }
                }
              });
              return this;
            },
            has: function(fn) {
              return fn ? jQuery2.inArray(fn, list) > -1 : list.length > 0;
            },
            empty: function() {
              if (list) {
                list = [];
              }
              return this;
            },
            disable: function() {
              locked = queue = [];
              list = memory = "";
              return this;
            },
            disabled: function() {
              return !list;
            },
            lock: function() {
              locked = queue = [];
              if (!memory && !firing) {
                list = memory = "";
              }
              return this;
            },
            locked: function() {
              return !!locked;
            },
            fireWith: function(context, args) {
              if (!locked) {
                args = args || [];
                args = [context, args.slice ? args.slice() : args];
                queue.push(args);
                if (!firing) {
                  fire();
                }
              }
              return this;
            },
            fire: function() {
              self2.fireWith(this, arguments);
              return this;
            },
            fired: function() {
              return !!fired;
            }
          };
          return self2;
        };
        function Identity(v) {
          return v;
        }
        function Thrower(ex) {
          throw ex;
        }
        function adoptValue(value, resolve, reject, noValue) {
          var method;
          try {
            if (value && isFunction(method = value.promise)) {
              method.call(value).done(resolve).fail(reject);
            } else if (value && isFunction(method = value.then)) {
              method.call(value, resolve, reject);
            } else {
              resolve.apply(void 0, [value].slice(noValue));
            }
          } catch (value2) {
            reject.apply(void 0, [value2]);
          }
        }
        jQuery2.extend({
          Deferred: function(func) {
            var tuples = [
              [
                "notify",
                "progress",
                jQuery2.Callbacks("memory"),
                jQuery2.Callbacks("memory"),
                2
              ],
              [
                "resolve",
                "done",
                jQuery2.Callbacks("once memory"),
                jQuery2.Callbacks("once memory"),
                0,
                "resolved"
              ],
              [
                "reject",
                "fail",
                jQuery2.Callbacks("once memory"),
                jQuery2.Callbacks("once memory"),
                1,
                "rejected"
              ]
            ], state = "pending", promise = {
              state: function() {
                return state;
              },
              always: function() {
                deferred.done(arguments).fail(arguments);
                return this;
              },
              "catch": function(fn) {
                return promise.then(null, fn);
              },
              pipe: function() {
                var fns = arguments;
                return jQuery2.Deferred(function(newDefer) {
                  jQuery2.each(tuples, function(_i, tuple) {
                    var fn = isFunction(fns[tuple[4]]) && fns[tuple[4]];
                    deferred[tuple[1]](function() {
                      var returned = fn && fn.apply(this, arguments);
                      if (returned && isFunction(returned.promise)) {
                        returned.promise().progress(newDefer.notify).done(newDefer.resolve).fail(newDefer.reject);
                      } else {
                        newDefer[tuple[0] + "With"](this, fn ? [returned] : arguments);
                      }
                    });
                  });
                  fns = null;
                }).promise();
              },
              then: function(onFulfilled, onRejected, onProgress) {
                var maxDepth = 0;
                function resolve(depth, deferred2, handler, special) {
                  return function() {
                    var that = this, args = arguments, mightThrow = function() {
                      var returned, then;
                      if (depth < maxDepth) {
                        return;
                      }
                      returned = handler.apply(that, args);
                      if (returned === deferred2.promise()) {
                        throw new TypeError("Thenable self-resolution");
                      }
                      then = returned && (typeof returned === "object" || typeof returned === "function") && returned.then;
                      if (isFunction(then)) {
                        if (special) {
                          then.call(returned, resolve(maxDepth, deferred2, Identity, special), resolve(maxDepth, deferred2, Thrower, special));
                        } else {
                          maxDepth++;
                          then.call(returned, resolve(maxDepth, deferred2, Identity, special), resolve(maxDepth, deferred2, Thrower, special), resolve(maxDepth, deferred2, Identity, deferred2.notifyWith));
                        }
                      } else {
                        if (handler !== Identity) {
                          that = void 0;
                          args = [returned];
                        }
                        (special || deferred2.resolveWith)(that, args);
                      }
                    }, process = special ? mightThrow : function() {
                      try {
                        mightThrow();
                      } catch (e) {
                        if (jQuery2.Deferred.exceptionHook) {
                          jQuery2.Deferred.exceptionHook(e, process.stackTrace);
                        }
                        if (depth + 1 >= maxDepth) {
                          if (handler !== Thrower) {
                            that = void 0;
                            args = [e];
                          }
                          deferred2.rejectWith(that, args);
                        }
                      }
                    };
                    if (depth) {
                      process();
                    } else {
                      if (jQuery2.Deferred.getStackHook) {
                        process.stackTrace = jQuery2.Deferred.getStackHook();
                      }
                      window2.setTimeout(process);
                    }
                  };
                }
                return jQuery2.Deferred(function(newDefer) {
                  tuples[0][3].add(resolve(0, newDefer, isFunction(onProgress) ? onProgress : Identity, newDefer.notifyWith));
                  tuples[1][3].add(resolve(0, newDefer, isFunction(onFulfilled) ? onFulfilled : Identity));
                  tuples[2][3].add(resolve(0, newDefer, isFunction(onRejected) ? onRejected : Thrower));
                }).promise();
              },
              promise: function(obj) {
                return obj != null ? jQuery2.extend(obj, promise) : promise;
              }
            }, deferred = {};
            jQuery2.each(tuples, function(i, tuple) {
              var list = tuple[2], stateString = tuple[5];
              promise[tuple[1]] = list.add;
              if (stateString) {
                list.add(function() {
                  state = stateString;
                }, tuples[3 - i][2].disable, tuples[3 - i][3].disable, tuples[0][2].lock, tuples[0][3].lock);
              }
              list.add(tuple[3].fire);
              deferred[tuple[0]] = function() {
                deferred[tuple[0] + "With"](this === deferred ? void 0 : this, arguments);
                return this;
              };
              deferred[tuple[0] + "With"] = list.fireWith;
            });
            promise.promise(deferred);
            if (func) {
              func.call(deferred, deferred);
            }
            return deferred;
          },
          when: function(singleValue) {
            var remaining = arguments.length, i = remaining, resolveContexts = Array(i), resolveValues = slice.call(arguments), primary = jQuery2.Deferred(), updateFunc = function(i2) {
              return function(value) {
                resolveContexts[i2] = this;
                resolveValues[i2] = arguments.length > 1 ? slice.call(arguments) : value;
                if (!--remaining) {
                  primary.resolveWith(resolveContexts, resolveValues);
                }
              };
            };
            if (remaining <= 1) {
              adoptValue(singleValue, primary.done(updateFunc(i)).resolve, primary.reject, !remaining);
              if (primary.state() === "pending" || isFunction(resolveValues[i] && resolveValues[i].then)) {
                return primary.then();
              }
            }
            while (i--) {
              adoptValue(resolveValues[i], updateFunc(i), primary.reject);
            }
            return primary.promise();
          }
        });
        var rerrorNames = /^(Eval|Internal|Range|Reference|Syntax|Type|URI)Error$/;
        jQuery2.Deferred.exceptionHook = function(error, stack) {
          if (window2.console && window2.console.warn && error && rerrorNames.test(error.name)) {
            window2.console.warn("jQuery.Deferred exception: " + error.message, error.stack, stack);
          }
        };
        jQuery2.readyException = function(error) {
          window2.setTimeout(function() {
            throw error;
          });
        };
        var readyList = jQuery2.Deferred();
        jQuery2.fn.ready = function(fn) {
          readyList.then(fn).catch(function(error) {
            jQuery2.readyException(error);
          });
          return this;
        };
        jQuery2.extend({
          isReady: false,
          readyWait: 1,
          ready: function(wait) {
            if (wait === true ? --jQuery2.readyWait : jQuery2.isReady) {
              return;
            }
            jQuery2.isReady = true;
            if (wait !== true && --jQuery2.readyWait > 0) {
              return;
            }
            readyList.resolveWith(document2, [jQuery2]);
          }
        });
        jQuery2.ready.then = readyList.then;
        function completed() {
          document2.removeEventListener("DOMContentLoaded", completed);
          window2.removeEventListener("load", completed);
          jQuery2.ready();
        }
        if (document2.readyState === "complete" || document2.readyState !== "loading" && !document2.documentElement.doScroll) {
          window2.setTimeout(jQuery2.ready);
        } else {
          document2.addEventListener("DOMContentLoaded", completed);
          window2.addEventListener("load", completed);
        }
        var access = function(elems, fn, key, value, chainable, emptyGet, raw) {
          var i = 0, len = elems.length, bulk = key == null;
          if (toType(key) === "object") {
            chainable = true;
            for (i in key) {
              access(elems, fn, i, key[i], true, emptyGet, raw);
            }
          } else if (value !== void 0) {
            chainable = true;
            if (!isFunction(value)) {
              raw = true;
            }
            if (bulk) {
              if (raw) {
                fn.call(elems, value);
                fn = null;
              } else {
                bulk = fn;
                fn = function(elem, _key, value2) {
                  return bulk.call(jQuery2(elem), value2);
                };
              }
            }
            if (fn) {
              for (; i < len; i++) {
                fn(elems[i], key, raw ? value : value.call(elems[i], i, fn(elems[i], key)));
              }
            }
          }
          if (chainable) {
            return elems;
          }
          if (bulk) {
            return fn.call(elems);
          }
          return len ? fn(elems[0], key) : emptyGet;
        };
        var rmsPrefix = /^-ms-/, rdashAlpha = /-([a-z])/g;
        function fcamelCase(_all, letter) {
          return letter.toUpperCase();
        }
        function camelCase(string) {
          return string.replace(rmsPrefix, "ms-").replace(rdashAlpha, fcamelCase);
        }
        var acceptData = function(owner) {
          return owner.nodeType === 1 || owner.nodeType === 9 || !+owner.nodeType;
        };
        function Data() {
          this.expando = jQuery2.expando + Data.uid++;
        }
        Data.uid = 1;
        Data.prototype = {
          cache: function(owner) {
            var value = owner[this.expando];
            if (!value) {
              value = {};
              if (acceptData(owner)) {
                if (owner.nodeType) {
                  owner[this.expando] = value;
                } else {
                  Object.defineProperty(owner, this.expando, {
                    value,
                    configurable: true
                  });
                }
              }
            }
            return value;
          },
          set: function(owner, data, value) {
            var prop, cache = this.cache(owner);
            if (typeof data === "string") {
              cache[camelCase(data)] = value;
            } else {
              for (prop in data) {
                cache[camelCase(prop)] = data[prop];
              }
            }
            return cache;
          },
          get: function(owner, key) {
            return key === void 0 ? this.cache(owner) : owner[this.expando] && owner[this.expando][camelCase(key)];
          },
          access: function(owner, key, value) {
            if (key === void 0 || key && typeof key === "string" && value === void 0) {
              return this.get(owner, key);
            }
            this.set(owner, key, value);
            return value !== void 0 ? value : key;
          },
          remove: function(owner, key) {
            var i, cache = owner[this.expando];
            if (cache === void 0) {
              return;
            }
            if (key !== void 0) {
              if (Array.isArray(key)) {
                key = key.map(camelCase);
              } else {
                key = camelCase(key);
                key = key in cache ? [key] : key.match(rnothtmlwhite) || [];
              }
              i = key.length;
              while (i--) {
                delete cache[key[i]];
              }
            }
            if (key === void 0 || jQuery2.isEmptyObject(cache)) {
              if (owner.nodeType) {
                owner[this.expando] = void 0;
              } else {
                delete owner[this.expando];
              }
            }
          },
          hasData: function(owner) {
            var cache = owner[this.expando];
            return cache !== void 0 && !jQuery2.isEmptyObject(cache);
          }
        };
        var dataPriv = new Data();
        var dataUser = new Data();
        var rbrace = /^(?:\{[\w\W]*\}|\[[\w\W]*\])$/, rmultiDash = /[A-Z]/g;
        function getData(data) {
          if (data === "true") {
            return true;
          }
          if (data === "false") {
            return false;
          }
          if (data === "null") {
            return null;
          }
          if (data === +data + "") {
            return +data;
          }
          if (rbrace.test(data)) {
            return JSON.parse(data);
          }
          return data;
        }
        function dataAttr(elem, key, data) {
          var name;
          if (data === void 0 && elem.nodeType === 1) {
            name = "data-" + key.replace(rmultiDash, "-$&").toLowerCase();
            data = elem.getAttribute(name);
            if (typeof data === "string") {
              try {
                data = getData(data);
              } catch (e) {
              }
              dataUser.set(elem, key, data);
            } else {
              data = void 0;
            }
          }
          return data;
        }
        jQuery2.extend({
          hasData: function(elem) {
            return dataUser.hasData(elem) || dataPriv.hasData(elem);
          },
          data: function(elem, name, data) {
            return dataUser.access(elem, name, data);
          },
          removeData: function(elem, name) {
            dataUser.remove(elem, name);
          },
          _data: function(elem, name, data) {
            return dataPriv.access(elem, name, data);
          },
          _removeData: function(elem, name) {
            dataPriv.remove(elem, name);
          }
        });
        jQuery2.fn.extend({
          data: function(key, value) {
            var i, name, data, elem = this[0], attrs = elem && elem.attributes;
            if (key === void 0) {
              if (this.length) {
                data = dataUser.get(elem);
                if (elem.nodeType === 1 && !dataPriv.get(elem, "hasDataAttrs")) {
                  i = attrs.length;
                  while (i--) {
                    if (attrs[i]) {
                      name = attrs[i].name;
                      if (name.indexOf("data-") === 0) {
                        name = camelCase(name.slice(5));
                        dataAttr(elem, name, data[name]);
                      }
                    }
                  }
                  dataPriv.set(elem, "hasDataAttrs", true);
                }
              }
              return data;
            }
            if (typeof key === "object") {
              return this.each(function() {
                dataUser.set(this, key);
              });
            }
            return access(this, function(value2) {
              var data2;
              if (elem && value2 === void 0) {
                data2 = dataUser.get(elem, key);
                if (data2 !== void 0) {
                  return data2;
                }
                data2 = dataAttr(elem, key);
                if (data2 !== void 0) {
                  return data2;
                }
                return;
              }
              this.each(function() {
                dataUser.set(this, key, value2);
              });
            }, null, value, arguments.length > 1, null, true);
          },
          removeData: function(key) {
            return this.each(function() {
              dataUser.remove(this, key);
            });
          }
        });
        jQuery2.extend({
          queue: function(elem, type, data) {
            var queue;
            if (elem) {
              type = (type || "fx") + "queue";
              queue = dataPriv.get(elem, type);
              if (data) {
                if (!queue || Array.isArray(data)) {
                  queue = dataPriv.access(elem, type, jQuery2.makeArray(data));
                } else {
                  queue.push(data);
                }
              }
              return queue || [];
            }
          },
          dequeue: function(elem, type) {
            type = type || "fx";
            var queue = jQuery2.queue(elem, type), startLength = queue.length, fn = queue.shift(), hooks = jQuery2._queueHooks(elem, type), next = function() {
              jQuery2.dequeue(elem, type);
            };
            if (fn === "inprogress") {
              fn = queue.shift();
              startLength--;
            }
            if (fn) {
              if (type === "fx") {
                queue.unshift("inprogress");
              }
              delete hooks.stop;
              fn.call(elem, next, hooks);
            }
            if (!startLength && hooks) {
              hooks.empty.fire();
            }
          },
          _queueHooks: function(elem, type) {
            var key = type + "queueHooks";
            return dataPriv.get(elem, key) || dataPriv.access(elem, key, {
              empty: jQuery2.Callbacks("once memory").add(function() {
                dataPriv.remove(elem, [type + "queue", key]);
              })
            });
          }
        });
        jQuery2.fn.extend({
          queue: function(type, data) {
            var setter = 2;
            if (typeof type !== "string") {
              data = type;
              type = "fx";
              setter--;
            }
            if (arguments.length < setter) {
              return jQuery2.queue(this[0], type);
            }
            return data === void 0 ? this : this.each(function() {
              var queue = jQuery2.queue(this, type, data);
              jQuery2._queueHooks(this, type);
              if (type === "fx" && queue[0] !== "inprogress") {
                jQuery2.dequeue(this, type);
              }
            });
          },
          dequeue: function(type) {
            return this.each(function() {
              jQuery2.dequeue(this, type);
            });
          },
          clearQueue: function(type) {
            return this.queue(type || "fx", []);
          },
          promise: function(type, obj) {
            var tmp, count = 1, defer = jQuery2.Deferred(), elements = this, i = this.length, resolve = function() {
              if (!--count) {
                defer.resolveWith(elements, [elements]);
              }
            };
            if (typeof type !== "string") {
              obj = type;
              type = void 0;
            }
            type = type || "fx";
            while (i--) {
              tmp = dataPriv.get(elements[i], type + "queueHooks");
              if (tmp && tmp.empty) {
                count++;
                tmp.empty.add(resolve);
              }
            }
            resolve();
            return defer.promise(obj);
          }
        });
        var pnum = /[+-]?(?:\d*\.|)\d+(?:[eE][+-]?\d+|)/.source;
        var rcssNum = new RegExp("^(?:([+-])=|)(" + pnum + ")([a-z%]*)$", "i");
        var cssExpand = ["Top", "Right", "Bottom", "Left"];
        var documentElement = document2.documentElement;
        var isAttached = function(elem) {
          return jQuery2.contains(elem.ownerDocument, elem);
        }, composed = { composed: true };
        if (documentElement.getRootNode) {
          isAttached = function(elem) {
            return jQuery2.contains(elem.ownerDocument, elem) || elem.getRootNode(composed) === elem.ownerDocument;
          };
        }
        var isHiddenWithinTree = function(elem, el) {
          elem = el || elem;
          return elem.style.display === "none" || elem.style.display === "" && isAttached(elem) && jQuery2.css(elem, "display") === "none";
        };
        function adjustCSS(elem, prop, valueParts, tween) {
          var adjusted, scale, maxIterations = 20, currentValue = tween ? function() {
            return tween.cur();
          } : function() {
            return jQuery2.css(elem, prop, "");
          }, initial = currentValue(), unit = valueParts && valueParts[3] || (jQuery2.cssNumber[prop] ? "" : "px"), initialInUnit = elem.nodeType && (jQuery2.cssNumber[prop] || unit !== "px" && +initial) && rcssNum.exec(jQuery2.css(elem, prop));
          if (initialInUnit && initialInUnit[3] !== unit) {
            initial = initial / 2;
            unit = unit || initialInUnit[3];
            initialInUnit = +initial || 1;
            while (maxIterations--) {
              jQuery2.style(elem, prop, initialInUnit + unit);
              if ((1 - scale) * (1 - (scale = currentValue() / initial || 0.5)) <= 0) {
                maxIterations = 0;
              }
              initialInUnit = initialInUnit / scale;
            }
            initialInUnit = initialInUnit * 2;
            jQuery2.style(elem, prop, initialInUnit + unit);
            valueParts = valueParts || [];
          }
          if (valueParts) {
            initialInUnit = +initialInUnit || +initial || 0;
            adjusted = valueParts[1] ? initialInUnit + (valueParts[1] + 1) * valueParts[2] : +valueParts[2];
            if (tween) {
              tween.unit = unit;
              tween.start = initialInUnit;
              tween.end = adjusted;
            }
          }
          return adjusted;
        }
        var defaultDisplayMap = {};
        function getDefaultDisplay(elem) {
          var temp, doc = elem.ownerDocument, nodeName2 = elem.nodeName, display = defaultDisplayMap[nodeName2];
          if (display) {
            return display;
          }
          temp = doc.body.appendChild(doc.createElement(nodeName2));
          display = jQuery2.css(temp, "display");
          temp.parentNode.removeChild(temp);
          if (display === "none") {
            display = "block";
          }
          defaultDisplayMap[nodeName2] = display;
          return display;
        }
        function showHide(elements, show) {
          var display, elem, values = [], index = 0, length = elements.length;
          for (; index < length; index++) {
            elem = elements[index];
            if (!elem.style) {
              continue;
            }
            display = elem.style.display;
            if (show) {
              if (display === "none") {
                values[index] = dataPriv.get(elem, "display") || null;
                if (!values[index]) {
                  elem.style.display = "";
                }
              }
              if (elem.style.display === "" && isHiddenWithinTree(elem)) {
                values[index] = getDefaultDisplay(elem);
              }
            } else {
              if (display !== "none") {
                values[index] = "none";
                dataPriv.set(elem, "display", display);
              }
            }
          }
          for (index = 0; index < length; index++) {
            if (values[index] != null) {
              elements[index].style.display = values[index];
            }
          }
          return elements;
        }
        jQuery2.fn.extend({
          show: function() {
            return showHide(this, true);
          },
          hide: function() {
            return showHide(this);
          },
          toggle: function(state) {
            if (typeof state === "boolean") {
              return state ? this.show() : this.hide();
            }
            return this.each(function() {
              if (isHiddenWithinTree(this)) {
                jQuery2(this).show();
              } else {
                jQuery2(this).hide();
              }
            });
          }
        });
        var rcheckableType = /^(?:checkbox|radio)$/i;
        var rtagName = /<([a-z][^\/\0>\x20\t\r\n\f]*)/i;
        var rscriptType = /^$|^module$|\/(?:java|ecma)script/i;
        (function() {
          var fragment = document2.createDocumentFragment(), div = fragment.appendChild(document2.createElement("div")), input = document2.createElement("input");
          input.setAttribute("type", "radio");
          input.setAttribute("checked", "checked");
          input.setAttribute("name", "t");
          div.appendChild(input);
          support.checkClone = div.cloneNode(true).cloneNode(true).lastChild.checked;
          div.innerHTML = "<textarea>x</textarea>";
          support.noCloneChecked = !!div.cloneNode(true).lastChild.defaultValue;
          div.innerHTML = "<option></option>";
          support.option = !!div.lastChild;
        })();
        var wrapMap = {
          thead: [1, "<table>", "</table>"],
          col: [2, "<table><colgroup>", "</colgroup></table>"],
          tr: [2, "<table><tbody>", "</tbody></table>"],
          td: [3, "<table><tbody><tr>", "</tr></tbody></table>"],
          _default: [0, "", ""]
        };
        wrapMap.tbody = wrapMap.tfoot = wrapMap.colgroup = wrapMap.caption = wrapMap.thead;
        wrapMap.th = wrapMap.td;
        if (!support.option) {
          wrapMap.optgroup = wrapMap.option = [1, "<select multiple='multiple'>", "</select>"];
        }
        function getAll(context, tag) {
          var ret;
          if (typeof context.getElementsByTagName !== "undefined") {
            ret = context.getElementsByTagName(tag || "*");
          } else if (typeof context.querySelectorAll !== "undefined") {
            ret = context.querySelectorAll(tag || "*");
          } else {
            ret = [];
          }
          if (tag === void 0 || tag && nodeName(context, tag)) {
            return jQuery2.merge([context], ret);
          }
          return ret;
        }
        function setGlobalEval(elems, refElements) {
          var i = 0, l = elems.length;
          for (; i < l; i++) {
            dataPriv.set(elems[i], "globalEval", !refElements || dataPriv.get(refElements[i], "globalEval"));
          }
        }
        var rhtml = /<|&#?\w+;/;
        function buildFragment(elems, context, scripts, selection, ignored) {
          var elem, tmp, tag, wrap, attached, j, fragment = context.createDocumentFragment(), nodes = [], i = 0, l = elems.length;
          for (; i < l; i++) {
            elem = elems[i];
            if (elem || elem === 0) {
              if (toType(elem) === "object") {
                jQuery2.merge(nodes, elem.nodeType ? [elem] : elem);
              } else if (!rhtml.test(elem)) {
                nodes.push(context.createTextNode(elem));
              } else {
                tmp = tmp || fragment.appendChild(context.createElement("div"));
                tag = (rtagName.exec(elem) || ["", ""])[1].toLowerCase();
                wrap = wrapMap[tag] || wrapMap._default;
                tmp.innerHTML = wrap[1] + jQuery2.htmlPrefilter(elem) + wrap[2];
                j = wrap[0];
                while (j--) {
                  tmp = tmp.lastChild;
                }
                jQuery2.merge(nodes, tmp.childNodes);
                tmp = fragment.firstChild;
                tmp.textContent = "";
              }
            }
          }
          fragment.textContent = "";
          i = 0;
          while (elem = nodes[i++]) {
            if (selection && jQuery2.inArray(elem, selection) > -1) {
              if (ignored) {
                ignored.push(elem);
              }
              continue;
            }
            attached = isAttached(elem);
            tmp = getAll(fragment.appendChild(elem), "script");
            if (attached) {
              setGlobalEval(tmp);
            }
            if (scripts) {
              j = 0;
              while (elem = tmp[j++]) {
                if (rscriptType.test(elem.type || "")) {
                  scripts.push(elem);
                }
              }
            }
          }
          return fragment;
        }
        var rtypenamespace = /^([^.]*)(?:\.(.+)|)/;
        function returnTrue() {
          return true;
        }
        function returnFalse() {
          return false;
        }
        function expectSync(elem, type) {
          return elem === safeActiveElement() === (type === "focus");
        }
        function safeActiveElement() {
          try {
            return document2.activeElement;
          } catch (err) {
          }
        }
        function on(elem, types, selector, data, fn, one) {
          var origFn, type;
          if (typeof types === "object") {
            if (typeof selector !== "string") {
              data = data || selector;
              selector = void 0;
            }
            for (type in types) {
              on(elem, type, selector, data, types[type], one);
            }
            return elem;
          }
          if (data == null && fn == null) {
            fn = selector;
            data = selector = void 0;
          } else if (fn == null) {
            if (typeof selector === "string") {
              fn = data;
              data = void 0;
            } else {
              fn = data;
              data = selector;
              selector = void 0;
            }
          }
          if (fn === false) {
            fn = returnFalse;
          } else if (!fn) {
            return elem;
          }
          if (one === 1) {
            origFn = fn;
            fn = function(event) {
              jQuery2().off(event);
              return origFn.apply(this, arguments);
            };
            fn.guid = origFn.guid || (origFn.guid = jQuery2.guid++);
          }
          return elem.each(function() {
            jQuery2.event.add(this, types, fn, data, selector);
          });
        }
        jQuery2.event = {
          global: {},
          add: function(elem, types, handler, data, selector) {
            var handleObjIn, eventHandle, tmp, events, t, handleObj, special, handlers, type, namespaces, origType, elemData = dataPriv.get(elem);
            if (!acceptData(elem)) {
              return;
            }
            if (handler.handler) {
              handleObjIn = handler;
              handler = handleObjIn.handler;
              selector = handleObjIn.selector;
            }
            if (selector) {
              jQuery2.find.matchesSelector(documentElement, selector);
            }
            if (!handler.guid) {
              handler.guid = jQuery2.guid++;
            }
            if (!(events = elemData.events)) {
              events = elemData.events = /* @__PURE__ */ Object.create(null);
            }
            if (!(eventHandle = elemData.handle)) {
              eventHandle = elemData.handle = function(e) {
                return typeof jQuery2 !== "undefined" && jQuery2.event.triggered !== e.type ? jQuery2.event.dispatch.apply(elem, arguments) : void 0;
              };
            }
            types = (types || "").match(rnothtmlwhite) || [""];
            t = types.length;
            while (t--) {
              tmp = rtypenamespace.exec(types[t]) || [];
              type = origType = tmp[1];
              namespaces = (tmp[2] || "").split(".").sort();
              if (!type) {
                continue;
              }
              special = jQuery2.event.special[type] || {};
              type = (selector ? special.delegateType : special.bindType) || type;
              special = jQuery2.event.special[type] || {};
              handleObj = jQuery2.extend({
                type,
                origType,
                data,
                handler,
                guid: handler.guid,
                selector,
                needsContext: selector && jQuery2.expr.match.needsContext.test(selector),
                namespace: namespaces.join(".")
              }, handleObjIn);
              if (!(handlers = events[type])) {
                handlers = events[type] = [];
                handlers.delegateCount = 0;
                if (!special.setup || special.setup.call(elem, data, namespaces, eventHandle) === false) {
                  if (elem.addEventListener) {
                    elem.addEventListener(type, eventHandle);
                  }
                }
              }
              if (special.add) {
                special.add.call(elem, handleObj);
                if (!handleObj.handler.guid) {
                  handleObj.handler.guid = handler.guid;
                }
              }
              if (selector) {
                handlers.splice(handlers.delegateCount++, 0, handleObj);
              } else {
                handlers.push(handleObj);
              }
              jQuery2.event.global[type] = true;
            }
          },
          remove: function(elem, types, handler, selector, mappedTypes) {
            var j, origCount, tmp, events, t, handleObj, special, handlers, type, namespaces, origType, elemData = dataPriv.hasData(elem) && dataPriv.get(elem);
            if (!elemData || !(events = elemData.events)) {
              return;
            }
            types = (types || "").match(rnothtmlwhite) || [""];
            t = types.length;
            while (t--) {
              tmp = rtypenamespace.exec(types[t]) || [];
              type = origType = tmp[1];
              namespaces = (tmp[2] || "").split(".").sort();
              if (!type) {
                for (type in events) {
                  jQuery2.event.remove(elem, type + types[t], handler, selector, true);
                }
                continue;
              }
              special = jQuery2.event.special[type] || {};
              type = (selector ? special.delegateType : special.bindType) || type;
              handlers = events[type] || [];
              tmp = tmp[2] && new RegExp("(^|\\.)" + namespaces.join("\\.(?:.*\\.|)") + "(\\.|$)");
              origCount = j = handlers.length;
              while (j--) {
                handleObj = handlers[j];
                if ((mappedTypes || origType === handleObj.origType) && (!handler || handler.guid === handleObj.guid) && (!tmp || tmp.test(handleObj.namespace)) && (!selector || selector === handleObj.selector || selector === "**" && handleObj.selector)) {
                  handlers.splice(j, 1);
                  if (handleObj.selector) {
                    handlers.delegateCount--;
                  }
                  if (special.remove) {
                    special.remove.call(elem, handleObj);
                  }
                }
              }
              if (origCount && !handlers.length) {
                if (!special.teardown || special.teardown.call(elem, namespaces, elemData.handle) === false) {
                  jQuery2.removeEvent(elem, type, elemData.handle);
                }
                delete events[type];
              }
            }
            if (jQuery2.isEmptyObject(events)) {
              dataPriv.remove(elem, "handle events");
            }
          },
          dispatch: function(nativeEvent) {
            var i, j, ret, matched, handleObj, handlerQueue, args = new Array(arguments.length), event = jQuery2.event.fix(nativeEvent), handlers = (dataPriv.get(this, "events") || /* @__PURE__ */ Object.create(null))[event.type] || [], special = jQuery2.event.special[event.type] || {};
            args[0] = event;
            for (i = 1; i < arguments.length; i++) {
              args[i] = arguments[i];
            }
            event.delegateTarget = this;
            if (special.preDispatch && special.preDispatch.call(this, event) === false) {
              return;
            }
            handlerQueue = jQuery2.event.handlers.call(this, event, handlers);
            i = 0;
            while ((matched = handlerQueue[i++]) && !event.isPropagationStopped()) {
              event.currentTarget = matched.elem;
              j = 0;
              while ((handleObj = matched.handlers[j++]) && !event.isImmediatePropagationStopped()) {
                if (!event.rnamespace || handleObj.namespace === false || event.rnamespace.test(handleObj.namespace)) {
                  event.handleObj = handleObj;
                  event.data = handleObj.data;
                  ret = ((jQuery2.event.special[handleObj.origType] || {}).handle || handleObj.handler).apply(matched.elem, args);
                  if (ret !== void 0) {
                    if ((event.result = ret) === false) {
                      event.preventDefault();
                      event.stopPropagation();
                    }
                  }
                }
              }
            }
            if (special.postDispatch) {
              special.postDispatch.call(this, event);
            }
            return event.result;
          },
          handlers: function(event, handlers) {
            var i, handleObj, sel, matchedHandlers, matchedSelectors, handlerQueue = [], delegateCount = handlers.delegateCount, cur = event.target;
            if (delegateCount && cur.nodeType && !(event.type === "click" && event.button >= 1)) {
              for (; cur !== this; cur = cur.parentNode || this) {
                if (cur.nodeType === 1 && !(event.type === "click" && cur.disabled === true)) {
                  matchedHandlers = [];
                  matchedSelectors = {};
                  for (i = 0; i < delegateCount; i++) {
                    handleObj = handlers[i];
                    sel = handleObj.selector + " ";
                    if (matchedSelectors[sel] === void 0) {
                      matchedSelectors[sel] = handleObj.needsContext ? jQuery2(sel, this).index(cur) > -1 : jQuery2.find(sel, this, null, [cur]).length;
                    }
                    if (matchedSelectors[sel]) {
                      matchedHandlers.push(handleObj);
                    }
                  }
                  if (matchedHandlers.length) {
                    handlerQueue.push({ elem: cur, handlers: matchedHandlers });
                  }
                }
              }
            }
            cur = this;
            if (delegateCount < handlers.length) {
              handlerQueue.push({ elem: cur, handlers: handlers.slice(delegateCount) });
            }
            return handlerQueue;
          },
          addProp: function(name, hook) {
            Object.defineProperty(jQuery2.Event.prototype, name, {
              enumerable: true,
              configurable: true,
              get: isFunction(hook) ? function() {
                if (this.originalEvent) {
                  return hook(this.originalEvent);
                }
              } : function() {
                if (this.originalEvent) {
                  return this.originalEvent[name];
                }
              },
              set: function(value) {
                Object.defineProperty(this, name, {
                  enumerable: true,
                  configurable: true,
                  writable: true,
                  value
                });
              }
            });
          },
          fix: function(originalEvent) {
            return originalEvent[jQuery2.expando] ? originalEvent : new jQuery2.Event(originalEvent);
          },
          special: {
            load: {
              noBubble: true
            },
            click: {
              setup: function(data) {
                var el = this || data;
                if (rcheckableType.test(el.type) && el.click && nodeName(el, "input")) {
                  leverageNative(el, "click", returnTrue);
                }
                return false;
              },
              trigger: function(data) {
                var el = this || data;
                if (rcheckableType.test(el.type) && el.click && nodeName(el, "input")) {
                  leverageNative(el, "click");
                }
                return true;
              },
              _default: function(event) {
                var target = event.target;
                return rcheckableType.test(target.type) && target.click && nodeName(target, "input") && dataPriv.get(target, "click") || nodeName(target, "a");
              }
            },
            beforeunload: {
              postDispatch: function(event) {
                if (event.result !== void 0 && event.originalEvent) {
                  event.originalEvent.returnValue = event.result;
                }
              }
            }
          }
        };
        function leverageNative(el, type, expectSync2) {
          if (!expectSync2) {
            if (dataPriv.get(el, type) === void 0) {
              jQuery2.event.add(el, type, returnTrue);
            }
            return;
          }
          dataPriv.set(el, type, false);
          jQuery2.event.add(el, type, {
            namespace: false,
            handler: function(event) {
              var notAsync, result, saved = dataPriv.get(this, type);
              if (event.isTrigger & 1 && this[type]) {
                if (!saved.length) {
                  saved = slice.call(arguments);
                  dataPriv.set(this, type, saved);
                  notAsync = expectSync2(this, type);
                  this[type]();
                  result = dataPriv.get(this, type);
                  if (saved !== result || notAsync) {
                    dataPriv.set(this, type, false);
                  } else {
                    result = {};
                  }
                  if (saved !== result) {
                    event.stopImmediatePropagation();
                    event.preventDefault();
                    return result && result.value;
                  }
                } else if ((jQuery2.event.special[type] || {}).delegateType) {
                  event.stopPropagation();
                }
              } else if (saved.length) {
                dataPriv.set(this, type, {
                  value: jQuery2.event.trigger(jQuery2.extend(saved[0], jQuery2.Event.prototype), saved.slice(1), this)
                });
                event.stopImmediatePropagation();
              }
            }
          });
        }
        jQuery2.removeEvent = function(elem, type, handle) {
          if (elem.removeEventListener) {
            elem.removeEventListener(type, handle);
          }
        };
        jQuery2.Event = function(src, props) {
          if (!(this instanceof jQuery2.Event)) {
            return new jQuery2.Event(src, props);
          }
          if (src && src.type) {
            this.originalEvent = src;
            this.type = src.type;
            this.isDefaultPrevented = src.defaultPrevented || src.defaultPrevented === void 0 && src.returnValue === false ? returnTrue : returnFalse;
            this.target = src.target && src.target.nodeType === 3 ? src.target.parentNode : src.target;
            this.currentTarget = src.currentTarget;
            this.relatedTarget = src.relatedTarget;
          } else {
            this.type = src;
          }
          if (props) {
            jQuery2.extend(this, props);
          }
          this.timeStamp = src && src.timeStamp || Date.now();
          this[jQuery2.expando] = true;
        };
        jQuery2.Event.prototype = {
          constructor: jQuery2.Event,
          isDefaultPrevented: returnFalse,
          isPropagationStopped: returnFalse,
          isImmediatePropagationStopped: returnFalse,
          isSimulated: false,
          preventDefault: function() {
            var e = this.originalEvent;
            this.isDefaultPrevented = returnTrue;
            if (e && !this.isSimulated) {
              e.preventDefault();
            }
          },
          stopPropagation: function() {
            var e = this.originalEvent;
            this.isPropagationStopped = returnTrue;
            if (e && !this.isSimulated) {
              e.stopPropagation();
            }
          },
          stopImmediatePropagation: function() {
            var e = this.originalEvent;
            this.isImmediatePropagationStopped = returnTrue;
            if (e && !this.isSimulated) {
              e.stopImmediatePropagation();
            }
            this.stopPropagation();
          }
        };
        jQuery2.each({
          altKey: true,
          bubbles: true,
          cancelable: true,
          changedTouches: true,
          ctrlKey: true,
          detail: true,
          eventPhase: true,
          metaKey: true,
          pageX: true,
          pageY: true,
          shiftKey: true,
          view: true,
          "char": true,
          code: true,
          charCode: true,
          key: true,
          keyCode: true,
          button: true,
          buttons: true,
          clientX: true,
          clientY: true,
          offsetX: true,
          offsetY: true,
          pointerId: true,
          pointerType: true,
          screenX: true,
          screenY: true,
          targetTouches: true,
          toElement: true,
          touches: true,
          which: true
        }, jQuery2.event.addProp);
        jQuery2.each({ focus: "focusin", blur: "focusout" }, function(type, delegateType) {
          jQuery2.event.special[type] = {
            setup: function() {
              leverageNative(this, type, expectSync);
              return false;
            },
            trigger: function() {
              leverageNative(this, type);
              return true;
            },
            _default: function() {
              return true;
            },
            delegateType
          };
        });
        jQuery2.each({
          mouseenter: "mouseover",
          mouseleave: "mouseout",
          pointerenter: "pointerover",
          pointerleave: "pointerout"
        }, function(orig, fix) {
          jQuery2.event.special[orig] = {
            delegateType: fix,
            bindType: fix,
            handle: function(event) {
              var ret, target = this, related = event.relatedTarget, handleObj = event.handleObj;
              if (!related || related !== target && !jQuery2.contains(target, related)) {
                event.type = handleObj.origType;
                ret = handleObj.handler.apply(this, arguments);
                event.type = fix;
              }
              return ret;
            }
          };
        });
        jQuery2.fn.extend({
          on: function(types, selector, data, fn) {
            return on(this, types, selector, data, fn);
          },
          one: function(types, selector, data, fn) {
            return on(this, types, selector, data, fn, 1);
          },
          off: function(types, selector, fn) {
            var handleObj, type;
            if (types && types.preventDefault && types.handleObj) {
              handleObj = types.handleObj;
              jQuery2(types.delegateTarget).off(handleObj.namespace ? handleObj.origType + "." + handleObj.namespace : handleObj.origType, handleObj.selector, handleObj.handler);
              return this;
            }
            if (typeof types === "object") {
              for (type in types) {
                this.off(type, selector, types[type]);
              }
              return this;
            }
            if (selector === false || typeof selector === "function") {
              fn = selector;
              selector = void 0;
            }
            if (fn === false) {
              fn = returnFalse;
            }
            return this.each(function() {
              jQuery2.event.remove(this, types, fn, selector);
            });
          }
        });
        var rnoInnerhtml = /<script|<style|<link/i, rchecked = /checked\s*(?:[^=]|=\s*.checked.)/i, rcleanScript = /^\s*<!(?:\[CDATA\[|--)|(?:\]\]|--)>\s*$/g;
        function manipulationTarget(elem, content) {
          if (nodeName(elem, "table") && nodeName(content.nodeType !== 11 ? content : content.firstChild, "tr")) {
            return jQuery2(elem).children("tbody")[0] || elem;
          }
          return elem;
        }
        function disableScript(elem) {
          elem.type = (elem.getAttribute("type") !== null) + "/" + elem.type;
          return elem;
        }
        function restoreScript(elem) {
          if ((elem.type || "").slice(0, 5) === "true/") {
            elem.type = elem.type.slice(5);
          } else {
            elem.removeAttribute("type");
          }
          return elem;
        }
        function cloneCopyEvent(src, dest) {
          var i, l, type, pdataOld, udataOld, udataCur, events;
          if (dest.nodeType !== 1) {
            return;
          }
          if (dataPriv.hasData(src)) {
            pdataOld = dataPriv.get(src);
            events = pdataOld.events;
            if (events) {
              dataPriv.remove(dest, "handle events");
              for (type in events) {
                for (i = 0, l = events[type].length; i < l; i++) {
                  jQuery2.event.add(dest, type, events[type][i]);
                }
              }
            }
          }
          if (dataUser.hasData(src)) {
            udataOld = dataUser.access(src);
            udataCur = jQuery2.extend({}, udataOld);
            dataUser.set(dest, udataCur);
          }
        }
        function fixInput(src, dest) {
          var nodeName2 = dest.nodeName.toLowerCase();
          if (nodeName2 === "input" && rcheckableType.test(src.type)) {
            dest.checked = src.checked;
          } else if (nodeName2 === "input" || nodeName2 === "textarea") {
            dest.defaultValue = src.defaultValue;
          }
        }
        function domManip(collection, args, callback, ignored) {
          args = flat(args);
          var fragment, first, scripts, hasScripts, node, doc, i = 0, l = collection.length, iNoClone = l - 1, value = args[0], valueIsFunction = isFunction(value);
          if (valueIsFunction || l > 1 && typeof value === "string" && !support.checkClone && rchecked.test(value)) {
            return collection.each(function(index) {
              var self2 = collection.eq(index);
              if (valueIsFunction) {
                args[0] = value.call(this, index, self2.html());
              }
              domManip(self2, args, callback, ignored);
            });
          }
          if (l) {
            fragment = buildFragment(args, collection[0].ownerDocument, false, collection, ignored);
            first = fragment.firstChild;
            if (fragment.childNodes.length === 1) {
              fragment = first;
            }
            if (first || ignored) {
              scripts = jQuery2.map(getAll(fragment, "script"), disableScript);
              hasScripts = scripts.length;
              for (; i < l; i++) {
                node = fragment;
                if (i !== iNoClone) {
                  node = jQuery2.clone(node, true, true);
                  if (hasScripts) {
                    jQuery2.merge(scripts, getAll(node, "script"));
                  }
                }
                callback.call(collection[i], node, i);
              }
              if (hasScripts) {
                doc = scripts[scripts.length - 1].ownerDocument;
                jQuery2.map(scripts, restoreScript);
                for (i = 0; i < hasScripts; i++) {
                  node = scripts[i];
                  if (rscriptType.test(node.type || "") && !dataPriv.access(node, "globalEval") && jQuery2.contains(doc, node)) {
                    if (node.src && (node.type || "").toLowerCase() !== "module") {
                      if (jQuery2._evalUrl && !node.noModule) {
                        jQuery2._evalUrl(node.src, {
                          nonce: node.nonce || node.getAttribute("nonce")
                        }, doc);
                      }
                    } else {
                      DOMEval(node.textContent.replace(rcleanScript, ""), node, doc);
                    }
                  }
                }
              }
            }
          }
          return collection;
        }
        function remove(elem, selector, keepData) {
          var node, nodes = selector ? jQuery2.filter(selector, elem) : elem, i = 0;
          for (; (node = nodes[i]) != null; i++) {
            if (!keepData && node.nodeType === 1) {
              jQuery2.cleanData(getAll(node));
            }
            if (node.parentNode) {
              if (keepData && isAttached(node)) {
                setGlobalEval(getAll(node, "script"));
              }
              node.parentNode.removeChild(node);
            }
          }
          return elem;
        }
        jQuery2.extend({
          htmlPrefilter: function(html) {
            return html;
          },
          clone: function(elem, dataAndEvents, deepDataAndEvents) {
            var i, l, srcElements, destElements, clone = elem.cloneNode(true), inPage = isAttached(elem);
            if (!support.noCloneChecked && (elem.nodeType === 1 || elem.nodeType === 11) && !jQuery2.isXMLDoc(elem)) {
              destElements = getAll(clone);
              srcElements = getAll(elem);
              for (i = 0, l = srcElements.length; i < l; i++) {
                fixInput(srcElements[i], destElements[i]);
              }
            }
            if (dataAndEvents) {
              if (deepDataAndEvents) {
                srcElements = srcElements || getAll(elem);
                destElements = destElements || getAll(clone);
                for (i = 0, l = srcElements.length; i < l; i++) {
                  cloneCopyEvent(srcElements[i], destElements[i]);
                }
              } else {
                cloneCopyEvent(elem, clone);
              }
            }
            destElements = getAll(clone, "script");
            if (destElements.length > 0) {
              setGlobalEval(destElements, !inPage && getAll(elem, "script"));
            }
            return clone;
          },
          cleanData: function(elems) {
            var data, elem, type, special = jQuery2.event.special, i = 0;
            for (; (elem = elems[i]) !== void 0; i++) {
              if (acceptData(elem)) {
                if (data = elem[dataPriv.expando]) {
                  if (data.events) {
                    for (type in data.events) {
                      if (special[type]) {
                        jQuery2.event.remove(elem, type);
                      } else {
                        jQuery2.removeEvent(elem, type, data.handle);
                      }
                    }
                  }
                  elem[dataPriv.expando] = void 0;
                }
                if (elem[dataUser.expando]) {
                  elem[dataUser.expando] = void 0;
                }
              }
            }
          }
        });
        jQuery2.fn.extend({
          detach: function(selector) {
            return remove(this, selector, true);
          },
          remove: function(selector) {
            return remove(this, selector);
          },
          text: function(value) {
            return access(this, function(value2) {
              return value2 === void 0 ? jQuery2.text(this) : this.empty().each(function() {
                if (this.nodeType === 1 || this.nodeType === 11 || this.nodeType === 9) {
                  this.textContent = value2;
                }
              });
            }, null, value, arguments.length);
          },
          append: function() {
            return domManip(this, arguments, function(elem) {
              if (this.nodeType === 1 || this.nodeType === 11 || this.nodeType === 9) {
                var target = manipulationTarget(this, elem);
                target.appendChild(elem);
              }
            });
          },
          prepend: function() {
            return domManip(this, arguments, function(elem) {
              if (this.nodeType === 1 || this.nodeType === 11 || this.nodeType === 9) {
                var target = manipulationTarget(this, elem);
                target.insertBefore(elem, target.firstChild);
              }
            });
          },
          before: function() {
            return domManip(this, arguments, function(elem) {
              if (this.parentNode) {
                this.parentNode.insertBefore(elem, this);
              }
            });
          },
          after: function() {
            return domManip(this, arguments, function(elem) {
              if (this.parentNode) {
                this.parentNode.insertBefore(elem, this.nextSibling);
              }
            });
          },
          empty: function() {
            var elem, i = 0;
            for (; (elem = this[i]) != null; i++) {
              if (elem.nodeType === 1) {
                jQuery2.cleanData(getAll(elem, false));
                elem.textContent = "";
              }
            }
            return this;
          },
          clone: function(dataAndEvents, deepDataAndEvents) {
            dataAndEvents = dataAndEvents == null ? false : dataAndEvents;
            deepDataAndEvents = deepDataAndEvents == null ? dataAndEvents : deepDataAndEvents;
            return this.map(function() {
              return jQuery2.clone(this, dataAndEvents, deepDataAndEvents);
            });
          },
          html: function(value) {
            return access(this, function(value2) {
              var elem = this[0] || {}, i = 0, l = this.length;
              if (value2 === void 0 && elem.nodeType === 1) {
                return elem.innerHTML;
              }
              if (typeof value2 === "string" && !rnoInnerhtml.test(value2) && !wrapMap[(rtagName.exec(value2) || ["", ""])[1].toLowerCase()]) {
                value2 = jQuery2.htmlPrefilter(value2);
                try {
                  for (; i < l; i++) {
                    elem = this[i] || {};
                    if (elem.nodeType === 1) {
                      jQuery2.cleanData(getAll(elem, false));
                      elem.innerHTML = value2;
                    }
                  }
                  elem = 0;
                } catch (e) {
                }
              }
              if (elem) {
                this.empty().append(value2);
              }
            }, null, value, arguments.length);
          },
          replaceWith: function() {
            var ignored = [];
            return domManip(this, arguments, function(elem) {
              var parent = this.parentNode;
              if (jQuery2.inArray(this, ignored) < 0) {
                jQuery2.cleanData(getAll(this));
                if (parent) {
                  parent.replaceChild(elem, this);
                }
              }
            }, ignored);
          }
        });
        jQuery2.each({
          appendTo: "append",
          prependTo: "prepend",
          insertBefore: "before",
          insertAfter: "after",
          replaceAll: "replaceWith"
        }, function(name, original) {
          jQuery2.fn[name] = function(selector) {
            var elems, ret = [], insert = jQuery2(selector), last = insert.length - 1, i = 0;
            for (; i <= last; i++) {
              elems = i === last ? this : this.clone(true);
              jQuery2(insert[i])[original](elems);
              push.apply(ret, elems.get());
            }
            return this.pushStack(ret);
          };
        });
        var rnumnonpx = new RegExp("^(" + pnum + ")(?!px)[a-z%]+$", "i");
        var getStyles = function(elem) {
          var view = elem.ownerDocument.defaultView;
          if (!view || !view.opener) {
            view = window2;
          }
          return view.getComputedStyle(elem);
        };
        var swap = function(elem, options, callback) {
          var ret, name, old = {};
          for (name in options) {
            old[name] = elem.style[name];
            elem.style[name] = options[name];
          }
          ret = callback.call(elem);
          for (name in options) {
            elem.style[name] = old[name];
          }
          return ret;
        };
        var rboxStyle = new RegExp(cssExpand.join("|"), "i");
        (function() {
          function computeStyleTests() {
            if (!div) {
              return;
            }
            container.style.cssText = "position:absolute;left:-11111px;width:60px;margin-top:1px;padding:0;border:0";
            div.style.cssText = "position:relative;display:block;box-sizing:border-box;overflow:scroll;margin:auto;border:1px;padding:1px;width:60%;top:1%";
            documentElement.appendChild(container).appendChild(div);
            var divStyle = window2.getComputedStyle(div);
            pixelPositionVal = divStyle.top !== "1%";
            reliableMarginLeftVal = roundPixelMeasures(divStyle.marginLeft) === 12;
            div.style.right = "60%";
            pixelBoxStylesVal = roundPixelMeasures(divStyle.right) === 36;
            boxSizingReliableVal = roundPixelMeasures(divStyle.width) === 36;
            div.style.position = "absolute";
            scrollboxSizeVal = roundPixelMeasures(div.offsetWidth / 3) === 12;
            documentElement.removeChild(container);
            div = null;
          }
          function roundPixelMeasures(measure) {
            return Math.round(parseFloat(measure));
          }
          var pixelPositionVal, boxSizingReliableVal, scrollboxSizeVal, pixelBoxStylesVal, reliableTrDimensionsVal, reliableMarginLeftVal, container = document2.createElement("div"), div = document2.createElement("div");
          if (!div.style) {
            return;
          }
          div.style.backgroundClip = "content-box";
          div.cloneNode(true).style.backgroundClip = "";
          support.clearCloneStyle = div.style.backgroundClip === "content-box";
          jQuery2.extend(support, {
            boxSizingReliable: function() {
              computeStyleTests();
              return boxSizingReliableVal;
            },
            pixelBoxStyles: function() {
              computeStyleTests();
              return pixelBoxStylesVal;
            },
            pixelPosition: function() {
              computeStyleTests();
              return pixelPositionVal;
            },
            reliableMarginLeft: function() {
              computeStyleTests();
              return reliableMarginLeftVal;
            },
            scrollboxSize: function() {
              computeStyleTests();
              return scrollboxSizeVal;
            },
            reliableTrDimensions: function() {
              var table, tr, trChild, trStyle;
              if (reliableTrDimensionsVal == null) {
                table = document2.createElement("table");
                tr = document2.createElement("tr");
                trChild = document2.createElement("div");
                table.style.cssText = "position:absolute;left:-11111px;border-collapse:separate";
                tr.style.cssText = "border:1px solid";
                tr.style.height = "1px";
                trChild.style.height = "9px";
                trChild.style.display = "block";
                documentElement.appendChild(table).appendChild(tr).appendChild(trChild);
                trStyle = window2.getComputedStyle(tr);
                reliableTrDimensionsVal = parseInt(trStyle.height, 10) + parseInt(trStyle.borderTopWidth, 10) + parseInt(trStyle.borderBottomWidth, 10) === tr.offsetHeight;
                documentElement.removeChild(table);
              }
              return reliableTrDimensionsVal;
            }
          });
        })();
        function curCSS(elem, name, computed) {
          var width, minWidth, maxWidth, ret, style = elem.style;
          computed = computed || getStyles(elem);
          if (computed) {
            ret = computed.getPropertyValue(name) || computed[name];
            if (ret === "" && !isAttached(elem)) {
              ret = jQuery2.style(elem, name);
            }
            if (!support.pixelBoxStyles() && rnumnonpx.test(ret) && rboxStyle.test(name)) {
              width = style.width;
              minWidth = style.minWidth;
              maxWidth = style.maxWidth;
              style.minWidth = style.maxWidth = style.width = ret;
              ret = computed.width;
              style.width = width;
              style.minWidth = minWidth;
              style.maxWidth = maxWidth;
            }
          }
          return ret !== void 0 ? ret + "" : ret;
        }
        function addGetHookIf(conditionFn, hookFn) {
          return {
            get: function() {
              if (conditionFn()) {
                delete this.get;
                return;
              }
              return (this.get = hookFn).apply(this, arguments);
            }
          };
        }
        var cssPrefixes = ["Webkit", "Moz", "ms"], emptyStyle = document2.createElement("div").style, vendorProps = {};
        function vendorPropName(name) {
          var capName = name[0].toUpperCase() + name.slice(1), i = cssPrefixes.length;
          while (i--) {
            name = cssPrefixes[i] + capName;
            if (name in emptyStyle) {
              return name;
            }
          }
        }
        function finalPropName(name) {
          var final = jQuery2.cssProps[name] || vendorProps[name];
          if (final) {
            return final;
          }
          if (name in emptyStyle) {
            return name;
          }
          return vendorProps[name] = vendorPropName(name) || name;
        }
        var rdisplayswap = /^(none|table(?!-c[ea]).+)/, rcustomProp = /^--/, cssShow = { position: "absolute", visibility: "hidden", display: "block" }, cssNormalTransform = {
          letterSpacing: "0",
          fontWeight: "400"
        };
        function setPositiveNumber(_elem, value, subtract) {
          var matches = rcssNum.exec(value);
          return matches ? Math.max(0, matches[2] - (subtract || 0)) + (matches[3] || "px") : value;
        }
        function boxModelAdjustment(elem, dimension, box, isBorderBox, styles, computedVal) {
          var i = dimension === "width" ? 1 : 0, extra = 0, delta = 0;
          if (box === (isBorderBox ? "border" : "content")) {
            return 0;
          }
          for (; i < 4; i += 2) {
            if (box === "margin") {
              delta += jQuery2.css(elem, box + cssExpand[i], true, styles);
            }
            if (!isBorderBox) {
              delta += jQuery2.css(elem, "padding" + cssExpand[i], true, styles);
              if (box !== "padding") {
                delta += jQuery2.css(elem, "border" + cssExpand[i] + "Width", true, styles);
              } else {
                extra += jQuery2.css(elem, "border" + cssExpand[i] + "Width", true, styles);
              }
            } else {
              if (box === "content") {
                delta -= jQuery2.css(elem, "padding" + cssExpand[i], true, styles);
              }
              if (box !== "margin") {
                delta -= jQuery2.css(elem, "border" + cssExpand[i] + "Width", true, styles);
              }
            }
          }
          if (!isBorderBox && computedVal >= 0) {
            delta += Math.max(0, Math.ceil(elem["offset" + dimension[0].toUpperCase() + dimension.slice(1)] - computedVal - delta - extra - 0.5)) || 0;
          }
          return delta;
        }
        function getWidthOrHeight(elem, dimension, extra) {
          var styles = getStyles(elem), boxSizingNeeded = !support.boxSizingReliable() || extra, isBorderBox = boxSizingNeeded && jQuery2.css(elem, "boxSizing", false, styles) === "border-box", valueIsBorderBox = isBorderBox, val = curCSS(elem, dimension, styles), offsetProp = "offset" + dimension[0].toUpperCase() + dimension.slice(1);
          if (rnumnonpx.test(val)) {
            if (!extra) {
              return val;
            }
            val = "auto";
          }
          if ((!support.boxSizingReliable() && isBorderBox || !support.reliableTrDimensions() && nodeName(elem, "tr") || val === "auto" || !parseFloat(val) && jQuery2.css(elem, "display", false, styles) === "inline") && elem.getClientRects().length) {
            isBorderBox = jQuery2.css(elem, "boxSizing", false, styles) === "border-box";
            valueIsBorderBox = offsetProp in elem;
            if (valueIsBorderBox) {
              val = elem[offsetProp];
            }
          }
          val = parseFloat(val) || 0;
          return val + boxModelAdjustment(elem, dimension, extra || (isBorderBox ? "border" : "content"), valueIsBorderBox, styles, val) + "px";
        }
        jQuery2.extend({
          cssHooks: {
            opacity: {
              get: function(elem, computed) {
                if (computed) {
                  var ret = curCSS(elem, "opacity");
                  return ret === "" ? "1" : ret;
                }
              }
            }
          },
          cssNumber: {
            "animationIterationCount": true,
            "columnCount": true,
            "fillOpacity": true,
            "flexGrow": true,
            "flexShrink": true,
            "fontWeight": true,
            "gridArea": true,
            "gridColumn": true,
            "gridColumnEnd": true,
            "gridColumnStart": true,
            "gridRow": true,
            "gridRowEnd": true,
            "gridRowStart": true,
            "lineHeight": true,
            "opacity": true,
            "order": true,
            "orphans": true,
            "widows": true,
            "zIndex": true,
            "zoom": true
          },
          cssProps: {},
          style: function(elem, name, value, extra) {
            if (!elem || elem.nodeType === 3 || elem.nodeType === 8 || !elem.style) {
              return;
            }
            var ret, type, hooks, origName = camelCase(name), isCustomProp = rcustomProp.test(name), style = elem.style;
            if (!isCustomProp) {
              name = finalPropName(origName);
            }
            hooks = jQuery2.cssHooks[name] || jQuery2.cssHooks[origName];
            if (value !== void 0) {
              type = typeof value;
              if (type === "string" && (ret = rcssNum.exec(value)) && ret[1]) {
                value = adjustCSS(elem, name, ret);
                type = "number";
              }
              if (value == null || value !== value) {
                return;
              }
              if (type === "number" && !isCustomProp) {
                value += ret && ret[3] || (jQuery2.cssNumber[origName] ? "" : "px");
              }
              if (!support.clearCloneStyle && value === "" && name.indexOf("background") === 0) {
                style[name] = "inherit";
              }
              if (!hooks || !("set" in hooks) || (value = hooks.set(elem, value, extra)) !== void 0) {
                if (isCustomProp) {
                  style.setProperty(name, value);
                } else {
                  style[name] = value;
                }
              }
            } else {
              if (hooks && "get" in hooks && (ret = hooks.get(elem, false, extra)) !== void 0) {
                return ret;
              }
              return style[name];
            }
          },
          css: function(elem, name, extra, styles) {
            var val, num, hooks, origName = camelCase(name), isCustomProp = rcustomProp.test(name);
            if (!isCustomProp) {
              name = finalPropName(origName);
            }
            hooks = jQuery2.cssHooks[name] || jQuery2.cssHooks[origName];
            if (hooks && "get" in hooks) {
              val = hooks.get(elem, true, extra);
            }
            if (val === void 0) {
              val = curCSS(elem, name, styles);
            }
            if (val === "normal" && name in cssNormalTransform) {
              val = cssNormalTransform[name];
            }
            if (extra === "" || extra) {
              num = parseFloat(val);
              return extra === true || isFinite(num) ? num || 0 : val;
            }
            return val;
          }
        });
        jQuery2.each(["height", "width"], function(_i, dimension) {
          jQuery2.cssHooks[dimension] = {
            get: function(elem, computed, extra) {
              if (computed) {
                return rdisplayswap.test(jQuery2.css(elem, "display")) && (!elem.getClientRects().length || !elem.getBoundingClientRect().width) ? swap(elem, cssShow, function() {
                  return getWidthOrHeight(elem, dimension, extra);
                }) : getWidthOrHeight(elem, dimension, extra);
              }
            },
            set: function(elem, value, extra) {
              var matches, styles = getStyles(elem), scrollboxSizeBuggy = !support.scrollboxSize() && styles.position === "absolute", boxSizingNeeded = scrollboxSizeBuggy || extra, isBorderBox = boxSizingNeeded && jQuery2.css(elem, "boxSizing", false, styles) === "border-box", subtract = extra ? boxModelAdjustment(elem, dimension, extra, isBorderBox, styles) : 0;
              if (isBorderBox && scrollboxSizeBuggy) {
                subtract -= Math.ceil(elem["offset" + dimension[0].toUpperCase() + dimension.slice(1)] - parseFloat(styles[dimension]) - boxModelAdjustment(elem, dimension, "border", false, styles) - 0.5);
              }
              if (subtract && (matches = rcssNum.exec(value)) && (matches[3] || "px") !== "px") {
                elem.style[dimension] = value;
                value = jQuery2.css(elem, dimension);
              }
              return setPositiveNumber(elem, value, subtract);
            }
          };
        });
        jQuery2.cssHooks.marginLeft = addGetHookIf(support.reliableMarginLeft, function(elem, computed) {
          if (computed) {
            return (parseFloat(curCSS(elem, "marginLeft")) || elem.getBoundingClientRect().left - swap(elem, { marginLeft: 0 }, function() {
              return elem.getBoundingClientRect().left;
            })) + "px";
          }
        });
        jQuery2.each({
          margin: "",
          padding: "",
          border: "Width"
        }, function(prefix, suffix) {
          jQuery2.cssHooks[prefix + suffix] = {
            expand: function(value) {
              var i = 0, expanded = {}, parts = typeof value === "string" ? value.split(" ") : [value];
              for (; i < 4; i++) {
                expanded[prefix + cssExpand[i] + suffix] = parts[i] || parts[i - 2] || parts[0];
              }
              return expanded;
            }
          };
          if (prefix !== "margin") {
            jQuery2.cssHooks[prefix + suffix].set = setPositiveNumber;
          }
        });
        jQuery2.fn.extend({
          css: function(name, value) {
            return access(this, function(elem, name2, value2) {
              var styles, len, map = {}, i = 0;
              if (Array.isArray(name2)) {
                styles = getStyles(elem);
                len = name2.length;
                for (; i < len; i++) {
                  map[name2[i]] = jQuery2.css(elem, name2[i], false, styles);
                }
                return map;
              }
              return value2 !== void 0 ? jQuery2.style(elem, name2, value2) : jQuery2.css(elem, name2);
            }, name, value, arguments.length > 1);
          }
        });
        function Tween(elem, options, prop, end, easing) {
          return new Tween.prototype.init(elem, options, prop, end, easing);
        }
        jQuery2.Tween = Tween;
        Tween.prototype = {
          constructor: Tween,
          init: function(elem, options, prop, end, easing, unit) {
            this.elem = elem;
            this.prop = prop;
            this.easing = easing || jQuery2.easing._default;
            this.options = options;
            this.start = this.now = this.cur();
            this.end = end;
            this.unit = unit || (jQuery2.cssNumber[prop] ? "" : "px");
          },
          cur: function() {
            var hooks = Tween.propHooks[this.prop];
            return hooks && hooks.get ? hooks.get(this) : Tween.propHooks._default.get(this);
          },
          run: function(percent) {
            var eased, hooks = Tween.propHooks[this.prop];
            if (this.options.duration) {
              this.pos = eased = jQuery2.easing[this.easing](percent, this.options.duration * percent, 0, 1, this.options.duration);
            } else {
              this.pos = eased = percent;
            }
            this.now = (this.end - this.start) * eased + this.start;
            if (this.options.step) {
              this.options.step.call(this.elem, this.now, this);
            }
            if (hooks && hooks.set) {
              hooks.set(this);
            } else {
              Tween.propHooks._default.set(this);
            }
            return this;
          }
        };
        Tween.prototype.init.prototype = Tween.prototype;
        Tween.propHooks = {
          _default: {
            get: function(tween) {
              var result;
              if (tween.elem.nodeType !== 1 || tween.elem[tween.prop] != null && tween.elem.style[tween.prop] == null) {
                return tween.elem[tween.prop];
              }
              result = jQuery2.css(tween.elem, tween.prop, "");
              return !result || result === "auto" ? 0 : result;
            },
            set: function(tween) {
              if (jQuery2.fx.step[tween.prop]) {
                jQuery2.fx.step[tween.prop](tween);
              } else if (tween.elem.nodeType === 1 && (jQuery2.cssHooks[tween.prop] || tween.elem.style[finalPropName(tween.prop)] != null)) {
                jQuery2.style(tween.elem, tween.prop, tween.now + tween.unit);
              } else {
                tween.elem[tween.prop] = tween.now;
              }
            }
          }
        };
        Tween.propHooks.scrollTop = Tween.propHooks.scrollLeft = {
          set: function(tween) {
            if (tween.elem.nodeType && tween.elem.parentNode) {
              tween.elem[tween.prop] = tween.now;
            }
          }
        };
        jQuery2.easing = {
          linear: function(p) {
            return p;
          },
          swing: function(p) {
            return 0.5 - Math.cos(p * Math.PI) / 2;
          },
          _default: "swing"
        };
        jQuery2.fx = Tween.prototype.init;
        jQuery2.fx.step = {};
        var fxNow, inProgress, rfxtypes = /^(?:toggle|show|hide)$/, rrun = /queueHooks$/;
        function schedule() {
          if (inProgress) {
            if (document2.hidden === false && window2.requestAnimationFrame) {
              window2.requestAnimationFrame(schedule);
            } else {
              window2.setTimeout(schedule, jQuery2.fx.interval);
            }
            jQuery2.fx.tick();
          }
        }
        function createFxNow() {
          window2.setTimeout(function() {
            fxNow = void 0;
          });
          return fxNow = Date.now();
        }
        function genFx(type, includeWidth) {
          var which, i = 0, attrs = { height: type };
          includeWidth = includeWidth ? 1 : 0;
          for (; i < 4; i += 2 - includeWidth) {
            which = cssExpand[i];
            attrs["margin" + which] = attrs["padding" + which] = type;
          }
          if (includeWidth) {
            attrs.opacity = attrs.width = type;
          }
          return attrs;
        }
        function createTween(value, prop, animation) {
          var tween, collection = (Animation.tweeners[prop] || []).concat(Animation.tweeners["*"]), index = 0, length = collection.length;
          for (; index < length; index++) {
            if (tween = collection[index].call(animation, prop, value)) {
              return tween;
            }
          }
        }
        function defaultPrefilter(elem, props, opts) {
          var prop, value, toggle, hooks, oldfire, propTween, restoreDisplay, display, isBox = "width" in props || "height" in props, anim = this, orig = {}, style = elem.style, hidden = elem.nodeType && isHiddenWithinTree(elem), dataShow = dataPriv.get(elem, "fxshow");
          if (!opts.queue) {
            hooks = jQuery2._queueHooks(elem, "fx");
            if (hooks.unqueued == null) {
              hooks.unqueued = 0;
              oldfire = hooks.empty.fire;
              hooks.empty.fire = function() {
                if (!hooks.unqueued) {
                  oldfire();
                }
              };
            }
            hooks.unqueued++;
            anim.always(function() {
              anim.always(function() {
                hooks.unqueued--;
                if (!jQuery2.queue(elem, "fx").length) {
                  hooks.empty.fire();
                }
              });
            });
          }
          for (prop in props) {
            value = props[prop];
            if (rfxtypes.test(value)) {
              delete props[prop];
              toggle = toggle || value === "toggle";
              if (value === (hidden ? "hide" : "show")) {
                if (value === "show" && dataShow && dataShow[prop] !== void 0) {
                  hidden = true;
                } else {
                  continue;
                }
              }
              orig[prop] = dataShow && dataShow[prop] || jQuery2.style(elem, prop);
            }
          }
          propTween = !jQuery2.isEmptyObject(props);
          if (!propTween && jQuery2.isEmptyObject(orig)) {
            return;
          }
          if (isBox && elem.nodeType === 1) {
            opts.overflow = [style.overflow, style.overflowX, style.overflowY];
            restoreDisplay = dataShow && dataShow.display;
            if (restoreDisplay == null) {
              restoreDisplay = dataPriv.get(elem, "display");
            }
            display = jQuery2.css(elem, "display");
            if (display === "none") {
              if (restoreDisplay) {
                display = restoreDisplay;
              } else {
                showHide([elem], true);
                restoreDisplay = elem.style.display || restoreDisplay;
                display = jQuery2.css(elem, "display");
                showHide([elem]);
              }
            }
            if (display === "inline" || display === "inline-block" && restoreDisplay != null) {
              if (jQuery2.css(elem, "float") === "none") {
                if (!propTween) {
                  anim.done(function() {
                    style.display = restoreDisplay;
                  });
                  if (restoreDisplay == null) {
                    display = style.display;
                    restoreDisplay = display === "none" ? "" : display;
                  }
                }
                style.display = "inline-block";
              }
            }
          }
          if (opts.overflow) {
            style.overflow = "hidden";
            anim.always(function() {
              style.overflow = opts.overflow[0];
              style.overflowX = opts.overflow[1];
              style.overflowY = opts.overflow[2];
            });
          }
          propTween = false;
          for (prop in orig) {
            if (!propTween) {
              if (dataShow) {
                if ("hidden" in dataShow) {
                  hidden = dataShow.hidden;
                }
              } else {
                dataShow = dataPriv.access(elem, "fxshow", { display: restoreDisplay });
              }
              if (toggle) {
                dataShow.hidden = !hidden;
              }
              if (hidden) {
                showHide([elem], true);
              }
              anim.done(function() {
                if (!hidden) {
                  showHide([elem]);
                }
                dataPriv.remove(elem, "fxshow");
                for (prop in orig) {
                  jQuery2.style(elem, prop, orig[prop]);
                }
              });
            }
            propTween = createTween(hidden ? dataShow[prop] : 0, prop, anim);
            if (!(prop in dataShow)) {
              dataShow[prop] = propTween.start;
              if (hidden) {
                propTween.end = propTween.start;
                propTween.start = 0;
              }
            }
          }
        }
        function propFilter(props, specialEasing) {
          var index, name, easing, value, hooks;
          for (index in props) {
            name = camelCase(index);
            easing = specialEasing[name];
            value = props[index];
            if (Array.isArray(value)) {
              easing = value[1];
              value = props[index] = value[0];
            }
            if (index !== name) {
              props[name] = value;
              delete props[index];
            }
            hooks = jQuery2.cssHooks[name];
            if (hooks && "expand" in hooks) {
              value = hooks.expand(value);
              delete props[name];
              for (index in value) {
                if (!(index in props)) {
                  props[index] = value[index];
                  specialEasing[index] = easing;
                }
              }
            } else {
              specialEasing[name] = easing;
            }
          }
        }
        function Animation(elem, properties, options) {
          var result, stopped, index = 0, length = Animation.prefilters.length, deferred = jQuery2.Deferred().always(function() {
            delete tick.elem;
          }), tick = function() {
            if (stopped) {
              return false;
            }
            var currentTime = fxNow || createFxNow(), remaining = Math.max(0, animation.startTime + animation.duration - currentTime), temp = remaining / animation.duration || 0, percent = 1 - temp, index2 = 0, length2 = animation.tweens.length;
            for (; index2 < length2; index2++) {
              animation.tweens[index2].run(percent);
            }
            deferred.notifyWith(elem, [animation, percent, remaining]);
            if (percent < 1 && length2) {
              return remaining;
            }
            if (!length2) {
              deferred.notifyWith(elem, [animation, 1, 0]);
            }
            deferred.resolveWith(elem, [animation]);
            return false;
          }, animation = deferred.promise({
            elem,
            props: jQuery2.extend({}, properties),
            opts: jQuery2.extend(true, {
              specialEasing: {},
              easing: jQuery2.easing._default
            }, options),
            originalProperties: properties,
            originalOptions: options,
            startTime: fxNow || createFxNow(),
            duration: options.duration,
            tweens: [],
            createTween: function(prop, end) {
              var tween = jQuery2.Tween(elem, animation.opts, prop, end, animation.opts.specialEasing[prop] || animation.opts.easing);
              animation.tweens.push(tween);
              return tween;
            },
            stop: function(gotoEnd) {
              var index2 = 0, length2 = gotoEnd ? animation.tweens.length : 0;
              if (stopped) {
                return this;
              }
              stopped = true;
              for (; index2 < length2; index2++) {
                animation.tweens[index2].run(1);
              }
              if (gotoEnd) {
                deferred.notifyWith(elem, [animation, 1, 0]);
                deferred.resolveWith(elem, [animation, gotoEnd]);
              } else {
                deferred.rejectWith(elem, [animation, gotoEnd]);
              }
              return this;
            }
          }), props = animation.props;
          propFilter(props, animation.opts.specialEasing);
          for (; index < length; index++) {
            result = Animation.prefilters[index].call(animation, elem, props, animation.opts);
            if (result) {
              if (isFunction(result.stop)) {
                jQuery2._queueHooks(animation.elem, animation.opts.queue).stop = result.stop.bind(result);
              }
              return result;
            }
          }
          jQuery2.map(props, createTween, animation);
          if (isFunction(animation.opts.start)) {
            animation.opts.start.call(elem, animation);
          }
          animation.progress(animation.opts.progress).done(animation.opts.done, animation.opts.complete).fail(animation.opts.fail).always(animation.opts.always);
          jQuery2.fx.timer(jQuery2.extend(tick, {
            elem,
            anim: animation,
            queue: animation.opts.queue
          }));
          return animation;
        }
        jQuery2.Animation = jQuery2.extend(Animation, {
          tweeners: {
            "*": [function(prop, value) {
              var tween = this.createTween(prop, value);
              adjustCSS(tween.elem, prop, rcssNum.exec(value), tween);
              return tween;
            }]
          },
          tweener: function(props, callback) {
            if (isFunction(props)) {
              callback = props;
              props = ["*"];
            } else {
              props = props.match(rnothtmlwhite);
            }
            var prop, index = 0, length = props.length;
            for (; index < length; index++) {
              prop = props[index];
              Animation.tweeners[prop] = Animation.tweeners[prop] || [];
              Animation.tweeners[prop].unshift(callback);
            }
          },
          prefilters: [defaultPrefilter],
          prefilter: function(callback, prepend) {
            if (prepend) {
              Animation.prefilters.unshift(callback);
            } else {
              Animation.prefilters.push(callback);
            }
          }
        });
        jQuery2.speed = function(speed, easing, fn) {
          var opt = speed && typeof speed === "object" ? jQuery2.extend({}, speed) : {
            complete: fn || !fn && easing || isFunction(speed) && speed,
            duration: speed,
            easing: fn && easing || easing && !isFunction(easing) && easing
          };
          if (jQuery2.fx.off) {
            opt.duration = 0;
          } else {
            if (typeof opt.duration !== "number") {
              if (opt.duration in jQuery2.fx.speeds) {
                opt.duration = jQuery2.fx.speeds[opt.duration];
              } else {
                opt.duration = jQuery2.fx.speeds._default;
              }
            }
          }
          if (opt.queue == null || opt.queue === true) {
            opt.queue = "fx";
          }
          opt.old = opt.complete;
          opt.complete = function() {
            if (isFunction(opt.old)) {
              opt.old.call(this);
            }
            if (opt.queue) {
              jQuery2.dequeue(this, opt.queue);
            }
          };
          return opt;
        };
        jQuery2.fn.extend({
          fadeTo: function(speed, to, easing, callback) {
            return this.filter(isHiddenWithinTree).css("opacity", 0).show().end().animate({ opacity: to }, speed, easing, callback);
          },
          animate: function(prop, speed, easing, callback) {
            var empty = jQuery2.isEmptyObject(prop), optall = jQuery2.speed(speed, easing, callback), doAnimation = function() {
              var anim = Animation(this, jQuery2.extend({}, prop), optall);
              if (empty || dataPriv.get(this, "finish")) {
                anim.stop(true);
              }
            };
            doAnimation.finish = doAnimation;
            return empty || optall.queue === false ? this.each(doAnimation) : this.queue(optall.queue, doAnimation);
          },
          stop: function(type, clearQueue, gotoEnd) {
            var stopQueue = function(hooks) {
              var stop = hooks.stop;
              delete hooks.stop;
              stop(gotoEnd);
            };
            if (typeof type !== "string") {
              gotoEnd = clearQueue;
              clearQueue = type;
              type = void 0;
            }
            if (clearQueue) {
              this.queue(type || "fx", []);
            }
            return this.each(function() {
              var dequeue = true, index = type != null && type + "queueHooks", timers = jQuery2.timers, data = dataPriv.get(this);
              if (index) {
                if (data[index] && data[index].stop) {
                  stopQueue(data[index]);
                }
              } else {
                for (index in data) {
                  if (data[index] && data[index].stop && rrun.test(index)) {
                    stopQueue(data[index]);
                  }
                }
              }
              for (index = timers.length; index--; ) {
                if (timers[index].elem === this && (type == null || timers[index].queue === type)) {
                  timers[index].anim.stop(gotoEnd);
                  dequeue = false;
                  timers.splice(index, 1);
                }
              }
              if (dequeue || !gotoEnd) {
                jQuery2.dequeue(this, type);
              }
            });
          },
          finish: function(type) {
            if (type !== false) {
              type = type || "fx";
            }
            return this.each(function() {
              var index, data = dataPriv.get(this), queue = data[type + "queue"], hooks = data[type + "queueHooks"], timers = jQuery2.timers, length = queue ? queue.length : 0;
              data.finish = true;
              jQuery2.queue(this, type, []);
              if (hooks && hooks.stop) {
                hooks.stop.call(this, true);
              }
              for (index = timers.length; index--; ) {
                if (timers[index].elem === this && timers[index].queue === type) {
                  timers[index].anim.stop(true);
                  timers.splice(index, 1);
                }
              }
              for (index = 0; index < length; index++) {
                if (queue[index] && queue[index].finish) {
                  queue[index].finish.call(this);
                }
              }
              delete data.finish;
            });
          }
        });
        jQuery2.each(["toggle", "show", "hide"], function(_i, name) {
          var cssFn = jQuery2.fn[name];
          jQuery2.fn[name] = function(speed, easing, callback) {
            return speed == null || typeof speed === "boolean" ? cssFn.apply(this, arguments) : this.animate(genFx(name, true), speed, easing, callback);
          };
        });
        jQuery2.each({
          slideDown: genFx("show"),
          slideUp: genFx("hide"),
          slideToggle: genFx("toggle"),
          fadeIn: { opacity: "show" },
          fadeOut: { opacity: "hide" },
          fadeToggle: { opacity: "toggle" }
        }, function(name, props) {
          jQuery2.fn[name] = function(speed, easing, callback) {
            return this.animate(props, speed, easing, callback);
          };
        });
        jQuery2.timers = [];
        jQuery2.fx.tick = function() {
          var timer, i = 0, timers = jQuery2.timers;
          fxNow = Date.now();
          for (; i < timers.length; i++) {
            timer = timers[i];
            if (!timer() && timers[i] === timer) {
              timers.splice(i--, 1);
            }
          }
          if (!timers.length) {
            jQuery2.fx.stop();
          }
          fxNow = void 0;
        };
        jQuery2.fx.timer = function(timer) {
          jQuery2.timers.push(timer);
          jQuery2.fx.start();
        };
        jQuery2.fx.interval = 13;
        jQuery2.fx.start = function() {
          if (inProgress) {
            return;
          }
          inProgress = true;
          schedule();
        };
        jQuery2.fx.stop = function() {
          inProgress = null;
        };
        jQuery2.fx.speeds = {
          slow: 600,
          fast: 200,
          _default: 400
        };
        jQuery2.fn.delay = function(time, type) {
          time = jQuery2.fx ? jQuery2.fx.speeds[time] || time : time;
          type = type || "fx";
          return this.queue(type, function(next, hooks) {
            var timeout = window2.setTimeout(next, time);
            hooks.stop = function() {
              window2.clearTimeout(timeout);
            };
          });
        };
        (function() {
          var input = document2.createElement("input"), select = document2.createElement("select"), opt = select.appendChild(document2.createElement("option"));
          input.type = "checkbox";
          support.checkOn = input.value !== "";
          support.optSelected = opt.selected;
          input = document2.createElement("input");
          input.value = "t";
          input.type = "radio";
          support.radioValue = input.value === "t";
        })();
        var boolHook, attrHandle = jQuery2.expr.attrHandle;
        jQuery2.fn.extend({
          attr: function(name, value) {
            return access(this, jQuery2.attr, name, value, arguments.length > 1);
          },
          removeAttr: function(name) {
            return this.each(function() {
              jQuery2.removeAttr(this, name);
            });
          }
        });
        jQuery2.extend({
          attr: function(elem, name, value) {
            var ret, hooks, nType = elem.nodeType;
            if (nType === 3 || nType === 8 || nType === 2) {
              return;
            }
            if (typeof elem.getAttribute === "undefined") {
              return jQuery2.prop(elem, name, value);
            }
            if (nType !== 1 || !jQuery2.isXMLDoc(elem)) {
              hooks = jQuery2.attrHooks[name.toLowerCase()] || (jQuery2.expr.match.bool.test(name) ? boolHook : void 0);
            }
            if (value !== void 0) {
              if (value === null) {
                jQuery2.removeAttr(elem, name);
                return;
              }
              if (hooks && "set" in hooks && (ret = hooks.set(elem, value, name)) !== void 0) {
                return ret;
              }
              elem.setAttribute(name, value + "");
              return value;
            }
            if (hooks && "get" in hooks && (ret = hooks.get(elem, name)) !== null) {
              return ret;
            }
            ret = jQuery2.find.attr(elem, name);
            return ret == null ? void 0 : ret;
          },
          attrHooks: {
            type: {
              set: function(elem, value) {
                if (!support.radioValue && value === "radio" && nodeName(elem, "input")) {
                  var val = elem.value;
                  elem.setAttribute("type", value);
                  if (val) {
                    elem.value = val;
                  }
                  return value;
                }
              }
            }
          },
          removeAttr: function(elem, value) {
            var name, i = 0, attrNames = value && value.match(rnothtmlwhite);
            if (attrNames && elem.nodeType === 1) {
              while (name = attrNames[i++]) {
                elem.removeAttribute(name);
              }
            }
          }
        });
        boolHook = {
          set: function(elem, value, name) {
            if (value === false) {
              jQuery2.removeAttr(elem, name);
            } else {
              elem.setAttribute(name, name);
            }
            return name;
          }
        };
        jQuery2.each(jQuery2.expr.match.bool.source.match(/\w+/g), function(_i, name) {
          var getter = attrHandle[name] || jQuery2.find.attr;
          attrHandle[name] = function(elem, name2, isXML) {
            var ret, handle, lowercaseName = name2.toLowerCase();
            if (!isXML) {
              handle = attrHandle[lowercaseName];
              attrHandle[lowercaseName] = ret;
              ret = getter(elem, name2, isXML) != null ? lowercaseName : null;
              attrHandle[lowercaseName] = handle;
            }
            return ret;
          };
        });
        var rfocusable = /^(?:input|select|textarea|button)$/i, rclickable = /^(?:a|area)$/i;
        jQuery2.fn.extend({
          prop: function(name, value) {
            return access(this, jQuery2.prop, name, value, arguments.length > 1);
          },
          removeProp: function(name) {
            return this.each(function() {
              delete this[jQuery2.propFix[name] || name];
            });
          }
        });
        jQuery2.extend({
          prop: function(elem, name, value) {
            var ret, hooks, nType = elem.nodeType;
            if (nType === 3 || nType === 8 || nType === 2) {
              return;
            }
            if (nType !== 1 || !jQuery2.isXMLDoc(elem)) {
              name = jQuery2.propFix[name] || name;
              hooks = jQuery2.propHooks[name];
            }
            if (value !== void 0) {
              if (hooks && "set" in hooks && (ret = hooks.set(elem, value, name)) !== void 0) {
                return ret;
              }
              return elem[name] = value;
            }
            if (hooks && "get" in hooks && (ret = hooks.get(elem, name)) !== null) {
              return ret;
            }
            return elem[name];
          },
          propHooks: {
            tabIndex: {
              get: function(elem) {
                var tabindex = jQuery2.find.attr(elem, "tabindex");
                if (tabindex) {
                  return parseInt(tabindex, 10);
                }
                if (rfocusable.test(elem.nodeName) || rclickable.test(elem.nodeName) && elem.href) {
                  return 0;
                }
                return -1;
              }
            }
          },
          propFix: {
            "for": "htmlFor",
            "class": "className"
          }
        });
        if (!support.optSelected) {
          jQuery2.propHooks.selected = {
            get: function(elem) {
              var parent = elem.parentNode;
              if (parent && parent.parentNode) {
                parent.parentNode.selectedIndex;
              }
              return null;
            },
            set: function(elem) {
              var parent = elem.parentNode;
              if (parent) {
                parent.selectedIndex;
                if (parent.parentNode) {
                  parent.parentNode.selectedIndex;
                }
              }
            }
          };
        }
        jQuery2.each([
          "tabIndex",
          "readOnly",
          "maxLength",
          "cellSpacing",
          "cellPadding",
          "rowSpan",
          "colSpan",
          "useMap",
          "frameBorder",
          "contentEditable"
        ], function() {
          jQuery2.propFix[this.toLowerCase()] = this;
        });
        function stripAndCollapse(value) {
          var tokens = value.match(rnothtmlwhite) || [];
          return tokens.join(" ");
        }
        function getClass(elem) {
          return elem.getAttribute && elem.getAttribute("class") || "";
        }
        function classesToArray(value) {
          if (Array.isArray(value)) {
            return value;
          }
          if (typeof value === "string") {
            return value.match(rnothtmlwhite) || [];
          }
          return [];
        }
        jQuery2.fn.extend({
          addClass: function(value) {
            var classes, elem, cur, curValue, clazz, j, finalValue, i = 0;
            if (isFunction(value)) {
              return this.each(function(j2) {
                jQuery2(this).addClass(value.call(this, j2, getClass(this)));
              });
            }
            classes = classesToArray(value);
            if (classes.length) {
              while (elem = this[i++]) {
                curValue = getClass(elem);
                cur = elem.nodeType === 1 && " " + stripAndCollapse(curValue) + " ";
                if (cur) {
                  j = 0;
                  while (clazz = classes[j++]) {
                    if (cur.indexOf(" " + clazz + " ") < 0) {
                      cur += clazz + " ";
                    }
                  }
                  finalValue = stripAndCollapse(cur);
                  if (curValue !== finalValue) {
                    elem.setAttribute("class", finalValue);
                  }
                }
              }
            }
            return this;
          },
          removeClass: function(value) {
            var classes, elem, cur, curValue, clazz, j, finalValue, i = 0;
            if (isFunction(value)) {
              return this.each(function(j2) {
                jQuery2(this).removeClass(value.call(this, j2, getClass(this)));
              });
            }
            if (!arguments.length) {
              return this.attr("class", "");
            }
            classes = classesToArray(value);
            if (classes.length) {
              while (elem = this[i++]) {
                curValue = getClass(elem);
                cur = elem.nodeType === 1 && " " + stripAndCollapse(curValue) + " ";
                if (cur) {
                  j = 0;
                  while (clazz = classes[j++]) {
                    while (cur.indexOf(" " + clazz + " ") > -1) {
                      cur = cur.replace(" " + clazz + " ", " ");
                    }
                  }
                  finalValue = stripAndCollapse(cur);
                  if (curValue !== finalValue) {
                    elem.setAttribute("class", finalValue);
                  }
                }
              }
            }
            return this;
          },
          toggleClass: function(value, stateVal) {
            var type = typeof value, isValidValue = type === "string" || Array.isArray(value);
            if (typeof stateVal === "boolean" && isValidValue) {
              return stateVal ? this.addClass(value) : this.removeClass(value);
            }
            if (isFunction(value)) {
              return this.each(function(i) {
                jQuery2(this).toggleClass(value.call(this, i, getClass(this), stateVal), stateVal);
              });
            }
            return this.each(function() {
              var className, i, self2, classNames;
              if (isValidValue) {
                i = 0;
                self2 = jQuery2(this);
                classNames = classesToArray(value);
                while (className = classNames[i++]) {
                  if (self2.hasClass(className)) {
                    self2.removeClass(className);
                  } else {
                    self2.addClass(className);
                  }
                }
              } else if (value === void 0 || type === "boolean") {
                className = getClass(this);
                if (className) {
                  dataPriv.set(this, "__className__", className);
                }
                if (this.setAttribute) {
                  this.setAttribute("class", className || value === false ? "" : dataPriv.get(this, "__className__") || "");
                }
              }
            });
          },
          hasClass: function(selector) {
            var className, elem, i = 0;
            className = " " + selector + " ";
            while (elem = this[i++]) {
              if (elem.nodeType === 1 && (" " + stripAndCollapse(getClass(elem)) + " ").indexOf(className) > -1) {
                return true;
              }
            }
            return false;
          }
        });
        var rreturn = /\r/g;
        jQuery2.fn.extend({
          val: function(value) {
            var hooks, ret, valueIsFunction, elem = this[0];
            if (!arguments.length) {
              if (elem) {
                hooks = jQuery2.valHooks[elem.type] || jQuery2.valHooks[elem.nodeName.toLowerCase()];
                if (hooks && "get" in hooks && (ret = hooks.get(elem, "value")) !== void 0) {
                  return ret;
                }
                ret = elem.value;
                if (typeof ret === "string") {
                  return ret.replace(rreturn, "");
                }
                return ret == null ? "" : ret;
              }
              return;
            }
            valueIsFunction = isFunction(value);
            return this.each(function(i) {
              var val;
              if (this.nodeType !== 1) {
                return;
              }
              if (valueIsFunction) {
                val = value.call(this, i, jQuery2(this).val());
              } else {
                val = value;
              }
              if (val == null) {
                val = "";
              } else if (typeof val === "number") {
                val += "";
              } else if (Array.isArray(val)) {
                val = jQuery2.map(val, function(value2) {
                  return value2 == null ? "" : value2 + "";
                });
              }
              hooks = jQuery2.valHooks[this.type] || jQuery2.valHooks[this.nodeName.toLowerCase()];
              if (!hooks || !("set" in hooks) || hooks.set(this, val, "value") === void 0) {
                this.value = val;
              }
            });
          }
        });
        jQuery2.extend({
          valHooks: {
            option: {
              get: function(elem) {
                var val = jQuery2.find.attr(elem, "value");
                return val != null ? val : stripAndCollapse(jQuery2.text(elem));
              }
            },
            select: {
              get: function(elem) {
                var value, option, i, options = elem.options, index = elem.selectedIndex, one = elem.type === "select-one", values = one ? null : [], max = one ? index + 1 : options.length;
                if (index < 0) {
                  i = max;
                } else {
                  i = one ? index : 0;
                }
                for (; i < max; i++) {
                  option = options[i];
                  if ((option.selected || i === index) && !option.disabled && (!option.parentNode.disabled || !nodeName(option.parentNode, "optgroup"))) {
                    value = jQuery2(option).val();
                    if (one) {
                      return value;
                    }
                    values.push(value);
                  }
                }
                return values;
              },
              set: function(elem, value) {
                var optionSet, option, options = elem.options, values = jQuery2.makeArray(value), i = options.length;
                while (i--) {
                  option = options[i];
                  if (option.selected = jQuery2.inArray(jQuery2.valHooks.option.get(option), values) > -1) {
                    optionSet = true;
                  }
                }
                if (!optionSet) {
                  elem.selectedIndex = -1;
                }
                return values;
              }
            }
          }
        });
        jQuery2.each(["radio", "checkbox"], function() {
          jQuery2.valHooks[this] = {
            set: function(elem, value) {
              if (Array.isArray(value)) {
                return elem.checked = jQuery2.inArray(jQuery2(elem).val(), value) > -1;
              }
            }
          };
          if (!support.checkOn) {
            jQuery2.valHooks[this].get = function(elem) {
              return elem.getAttribute("value") === null ? "on" : elem.value;
            };
          }
        });
        support.focusin = "onfocusin" in window2;
        var rfocusMorph = /^(?:focusinfocus|focusoutblur)$/, stopPropagationCallback = function(e) {
          e.stopPropagation();
        };
        jQuery2.extend(jQuery2.event, {
          trigger: function(event, data, elem, onlyHandlers) {
            var i, cur, tmp, bubbleType, ontype, handle, special, lastElement, eventPath = [elem || document2], type = hasOwn.call(event, "type") ? event.type : event, namespaces = hasOwn.call(event, "namespace") ? event.namespace.split(".") : [];
            cur = lastElement = tmp = elem = elem || document2;
            if (elem.nodeType === 3 || elem.nodeType === 8) {
              return;
            }
            if (rfocusMorph.test(type + jQuery2.event.triggered)) {
              return;
            }
            if (type.indexOf(".") > -1) {
              namespaces = type.split(".");
              type = namespaces.shift();
              namespaces.sort();
            }
            ontype = type.indexOf(":") < 0 && "on" + type;
            event = event[jQuery2.expando] ? event : new jQuery2.Event(type, typeof event === "object" && event);
            event.isTrigger = onlyHandlers ? 2 : 3;
            event.namespace = namespaces.join(".");
            event.rnamespace = event.namespace ? new RegExp("(^|\\.)" + namespaces.join("\\.(?:.*\\.|)") + "(\\.|$)") : null;
            event.result = void 0;
            if (!event.target) {
              event.target = elem;
            }
            data = data == null ? [event] : jQuery2.makeArray(data, [event]);
            special = jQuery2.event.special[type] || {};
            if (!onlyHandlers && special.trigger && special.trigger.apply(elem, data) === false) {
              return;
            }
            if (!onlyHandlers && !special.noBubble && !isWindow(elem)) {
              bubbleType = special.delegateType || type;
              if (!rfocusMorph.test(bubbleType + type)) {
                cur = cur.parentNode;
              }
              for (; cur; cur = cur.parentNode) {
                eventPath.push(cur);
                tmp = cur;
              }
              if (tmp === (elem.ownerDocument || document2)) {
                eventPath.push(tmp.defaultView || tmp.parentWindow || window2);
              }
            }
            i = 0;
            while ((cur = eventPath[i++]) && !event.isPropagationStopped()) {
              lastElement = cur;
              event.type = i > 1 ? bubbleType : special.bindType || type;
              handle = (dataPriv.get(cur, "events") || /* @__PURE__ */ Object.create(null))[event.type] && dataPriv.get(cur, "handle");
              if (handle) {
                handle.apply(cur, data);
              }
              handle = ontype && cur[ontype];
              if (handle && handle.apply && acceptData(cur)) {
                event.result = handle.apply(cur, data);
                if (event.result === false) {
                  event.preventDefault();
                }
              }
            }
            event.type = type;
            if (!onlyHandlers && !event.isDefaultPrevented()) {
              if ((!special._default || special._default.apply(eventPath.pop(), data) === false) && acceptData(elem)) {
                if (ontype && isFunction(elem[type]) && !isWindow(elem)) {
                  tmp = elem[ontype];
                  if (tmp) {
                    elem[ontype] = null;
                  }
                  jQuery2.event.triggered = type;
                  if (event.isPropagationStopped()) {
                    lastElement.addEventListener(type, stopPropagationCallback);
                  }
                  elem[type]();
                  if (event.isPropagationStopped()) {
                    lastElement.removeEventListener(type, stopPropagationCallback);
                  }
                  jQuery2.event.triggered = void 0;
                  if (tmp) {
                    elem[ontype] = tmp;
                  }
                }
              }
            }
            return event.result;
          },
          simulate: function(type, elem, event) {
            var e = jQuery2.extend(new jQuery2.Event(), event, {
              type,
              isSimulated: true
            });
            jQuery2.event.trigger(e, null, elem);
          }
        });
        jQuery2.fn.extend({
          trigger: function(type, data) {
            return this.each(function() {
              jQuery2.event.trigger(type, data, this);
            });
          },
          triggerHandler: function(type, data) {
            var elem = this[0];
            if (elem) {
              return jQuery2.event.trigger(type, data, elem, true);
            }
          }
        });
        if (!support.focusin) {
          jQuery2.each({ focus: "focusin", blur: "focusout" }, function(orig, fix) {
            var handler = function(event) {
              jQuery2.event.simulate(fix, event.target, jQuery2.event.fix(event));
            };
            jQuery2.event.special[fix] = {
              setup: function() {
                var doc = this.ownerDocument || this.document || this, attaches = dataPriv.access(doc, fix);
                if (!attaches) {
                  doc.addEventListener(orig, handler, true);
                }
                dataPriv.access(doc, fix, (attaches || 0) + 1);
              },
              teardown: function() {
                var doc = this.ownerDocument || this.document || this, attaches = dataPriv.access(doc, fix) - 1;
                if (!attaches) {
                  doc.removeEventListener(orig, handler, true);
                  dataPriv.remove(doc, fix);
                } else {
                  dataPriv.access(doc, fix, attaches);
                }
              }
            };
          });
        }
        var location2 = window2.location;
        var nonce = { guid: Date.now() };
        var rquery = /\?/;
        jQuery2.parseXML = function(data) {
          var xml, parserErrorElem;
          if (!data || typeof data !== "string") {
            return null;
          }
          try {
            xml = new window2.DOMParser().parseFromString(data, "text/xml");
          } catch (e) {
          }
          parserErrorElem = xml && xml.getElementsByTagName("parsererror")[0];
          if (!xml || parserErrorElem) {
            jQuery2.error("Invalid XML: " + (parserErrorElem ? jQuery2.map(parserErrorElem.childNodes, function(el) {
              return el.textContent;
            }).join("\n") : data));
          }
          return xml;
        };
        var rbracket = /\[\]$/, rCRLF = /\r?\n/g, rsubmitterTypes = /^(?:submit|button|image|reset|file)$/i, rsubmittable = /^(?:input|select|textarea|keygen)/i;
        function buildParams(prefix, obj, traditional, add) {
          var name;
          if (Array.isArray(obj)) {
            jQuery2.each(obj, function(i, v) {
              if (traditional || rbracket.test(prefix)) {
                add(prefix, v);
              } else {
                buildParams(prefix + "[" + (typeof v === "object" && v != null ? i : "") + "]", v, traditional, add);
              }
            });
          } else if (!traditional && toType(obj) === "object") {
            for (name in obj) {
              buildParams(prefix + "[" + name + "]", obj[name], traditional, add);
            }
          } else {
            add(prefix, obj);
          }
        }
        jQuery2.param = function(a, traditional) {
          var prefix, s = [], add = function(key, valueOrFunction) {
            var value = isFunction(valueOrFunction) ? valueOrFunction() : valueOrFunction;
            s[s.length] = encodeURIComponent(key) + "=" + encodeURIComponent(value == null ? "" : value);
          };
          if (a == null) {
            return "";
          }
          if (Array.isArray(a) || a.jquery && !jQuery2.isPlainObject(a)) {
            jQuery2.each(a, function() {
              add(this.name, this.value);
            });
          } else {
            for (prefix in a) {
              buildParams(prefix, a[prefix], traditional, add);
            }
          }
          return s.join("&");
        };
        jQuery2.fn.extend({
          serialize: function() {
            return jQuery2.param(this.serializeArray());
          },
          serializeArray: function() {
            return this.map(function() {
              var elements = jQuery2.prop(this, "elements");
              return elements ? jQuery2.makeArray(elements) : this;
            }).filter(function() {
              var type = this.type;
              return this.name && !jQuery2(this).is(":disabled") && rsubmittable.test(this.nodeName) && !rsubmitterTypes.test(type) && (this.checked || !rcheckableType.test(type));
            }).map(function(_i, elem) {
              var val = jQuery2(this).val();
              if (val == null) {
                return null;
              }
              if (Array.isArray(val)) {
                return jQuery2.map(val, function(val2) {
                  return { name: elem.name, value: val2.replace(rCRLF, "\r\n") };
                });
              }
              return { name: elem.name, value: val.replace(rCRLF, "\r\n") };
            }).get();
          }
        });
        var r20 = /%20/g, rhash = /#.*$/, rantiCache = /([?&])_=[^&]*/, rheaders = /^(.*?):[ \t]*([^\r\n]*)$/mg, rlocalProtocol = /^(?:about|app|app-storage|.+-extension|file|res|widget):$/, rnoContent = /^(?:GET|HEAD)$/, rprotocol = /^\/\//, prefilters = {}, transports = {}, allTypes = "*/".concat("*"), originAnchor = document2.createElement("a");
        originAnchor.href = location2.href;
        function addToPrefiltersOrTransports(structure) {
          return function(dataTypeExpression, func) {
            if (typeof dataTypeExpression !== "string") {
              func = dataTypeExpression;
              dataTypeExpression = "*";
            }
            var dataType, i = 0, dataTypes = dataTypeExpression.toLowerCase().match(rnothtmlwhite) || [];
            if (isFunction(func)) {
              while (dataType = dataTypes[i++]) {
                if (dataType[0] === "+") {
                  dataType = dataType.slice(1) || "*";
                  (structure[dataType] = structure[dataType] || []).unshift(func);
                } else {
                  (structure[dataType] = structure[dataType] || []).push(func);
                }
              }
            }
          };
        }
        function inspectPrefiltersOrTransports(structure, options, originalOptions, jqXHR) {
          var inspected = {}, seekingTransport = structure === transports;
          function inspect(dataType) {
            var selected;
            inspected[dataType] = true;
            jQuery2.each(structure[dataType] || [], function(_, prefilterOrFactory) {
              var dataTypeOrTransport = prefilterOrFactory(options, originalOptions, jqXHR);
              if (typeof dataTypeOrTransport === "string" && !seekingTransport && !inspected[dataTypeOrTransport]) {
                options.dataTypes.unshift(dataTypeOrTransport);
                inspect(dataTypeOrTransport);
                return false;
              } else if (seekingTransport) {
                return !(selected = dataTypeOrTransport);
              }
            });
            return selected;
          }
          return inspect(options.dataTypes[0]) || !inspected["*"] && inspect("*");
        }
        function ajaxExtend(target, src) {
          var key, deep, flatOptions = jQuery2.ajaxSettings.flatOptions || {};
          for (key in src) {
            if (src[key] !== void 0) {
              (flatOptions[key] ? target : deep || (deep = {}))[key] = src[key];
            }
          }
          if (deep) {
            jQuery2.extend(true, target, deep);
          }
          return target;
        }
        function ajaxHandleResponses(s, jqXHR, responses) {
          var ct, type, finalDataType, firstDataType, contents = s.contents, dataTypes = s.dataTypes;
          while (dataTypes[0] === "*") {
            dataTypes.shift();
            if (ct === void 0) {
              ct = s.mimeType || jqXHR.getResponseHeader("Content-Type");
            }
          }
          if (ct) {
            for (type in contents) {
              if (contents[type] && contents[type].test(ct)) {
                dataTypes.unshift(type);
                break;
              }
            }
          }
          if (dataTypes[0] in responses) {
            finalDataType = dataTypes[0];
          } else {
            for (type in responses) {
              if (!dataTypes[0] || s.converters[type + " " + dataTypes[0]]) {
                finalDataType = type;
                break;
              }
              if (!firstDataType) {
                firstDataType = type;
              }
            }
            finalDataType = finalDataType || firstDataType;
          }
          if (finalDataType) {
            if (finalDataType !== dataTypes[0]) {
              dataTypes.unshift(finalDataType);
            }
            return responses[finalDataType];
          }
        }
        function ajaxConvert(s, response, jqXHR, isSuccess) {
          var conv2, current, conv, tmp, prev, converters = {}, dataTypes = s.dataTypes.slice();
          if (dataTypes[1]) {
            for (conv in s.converters) {
              converters[conv.toLowerCase()] = s.converters[conv];
            }
          }
          current = dataTypes.shift();
          while (current) {
            if (s.responseFields[current]) {
              jqXHR[s.responseFields[current]] = response;
            }
            if (!prev && isSuccess && s.dataFilter) {
              response = s.dataFilter(response, s.dataType);
            }
            prev = current;
            current = dataTypes.shift();
            if (current) {
              if (current === "*") {
                current = prev;
              } else if (prev !== "*" && prev !== current) {
                conv = converters[prev + " " + current] || converters["* " + current];
                if (!conv) {
                  for (conv2 in converters) {
                    tmp = conv2.split(" ");
                    if (tmp[1] === current) {
                      conv = converters[prev + " " + tmp[0]] || converters["* " + tmp[0]];
                      if (conv) {
                        if (conv === true) {
                          conv = converters[conv2];
                        } else if (converters[conv2] !== true) {
                          current = tmp[0];
                          dataTypes.unshift(tmp[1]);
                        }
                        break;
                      }
                    }
                  }
                }
                if (conv !== true) {
                  if (conv && s.throws) {
                    response = conv(response);
                  } else {
                    try {
                      response = conv(response);
                    } catch (e) {
                      return {
                        state: "parsererror",
                        error: conv ? e : "No conversion from " + prev + " to " + current
                      };
                    }
                  }
                }
              }
            }
          }
          return { state: "success", data: response };
        }
        jQuery2.extend({
          active: 0,
          lastModified: {},
          etag: {},
          ajaxSettings: {
            url: location2.href,
            type: "GET",
            isLocal: rlocalProtocol.test(location2.protocol),
            global: true,
            processData: true,
            async: true,
            contentType: "application/x-www-form-urlencoded; charset=UTF-8",
            accepts: {
              "*": allTypes,
              text: "text/plain",
              html: "text/html",
              xml: "application/xml, text/xml",
              json: "application/json, text/javascript"
            },
            contents: {
              xml: /\bxml\b/,
              html: /\bhtml/,
              json: /\bjson\b/
            },
            responseFields: {
              xml: "responseXML",
              text: "responseText",
              json: "responseJSON"
            },
            converters: {
              "* text": String,
              "text html": true,
              "text json": JSON.parse,
              "text xml": jQuery2.parseXML
            },
            flatOptions: {
              url: true,
              context: true
            }
          },
          ajaxSetup: function(target, settings) {
            return settings ? ajaxExtend(ajaxExtend(target, jQuery2.ajaxSettings), settings) : ajaxExtend(jQuery2.ajaxSettings, target);
          },
          ajaxPrefilter: addToPrefiltersOrTransports(prefilters),
          ajaxTransport: addToPrefiltersOrTransports(transports),
          ajax: function(url, options) {
            if (typeof url === "object") {
              options = url;
              url = void 0;
            }
            options = options || {};
            var transport, cacheURL, responseHeadersString, responseHeaders, timeoutTimer, urlAnchor, completed2, fireGlobals, i, uncached, s = jQuery2.ajaxSetup({}, options), callbackContext = s.context || s, globalEventContext = s.context && (callbackContext.nodeType || callbackContext.jquery) ? jQuery2(callbackContext) : jQuery2.event, deferred = jQuery2.Deferred(), completeDeferred = jQuery2.Callbacks("once memory"), statusCode = s.statusCode || {}, requestHeaders = {}, requestHeadersNames = {}, strAbort = "canceled", jqXHR = {
              readyState: 0,
              getResponseHeader: function(key) {
                var match;
                if (completed2) {
                  if (!responseHeaders) {
                    responseHeaders = {};
                    while (match = rheaders.exec(responseHeadersString)) {
                      responseHeaders[match[1].toLowerCase() + " "] = (responseHeaders[match[1].toLowerCase() + " "] || []).concat(match[2]);
                    }
                  }
                  match = responseHeaders[key.toLowerCase() + " "];
                }
                return match == null ? null : match.join(", ");
              },
              getAllResponseHeaders: function() {
                return completed2 ? responseHeadersString : null;
              },
              setRequestHeader: function(name, value) {
                if (completed2 == null) {
                  name = requestHeadersNames[name.toLowerCase()] = requestHeadersNames[name.toLowerCase()] || name;
                  requestHeaders[name] = value;
                }
                return this;
              },
              overrideMimeType: function(type) {
                if (completed2 == null) {
                  s.mimeType = type;
                }
                return this;
              },
              statusCode: function(map) {
                var code;
                if (map) {
                  if (completed2) {
                    jqXHR.always(map[jqXHR.status]);
                  } else {
                    for (code in map) {
                      statusCode[code] = [statusCode[code], map[code]];
                    }
                  }
                }
                return this;
              },
              abort: function(statusText) {
                var finalText = statusText || strAbort;
                if (transport) {
                  transport.abort(finalText);
                }
                done(0, finalText);
                return this;
              }
            };
            deferred.promise(jqXHR);
            s.url = ((url || s.url || location2.href) + "").replace(rprotocol, location2.protocol + "//");
            s.type = options.method || options.type || s.method || s.type;
            s.dataTypes = (s.dataType || "*").toLowerCase().match(rnothtmlwhite) || [""];
            if (s.crossDomain == null) {
              urlAnchor = document2.createElement("a");
              try {
                urlAnchor.href = s.url;
                urlAnchor.href = urlAnchor.href;
                s.crossDomain = originAnchor.protocol + "//" + originAnchor.host !== urlAnchor.protocol + "//" + urlAnchor.host;
              } catch (e) {
                s.crossDomain = true;
              }
            }
            if (s.data && s.processData && typeof s.data !== "string") {
              s.data = jQuery2.param(s.data, s.traditional);
            }
            inspectPrefiltersOrTransports(prefilters, s, options, jqXHR);
            if (completed2) {
              return jqXHR;
            }
            fireGlobals = jQuery2.event && s.global;
            if (fireGlobals && jQuery2.active++ === 0) {
              jQuery2.event.trigger("ajaxStart");
            }
            s.type = s.type.toUpperCase();
            s.hasContent = !rnoContent.test(s.type);
            cacheURL = s.url.replace(rhash, "");
            if (!s.hasContent) {
              uncached = s.url.slice(cacheURL.length);
              if (s.data && (s.processData || typeof s.data === "string")) {
                cacheURL += (rquery.test(cacheURL) ? "&" : "?") + s.data;
                delete s.data;
              }
              if (s.cache === false) {
                cacheURL = cacheURL.replace(rantiCache, "$1");
                uncached = (rquery.test(cacheURL) ? "&" : "?") + "_=" + nonce.guid++ + uncached;
              }
              s.url = cacheURL + uncached;
            } else if (s.data && s.processData && (s.contentType || "").indexOf("application/x-www-form-urlencoded") === 0) {
              s.data = s.data.replace(r20, "+");
            }
            if (s.ifModified) {
              if (jQuery2.lastModified[cacheURL]) {
                jqXHR.setRequestHeader("If-Modified-Since", jQuery2.lastModified[cacheURL]);
              }
              if (jQuery2.etag[cacheURL]) {
                jqXHR.setRequestHeader("If-None-Match", jQuery2.etag[cacheURL]);
              }
            }
            if (s.data && s.hasContent && s.contentType !== false || options.contentType) {
              jqXHR.setRequestHeader("Content-Type", s.contentType);
            }
            jqXHR.setRequestHeader("Accept", s.dataTypes[0] && s.accepts[s.dataTypes[0]] ? s.accepts[s.dataTypes[0]] + (s.dataTypes[0] !== "*" ? ", " + allTypes + "; q=0.01" : "") : s.accepts["*"]);
            for (i in s.headers) {
              jqXHR.setRequestHeader(i, s.headers[i]);
            }
            if (s.beforeSend && (s.beforeSend.call(callbackContext, jqXHR, s) === false || completed2)) {
              return jqXHR.abort();
            }
            strAbort = "abort";
            completeDeferred.add(s.complete);
            jqXHR.done(s.success);
            jqXHR.fail(s.error);
            transport = inspectPrefiltersOrTransports(transports, s, options, jqXHR);
            if (!transport) {
              done(-1, "No Transport");
            } else {
              jqXHR.readyState = 1;
              if (fireGlobals) {
                globalEventContext.trigger("ajaxSend", [jqXHR, s]);
              }
              if (completed2) {
                return jqXHR;
              }
              if (s.async && s.timeout > 0) {
                timeoutTimer = window2.setTimeout(function() {
                  jqXHR.abort("timeout");
                }, s.timeout);
              }
              try {
                completed2 = false;
                transport.send(requestHeaders, done);
              } catch (e) {
                if (completed2) {
                  throw e;
                }
                done(-1, e);
              }
            }
            function done(status, nativeStatusText, responses, headers) {
              var isSuccess, success, error, response, modified, statusText = nativeStatusText;
              if (completed2) {
                return;
              }
              completed2 = true;
              if (timeoutTimer) {
                window2.clearTimeout(timeoutTimer);
              }
              transport = void 0;
              responseHeadersString = headers || "";
              jqXHR.readyState = status > 0 ? 4 : 0;
              isSuccess = status >= 200 && status < 300 || status === 304;
              if (responses) {
                response = ajaxHandleResponses(s, jqXHR, responses);
              }
              if (!isSuccess && jQuery2.inArray("script", s.dataTypes) > -1 && jQuery2.inArray("json", s.dataTypes) < 0) {
                s.converters["text script"] = function() {
                };
              }
              response = ajaxConvert(s, response, jqXHR, isSuccess);
              if (isSuccess) {
                if (s.ifModified) {
                  modified = jqXHR.getResponseHeader("Last-Modified");
                  if (modified) {
                    jQuery2.lastModified[cacheURL] = modified;
                  }
                  modified = jqXHR.getResponseHeader("etag");
                  if (modified) {
                    jQuery2.etag[cacheURL] = modified;
                  }
                }
                if (status === 204 || s.type === "HEAD") {
                  statusText = "nocontent";
                } else if (status === 304) {
                  statusText = "notmodified";
                } else {
                  statusText = response.state;
                  success = response.data;
                  error = response.error;
                  isSuccess = !error;
                }
              } else {
                error = statusText;
                if (status || !statusText) {
                  statusText = "error";
                  if (status < 0) {
                    status = 0;
                  }
                }
              }
              jqXHR.status = status;
              jqXHR.statusText = (nativeStatusText || statusText) + "";
              if (isSuccess) {
                deferred.resolveWith(callbackContext, [success, statusText, jqXHR]);
              } else {
                deferred.rejectWith(callbackContext, [jqXHR, statusText, error]);
              }
              jqXHR.statusCode(statusCode);
              statusCode = void 0;
              if (fireGlobals) {
                globalEventContext.trigger(isSuccess ? "ajaxSuccess" : "ajaxError", [jqXHR, s, isSuccess ? success : error]);
              }
              completeDeferred.fireWith(callbackContext, [jqXHR, statusText]);
              if (fireGlobals) {
                globalEventContext.trigger("ajaxComplete", [jqXHR, s]);
                if (!--jQuery2.active) {
                  jQuery2.event.trigger("ajaxStop");
                }
              }
            }
            return jqXHR;
          },
          getJSON: function(url, data, callback) {
            return jQuery2.get(url, data, callback, "json");
          },
          getScript: function(url, callback) {
            return jQuery2.get(url, void 0, callback, "script");
          }
        });
        jQuery2.each(["get", "post"], function(_i, method) {
          jQuery2[method] = function(url, data, callback, type) {
            if (isFunction(data)) {
              type = type || callback;
              callback = data;
              data = void 0;
            }
            return jQuery2.ajax(jQuery2.extend({
              url,
              type: method,
              dataType: type,
              data,
              success: callback
            }, jQuery2.isPlainObject(url) && url));
          };
        });
        jQuery2.ajaxPrefilter(function(s) {
          var i;
          for (i in s.headers) {
            if (i.toLowerCase() === "content-type") {
              s.contentType = s.headers[i] || "";
            }
          }
        });
        jQuery2._evalUrl = function(url, options, doc) {
          return jQuery2.ajax({
            url,
            type: "GET",
            dataType: "script",
            cache: true,
            async: false,
            global: false,
            converters: {
              "text script": function() {
              }
            },
            dataFilter: function(response) {
              jQuery2.globalEval(response, options, doc);
            }
          });
        };
        jQuery2.fn.extend({
          wrapAll: function(html) {
            var wrap;
            if (this[0]) {
              if (isFunction(html)) {
                html = html.call(this[0]);
              }
              wrap = jQuery2(html, this[0].ownerDocument).eq(0).clone(true);
              if (this[0].parentNode) {
                wrap.insertBefore(this[0]);
              }
              wrap.map(function() {
                var elem = this;
                while (elem.firstElementChild) {
                  elem = elem.firstElementChild;
                }
                return elem;
              }).append(this);
            }
            return this;
          },
          wrapInner: function(html) {
            if (isFunction(html)) {
              return this.each(function(i) {
                jQuery2(this).wrapInner(html.call(this, i));
              });
            }
            return this.each(function() {
              var self2 = jQuery2(this), contents = self2.contents();
              if (contents.length) {
                contents.wrapAll(html);
              } else {
                self2.append(html);
              }
            });
          },
          wrap: function(html) {
            var htmlIsFunction = isFunction(html);
            return this.each(function(i) {
              jQuery2(this).wrapAll(htmlIsFunction ? html.call(this, i) : html);
            });
          },
          unwrap: function(selector) {
            this.parent(selector).not("body").each(function() {
              jQuery2(this).replaceWith(this.childNodes);
            });
            return this;
          }
        });
        jQuery2.expr.pseudos.hidden = function(elem) {
          return !jQuery2.expr.pseudos.visible(elem);
        };
        jQuery2.expr.pseudos.visible = function(elem) {
          return !!(elem.offsetWidth || elem.offsetHeight || elem.getClientRects().length);
        };
        jQuery2.ajaxSettings.xhr = function() {
          try {
            return new window2.XMLHttpRequest();
          } catch (e) {
          }
        };
        var xhrSuccessStatus = {
          0: 200,
          1223: 204
        }, xhrSupported = jQuery2.ajaxSettings.xhr();
        support.cors = !!xhrSupported && "withCredentials" in xhrSupported;
        support.ajax = xhrSupported = !!xhrSupported;
        jQuery2.ajaxTransport(function(options) {
          var callback, errorCallback;
          if (support.cors || xhrSupported && !options.crossDomain) {
            return {
              send: function(headers, complete) {
                var i, xhr = options.xhr();
                xhr.open(options.type, options.url, options.async, options.username, options.password);
                if (options.xhrFields) {
                  for (i in options.xhrFields) {
                    xhr[i] = options.xhrFields[i];
                  }
                }
                if (options.mimeType && xhr.overrideMimeType) {
                  xhr.overrideMimeType(options.mimeType);
                }
                if (!options.crossDomain && !headers["X-Requested-With"]) {
                  headers["X-Requested-With"] = "XMLHttpRequest";
                }
                for (i in headers) {
                  xhr.setRequestHeader(i, headers[i]);
                }
                callback = function(type) {
                  return function() {
                    if (callback) {
                      callback = errorCallback = xhr.onload = xhr.onerror = xhr.onabort = xhr.ontimeout = xhr.onreadystatechange = null;
                      if (type === "abort") {
                        xhr.abort();
                      } else if (type === "error") {
                        if (typeof xhr.status !== "number") {
                          complete(0, "error");
                        } else {
                          complete(xhr.status, xhr.statusText);
                        }
                      } else {
                        complete(xhrSuccessStatus[xhr.status] || xhr.status, xhr.statusText, (xhr.responseType || "text") !== "text" || typeof xhr.responseText !== "string" ? { binary: xhr.response } : { text: xhr.responseText }, xhr.getAllResponseHeaders());
                      }
                    }
                  };
                };
                xhr.onload = callback();
                errorCallback = xhr.onerror = xhr.ontimeout = callback("error");
                if (xhr.onabort !== void 0) {
                  xhr.onabort = errorCallback;
                } else {
                  xhr.onreadystatechange = function() {
                    if (xhr.readyState === 4) {
                      window2.setTimeout(function() {
                        if (callback) {
                          errorCallback();
                        }
                      });
                    }
                  };
                }
                callback = callback("abort");
                try {
                  xhr.send(options.hasContent && options.data || null);
                } catch (e) {
                  if (callback) {
                    throw e;
                  }
                }
              },
              abort: function() {
                if (callback) {
                  callback();
                }
              }
            };
          }
        });
        jQuery2.ajaxPrefilter(function(s) {
          if (s.crossDomain) {
            s.contents.script = false;
          }
        });
        jQuery2.ajaxSetup({
          accepts: {
            script: "text/javascript, application/javascript, application/ecmascript, application/x-ecmascript"
          },
          contents: {
            script: /\b(?:java|ecma)script\b/
          },
          converters: {
            "text script": function(text) {
              jQuery2.globalEval(text);
              return text;
            }
          }
        });
        jQuery2.ajaxPrefilter("script", function(s) {
          if (s.cache === void 0) {
            s.cache = false;
          }
          if (s.crossDomain) {
            s.type = "GET";
          }
        });
        jQuery2.ajaxTransport("script", function(s) {
          if (s.crossDomain || s.scriptAttrs) {
            var script, callback;
            return {
              send: function(_, complete) {
                script = jQuery2("<script>").attr(s.scriptAttrs || {}).prop({ charset: s.scriptCharset, src: s.url }).on("load error", callback = function(evt) {
                  script.remove();
                  callback = null;
                  if (evt) {
                    complete(evt.type === "error" ? 404 : 200, evt.type);
                  }
                });
                document2.head.appendChild(script[0]);
              },
              abort: function() {
                if (callback) {
                  callback();
                }
              }
            };
          }
        });
        var oldCallbacks = [], rjsonp = /(=)\?(?=&|$)|\?\?/;
        jQuery2.ajaxSetup({
          jsonp: "callback",
          jsonpCallback: function() {
            var callback = oldCallbacks.pop() || jQuery2.expando + "_" + nonce.guid++;
            this[callback] = true;
            return callback;
          }
        });
        jQuery2.ajaxPrefilter("json jsonp", function(s, originalSettings, jqXHR) {
          var callbackName, overwritten, responseContainer, jsonProp = s.jsonp !== false && (rjsonp.test(s.url) ? "url" : typeof s.data === "string" && (s.contentType || "").indexOf("application/x-www-form-urlencoded") === 0 && rjsonp.test(s.data) && "data");
          if (jsonProp || s.dataTypes[0] === "jsonp") {
            callbackName = s.jsonpCallback = isFunction(s.jsonpCallback) ? s.jsonpCallback() : s.jsonpCallback;
            if (jsonProp) {
              s[jsonProp] = s[jsonProp].replace(rjsonp, "$1" + callbackName);
            } else if (s.jsonp !== false) {
              s.url += (rquery.test(s.url) ? "&" : "?") + s.jsonp + "=" + callbackName;
            }
            s.converters["script json"] = function() {
              if (!responseContainer) {
                jQuery2.error(callbackName + " was not called");
              }
              return responseContainer[0];
            };
            s.dataTypes[0] = "json";
            overwritten = window2[callbackName];
            window2[callbackName] = function() {
              responseContainer = arguments;
            };
            jqXHR.always(function() {
              if (overwritten === void 0) {
                jQuery2(window2).removeProp(callbackName);
              } else {
                window2[callbackName] = overwritten;
              }
              if (s[callbackName]) {
                s.jsonpCallback = originalSettings.jsonpCallback;
                oldCallbacks.push(callbackName);
              }
              if (responseContainer && isFunction(overwritten)) {
                overwritten(responseContainer[0]);
              }
              responseContainer = overwritten = void 0;
            });
            return "script";
          }
        });
        support.createHTMLDocument = function() {
          var body = document2.implementation.createHTMLDocument("").body;
          body.innerHTML = "<form></form><form></form>";
          return body.childNodes.length === 2;
        }();
        jQuery2.parseHTML = function(data, context, keepScripts) {
          if (typeof data !== "string") {
            return [];
          }
          if (typeof context === "boolean") {
            keepScripts = context;
            context = false;
          }
          var base, parsed, scripts;
          if (!context) {
            if (support.createHTMLDocument) {
              context = document2.implementation.createHTMLDocument("");
              base = context.createElement("base");
              base.href = document2.location.href;
              context.head.appendChild(base);
            } else {
              context = document2;
            }
          }
          parsed = rsingleTag.exec(data);
          scripts = !keepScripts && [];
          if (parsed) {
            return [context.createElement(parsed[1])];
          }
          parsed = buildFragment([data], context, scripts);
          if (scripts && scripts.length) {
            jQuery2(scripts).remove();
          }
          return jQuery2.merge([], parsed.childNodes);
        };
        jQuery2.fn.load = function(url, params, callback) {
          var selector, type, response, self2 = this, off = url.indexOf(" ");
          if (off > -1) {
            selector = stripAndCollapse(url.slice(off));
            url = url.slice(0, off);
          }
          if (isFunction(params)) {
            callback = params;
            params = void 0;
          } else if (params && typeof params === "object") {
            type = "POST";
          }
          if (self2.length > 0) {
            jQuery2.ajax({
              url,
              type: type || "GET",
              dataType: "html",
              data: params
            }).done(function(responseText) {
              response = arguments;
              self2.html(selector ? jQuery2("<div>").append(jQuery2.parseHTML(responseText)).find(selector) : responseText);
            }).always(callback && function(jqXHR, status) {
              self2.each(function() {
                callback.apply(this, response || [jqXHR.responseText, status, jqXHR]);
              });
            });
          }
          return this;
        };
        jQuery2.expr.pseudos.animated = function(elem) {
          return jQuery2.grep(jQuery2.timers, function(fn) {
            return elem === fn.elem;
          }).length;
        };
        jQuery2.offset = {
          setOffset: function(elem, options, i) {
            var curPosition, curLeft, curCSSTop, curTop, curOffset, curCSSLeft, calculatePosition, position = jQuery2.css(elem, "position"), curElem = jQuery2(elem), props = {};
            if (position === "static") {
              elem.style.position = "relative";
            }
            curOffset = curElem.offset();
            curCSSTop = jQuery2.css(elem, "top");
            curCSSLeft = jQuery2.css(elem, "left");
            calculatePosition = (position === "absolute" || position === "fixed") && (curCSSTop + curCSSLeft).indexOf("auto") > -1;
            if (calculatePosition) {
              curPosition = curElem.position();
              curTop = curPosition.top;
              curLeft = curPosition.left;
            } else {
              curTop = parseFloat(curCSSTop) || 0;
              curLeft = parseFloat(curCSSLeft) || 0;
            }
            if (isFunction(options)) {
              options = options.call(elem, i, jQuery2.extend({}, curOffset));
            }
            if (options.top != null) {
              props.top = options.top - curOffset.top + curTop;
            }
            if (options.left != null) {
              props.left = options.left - curOffset.left + curLeft;
            }
            if ("using" in options) {
              options.using.call(elem, props);
            } else {
              curElem.css(props);
            }
          }
        };
        jQuery2.fn.extend({
          offset: function(options) {
            if (arguments.length) {
              return options === void 0 ? this : this.each(function(i) {
                jQuery2.offset.setOffset(this, options, i);
              });
            }
            var rect, win, elem = this[0];
            if (!elem) {
              return;
            }
            if (!elem.getClientRects().length) {
              return { top: 0, left: 0 };
            }
            rect = elem.getBoundingClientRect();
            win = elem.ownerDocument.defaultView;
            return {
              top: rect.top + win.pageYOffset,
              left: rect.left + win.pageXOffset
            };
          },
          position: function() {
            if (!this[0]) {
              return;
            }
            var offsetParent, offset, doc, elem = this[0], parentOffset = { top: 0, left: 0 };
            if (jQuery2.css(elem, "position") === "fixed") {
              offset = elem.getBoundingClientRect();
            } else {
              offset = this.offset();
              doc = elem.ownerDocument;
              offsetParent = elem.offsetParent || doc.documentElement;
              while (offsetParent && (offsetParent === doc.body || offsetParent === doc.documentElement) && jQuery2.css(offsetParent, "position") === "static") {
                offsetParent = offsetParent.parentNode;
              }
              if (offsetParent && offsetParent !== elem && offsetParent.nodeType === 1) {
                parentOffset = jQuery2(offsetParent).offset();
                parentOffset.top += jQuery2.css(offsetParent, "borderTopWidth", true);
                parentOffset.left += jQuery2.css(offsetParent, "borderLeftWidth", true);
              }
            }
            return {
              top: offset.top - parentOffset.top - jQuery2.css(elem, "marginTop", true),
              left: offset.left - parentOffset.left - jQuery2.css(elem, "marginLeft", true)
            };
          },
          offsetParent: function() {
            return this.map(function() {
              var offsetParent = this.offsetParent;
              while (offsetParent && jQuery2.css(offsetParent, "position") === "static") {
                offsetParent = offsetParent.offsetParent;
              }
              return offsetParent || documentElement;
            });
          }
        });
        jQuery2.each({ scrollLeft: "pageXOffset", scrollTop: "pageYOffset" }, function(method, prop) {
          var top = prop === "pageYOffset";
          jQuery2.fn[method] = function(val) {
            return access(this, function(elem, method2, val2) {
              var win;
              if (isWindow(elem)) {
                win = elem;
              } else if (elem.nodeType === 9) {
                win = elem.defaultView;
              }
              if (val2 === void 0) {
                return win ? win[prop] : elem[method2];
              }
              if (win) {
                win.scrollTo(!top ? val2 : win.pageXOffset, top ? val2 : win.pageYOffset);
              } else {
                elem[method2] = val2;
              }
            }, method, val, arguments.length);
          };
        });
        jQuery2.each(["top", "left"], function(_i, prop) {
          jQuery2.cssHooks[prop] = addGetHookIf(support.pixelPosition, function(elem, computed) {
            if (computed) {
              computed = curCSS(elem, prop);
              return rnumnonpx.test(computed) ? jQuery2(elem).position()[prop] + "px" : computed;
            }
          });
        });
        jQuery2.each({ Height: "height", Width: "width" }, function(name, type) {
          jQuery2.each({
            padding: "inner" + name,
            content: type,
            "": "outer" + name
          }, function(defaultExtra, funcName) {
            jQuery2.fn[funcName] = function(margin, value) {
              var chainable = arguments.length && (defaultExtra || typeof margin !== "boolean"), extra = defaultExtra || (margin === true || value === true ? "margin" : "border");
              return access(this, function(elem, type2, value2) {
                var doc;
                if (isWindow(elem)) {
                  return funcName.indexOf("outer") === 0 ? elem["inner" + name] : elem.document.documentElement["client" + name];
                }
                if (elem.nodeType === 9) {
                  doc = elem.documentElement;
                  return Math.max(elem.body["scroll" + name], doc["scroll" + name], elem.body["offset" + name], doc["offset" + name], doc["client" + name]);
                }
                return value2 === void 0 ? jQuery2.css(elem, type2, extra) : jQuery2.style(elem, type2, value2, extra);
              }, type, chainable ? margin : void 0, chainable);
            };
          });
        });
        jQuery2.each([
          "ajaxStart",
          "ajaxStop",
          "ajaxComplete",
          "ajaxError",
          "ajaxSuccess",
          "ajaxSend"
        ], function(_i, type) {
          jQuery2.fn[type] = function(fn) {
            return this.on(type, fn);
          };
        });
        jQuery2.fn.extend({
          bind: function(types, data, fn) {
            return this.on(types, null, data, fn);
          },
          unbind: function(types, fn) {
            return this.off(types, null, fn);
          },
          delegate: function(selector, types, data, fn) {
            return this.on(types, selector, data, fn);
          },
          undelegate: function(selector, types, fn) {
            return arguments.length === 1 ? this.off(selector, "**") : this.off(types, selector || "**", fn);
          },
          hover: function(fnOver, fnOut) {
            return this.mouseenter(fnOver).mouseleave(fnOut || fnOver);
          }
        });
        jQuery2.each("blur focus focusin focusout resize scroll click dblclick mousedown mouseup mousemove mouseover mouseout mouseenter mouseleave change select submit keydown keypress keyup contextmenu".split(" "), function(_i, name) {
          jQuery2.fn[name] = function(data, fn) {
            return arguments.length > 0 ? this.on(name, null, data, fn) : this.trigger(name);
          };
        });
        var rtrim = /^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g;
        jQuery2.proxy = function(fn, context) {
          var tmp, args, proxy;
          if (typeof context === "string") {
            tmp = fn[context];
            context = fn;
            fn = tmp;
          }
          if (!isFunction(fn)) {
            return void 0;
          }
          args = slice.call(arguments, 2);
          proxy = function() {
            return fn.apply(context || this, args.concat(slice.call(arguments)));
          };
          proxy.guid = fn.guid = fn.guid || jQuery2.guid++;
          return proxy;
        };
        jQuery2.holdReady = function(hold) {
          if (hold) {
            jQuery2.readyWait++;
          } else {
            jQuery2.ready(true);
          }
        };
        jQuery2.isArray = Array.isArray;
        jQuery2.parseJSON = JSON.parse;
        jQuery2.nodeName = nodeName;
        jQuery2.isFunction = isFunction;
        jQuery2.isWindow = isWindow;
        jQuery2.camelCase = camelCase;
        jQuery2.type = toType;
        jQuery2.now = Date.now;
        jQuery2.isNumeric = function(obj) {
          var type = jQuery2.type(obj);
          return (type === "number" || type === "string") && !isNaN(obj - parseFloat(obj));
        };
        jQuery2.trim = function(text) {
          return text == null ? "" : (text + "").replace(rtrim, "");
        };
        if (typeof define === "function" && define.amd) {
          define("jquery", [], function() {
            return jQuery2;
          });
        }
        var _jQuery = window2.jQuery, _$ = window2.$;
        jQuery2.noConflict = function(deep) {
          if (window2.$ === jQuery2) {
            window2.$ = _$;
          }
          if (deep && window2.jQuery === jQuery2) {
            window2.jQuery = _jQuery;
          }
          return jQuery2;
        };
        if (typeof noGlobal === "undefined") {
          window2.jQuery = window2.$ = jQuery2;
        }
        return jQuery2;
      });
    }
  });

  // node_modules/datatables.net/js/jquery.dataTables.js
  var require_jquery_dataTables = __commonJS({
    "node_modules/datatables.net/js/jquery.dataTables.js"(exports, module) {
      (function(factory) {
        "use strict";
        if (typeof define === "function" && define.amd) {
          define(["jquery"], function($2) {
            return factory($2, window, document);
          });
        } else if (typeof exports === "object") {
          module.exports = function(root, $2) {
            if (!root) {
              root = window;
            }
            if (!$2) {
              $2 = typeof window !== "undefined" ? require_jquery() : require_jquery()(root);
            }
            return factory($2, root, root.document);
          };
        } else {
          window.DataTable = factory(jQuery, window, document);
        }
      })(function($2, window2, document2, undefined2) {
        "use strict";
        var DataTable = function(selector, options) {
          if (this instanceof DataTable) {
            return $2(selector).DataTable(options);
          } else {
            options = selector;
          }
          this.$ = function(sSelector, oOpts) {
            return this.api(true).$(sSelector, oOpts);
          };
          this._ = function(sSelector, oOpts) {
            return this.api(true).rows(sSelector, oOpts).data();
          };
          this.api = function(traditional) {
            return traditional ? new _Api(_fnSettingsFromNode(this[_ext.iApiIndex])) : new _Api(this);
          };
          this.fnAddData = function(data, redraw) {
            var api = this.api(true);
            var rows = Array.isArray(data) && (Array.isArray(data[0]) || $2.isPlainObject(data[0])) ? api.rows.add(data) : api.row.add(data);
            if (redraw === undefined2 || redraw) {
              api.draw();
            }
            return rows.flatten().toArray();
          };
          this.fnAdjustColumnSizing = function(bRedraw) {
            var api = this.api(true).columns.adjust();
            var settings = api.settings()[0];
            var scroll = settings.oScroll;
            if (bRedraw === undefined2 || bRedraw) {
              api.draw(false);
            } else if (scroll.sX !== "" || scroll.sY !== "") {
              _fnScrollDraw(settings);
            }
          };
          this.fnClearTable = function(bRedraw) {
            var api = this.api(true).clear();
            if (bRedraw === undefined2 || bRedraw) {
              api.draw();
            }
          };
          this.fnClose = function(nTr) {
            this.api(true).row(nTr).child.hide();
          };
          this.fnDeleteRow = function(target, callback, redraw) {
            var api = this.api(true);
            var rows = api.rows(target);
            var settings = rows.settings()[0];
            var data = settings.aoData[rows[0][0]];
            rows.remove();
            if (callback) {
              callback.call(this, settings, data);
            }
            if (redraw === undefined2 || redraw) {
              api.draw();
            }
            return data;
          };
          this.fnDestroy = function(remove) {
            this.api(true).destroy(remove);
          };
          this.fnDraw = function(complete) {
            this.api(true).draw(complete);
          };
          this.fnFilter = function(sInput, iColumn, bRegex, bSmart, bShowGlobal, bCaseInsensitive) {
            var api = this.api(true);
            if (iColumn === null || iColumn === undefined2) {
              api.search(sInput, bRegex, bSmart, bCaseInsensitive);
            } else {
              api.column(iColumn).search(sInput, bRegex, bSmart, bCaseInsensitive);
            }
            api.draw();
          };
          this.fnGetData = function(src, col) {
            var api = this.api(true);
            if (src !== undefined2) {
              var type = src.nodeName ? src.nodeName.toLowerCase() : "";
              return col !== undefined2 || type == "td" || type == "th" ? api.cell(src, col).data() : api.row(src).data() || null;
            }
            return api.data().toArray();
          };
          this.fnGetNodes = function(iRow) {
            var api = this.api(true);
            return iRow !== undefined2 ? api.row(iRow).node() : api.rows().nodes().flatten().toArray();
          };
          this.fnGetPosition = function(node) {
            var api = this.api(true);
            var nodeName = node.nodeName.toUpperCase();
            if (nodeName == "TR") {
              return api.row(node).index();
            } else if (nodeName == "TD" || nodeName == "TH") {
              var cell = api.cell(node).index();
              return [
                cell.row,
                cell.columnVisible,
                cell.column
              ];
            }
            return null;
          };
          this.fnIsOpen = function(nTr) {
            return this.api(true).row(nTr).child.isShown();
          };
          this.fnOpen = function(nTr, mHtml, sClass) {
            return this.api(true).row(nTr).child(mHtml, sClass).show().child()[0];
          };
          this.fnPageChange = function(mAction, bRedraw) {
            var api = this.api(true).page(mAction);
            if (bRedraw === undefined2 || bRedraw) {
              api.draw(false);
            }
          };
          this.fnSetColumnVis = function(iCol, bShow, bRedraw) {
            var api = this.api(true).column(iCol).visible(bShow);
            if (bRedraw === undefined2 || bRedraw) {
              api.columns.adjust().draw();
            }
          };
          this.fnSettings = function() {
            return _fnSettingsFromNode(this[_ext.iApiIndex]);
          };
          this.fnSort = function(aaSort) {
            this.api(true).order(aaSort).draw();
          };
          this.fnSortListener = function(nNode, iColumn, fnCallback) {
            this.api(true).order.listener(nNode, iColumn, fnCallback);
          };
          this.fnUpdate = function(mData, mRow, iColumn, bRedraw, bAction) {
            var api = this.api(true);
            if (iColumn === undefined2 || iColumn === null) {
              api.row(mRow).data(mData);
            } else {
              api.cell(mRow, iColumn).data(mData);
            }
            if (bAction === undefined2 || bAction) {
              api.columns.adjust();
            }
            if (bRedraw === undefined2 || bRedraw) {
              api.draw();
            }
            return 0;
          };
          this.fnVersionCheck = _ext.fnVersionCheck;
          var _that = this;
          var emptyInit = options === undefined2;
          var len = this.length;
          if (emptyInit) {
            options = {};
          }
          this.oApi = this.internal = _ext.internal;
          for (var fn in DataTable.ext.internal) {
            if (fn) {
              this[fn] = _fnExternApiFunc(fn);
            }
          }
          this.each(function() {
            var o = {};
            var oInit = len > 1 ? _fnExtend(o, options, true) : options;
            var i = 0, iLen, j, jLen, k, kLen;
            var sId = this.getAttribute("id");
            var bInitHandedOff = false;
            var defaults = DataTable.defaults;
            var $this = $2(this);
            if (this.nodeName.toLowerCase() != "table") {
              _fnLog(null, 0, "Non-table node initialisation (" + this.nodeName + ")", 2);
              return;
            }
            _fnCompatOpts(defaults);
            _fnCompatCols(defaults.column);
            _fnCamelToHungarian(defaults, defaults, true);
            _fnCamelToHungarian(defaults.column, defaults.column, true);
            _fnCamelToHungarian(defaults, $2.extend(oInit, $this.data()), true);
            var allSettings = DataTable.settings;
            for (i = 0, iLen = allSettings.length; i < iLen; i++) {
              var s = allSettings[i];
              if (s.nTable == this || s.nTHead && s.nTHead.parentNode == this || s.nTFoot && s.nTFoot.parentNode == this) {
                var bRetrieve = oInit.bRetrieve !== undefined2 ? oInit.bRetrieve : defaults.bRetrieve;
                var bDestroy = oInit.bDestroy !== undefined2 ? oInit.bDestroy : defaults.bDestroy;
                if (emptyInit || bRetrieve) {
                  return s.oInstance;
                } else if (bDestroy) {
                  s.oInstance.fnDestroy();
                  break;
                } else {
                  _fnLog(s, 0, "Cannot reinitialise DataTable", 3);
                  return;
                }
              }
              if (s.sTableId == this.id) {
                allSettings.splice(i, 1);
                break;
              }
            }
            if (sId === null || sId === "") {
              sId = "DataTables_Table_" + DataTable.ext._unique++;
              this.id = sId;
            }
            var oSettings = $2.extend(true, {}, DataTable.models.oSettings, {
              "sDestroyWidth": $this[0].style.width,
              "sInstance": sId,
              "sTableId": sId
            });
            oSettings.nTable = this;
            oSettings.oApi = _that.internal;
            oSettings.oInit = oInit;
            allSettings.push(oSettings);
            oSettings.oInstance = _that.length === 1 ? _that : $this.dataTable();
            _fnCompatOpts(oInit);
            _fnLanguageCompat(oInit.oLanguage);
            if (oInit.aLengthMenu && !oInit.iDisplayLength) {
              oInit.iDisplayLength = Array.isArray(oInit.aLengthMenu[0]) ? oInit.aLengthMenu[0][0] : oInit.aLengthMenu[0];
            }
            oInit = _fnExtend($2.extend(true, {}, defaults), oInit);
            _fnMap(oSettings.oFeatures, oInit, [
              "bPaginate",
              "bLengthChange",
              "bFilter",
              "bSort",
              "bSortMulti",
              "bInfo",
              "bProcessing",
              "bAutoWidth",
              "bSortClasses",
              "bServerSide",
              "bDeferRender"
            ]);
            _fnMap(oSettings, oInit, [
              "asStripeClasses",
              "ajax",
              "fnServerData",
              "fnFormatNumber",
              "sServerMethod",
              "aaSorting",
              "aaSortingFixed",
              "aLengthMenu",
              "sPaginationType",
              "sAjaxSource",
              "sAjaxDataProp",
              "iStateDuration",
              "sDom",
              "bSortCellsTop",
              "iTabIndex",
              "fnStateLoadCallback",
              "fnStateSaveCallback",
              "renderer",
              "searchDelay",
              "rowId",
              ["iCookieDuration", "iStateDuration"],
              ["oSearch", "oPreviousSearch"],
              ["aoSearchCols", "aoPreSearchCols"],
              ["iDisplayLength", "_iDisplayLength"]
            ]);
            _fnMap(oSettings.oScroll, oInit, [
              ["sScrollX", "sX"],
              ["sScrollXInner", "sXInner"],
              ["sScrollY", "sY"],
              ["bScrollCollapse", "bCollapse"]
            ]);
            _fnMap(oSettings.oLanguage, oInit, "fnInfoCallback");
            _fnCallbackReg(oSettings, "aoDrawCallback", oInit.fnDrawCallback, "user");
            _fnCallbackReg(oSettings, "aoServerParams", oInit.fnServerParams, "user");
            _fnCallbackReg(oSettings, "aoStateSaveParams", oInit.fnStateSaveParams, "user");
            _fnCallbackReg(oSettings, "aoStateLoadParams", oInit.fnStateLoadParams, "user");
            _fnCallbackReg(oSettings, "aoStateLoaded", oInit.fnStateLoaded, "user");
            _fnCallbackReg(oSettings, "aoRowCallback", oInit.fnRowCallback, "user");
            _fnCallbackReg(oSettings, "aoRowCreatedCallback", oInit.fnCreatedRow, "user");
            _fnCallbackReg(oSettings, "aoHeaderCallback", oInit.fnHeaderCallback, "user");
            _fnCallbackReg(oSettings, "aoFooterCallback", oInit.fnFooterCallback, "user");
            _fnCallbackReg(oSettings, "aoInitComplete", oInit.fnInitComplete, "user");
            _fnCallbackReg(oSettings, "aoPreDrawCallback", oInit.fnPreDrawCallback, "user");
            oSettings.rowIdFn = _fnGetObjectDataFn(oInit.rowId);
            _fnBrowserDetect(oSettings);
            var oClasses = oSettings.oClasses;
            $2.extend(oClasses, DataTable.ext.classes, oInit.oClasses);
            $this.addClass(oClasses.sTable);
            if (oSettings.iInitDisplayStart === undefined2) {
              oSettings.iInitDisplayStart = oInit.iDisplayStart;
              oSettings._iDisplayStart = oInit.iDisplayStart;
            }
            if (oInit.iDeferLoading !== null) {
              oSettings.bDeferLoading = true;
              var tmp = Array.isArray(oInit.iDeferLoading);
              oSettings._iRecordsDisplay = tmp ? oInit.iDeferLoading[0] : oInit.iDeferLoading;
              oSettings._iRecordsTotal = tmp ? oInit.iDeferLoading[1] : oInit.iDeferLoading;
            }
            var oLanguage = oSettings.oLanguage;
            $2.extend(true, oLanguage, oInit.oLanguage);
            if (oLanguage.sUrl) {
              $2.ajax({
                dataType: "json",
                url: oLanguage.sUrl,
                success: function(json) {
                  _fnCamelToHungarian(defaults.oLanguage, json);
                  _fnLanguageCompat(json);
                  $2.extend(true, oLanguage, json);
                  _fnCallbackFire(oSettings, null, "i18n", [oSettings]);
                  _fnInitialise(oSettings);
                },
                error: function() {
                  _fnInitialise(oSettings);
                }
              });
              bInitHandedOff = true;
            } else {
              _fnCallbackFire(oSettings, null, "i18n", [oSettings]);
            }
            if (oInit.asStripeClasses === null) {
              oSettings.asStripeClasses = [
                oClasses.sStripeOdd,
                oClasses.sStripeEven
              ];
            }
            var stripeClasses = oSettings.asStripeClasses;
            var rowOne = $this.children("tbody").find("tr").eq(0);
            if ($2.inArray(true, $2.map(stripeClasses, function(el, i2) {
              return rowOne.hasClass(el);
            })) !== -1) {
              $2("tbody tr", this).removeClass(stripeClasses.join(" "));
              oSettings.asDestroyStripes = stripeClasses.slice();
            }
            var anThs = [];
            var aoColumnsInit;
            var nThead = this.getElementsByTagName("thead");
            if (nThead.length !== 0) {
              _fnDetectHeader(oSettings.aoHeader, nThead[0]);
              anThs = _fnGetUniqueThs(oSettings);
            }
            if (oInit.aoColumns === null) {
              aoColumnsInit = [];
              for (i = 0, iLen = anThs.length; i < iLen; i++) {
                aoColumnsInit.push(null);
              }
            } else {
              aoColumnsInit = oInit.aoColumns;
            }
            for (i = 0, iLen = aoColumnsInit.length; i < iLen; i++) {
              _fnAddColumn(oSettings, anThs ? anThs[i] : null);
            }
            _fnApplyColumnDefs(oSettings, oInit.aoColumnDefs, aoColumnsInit, function(iCol, oDef) {
              _fnColumnOptions(oSettings, iCol, oDef);
            });
            if (rowOne.length) {
              var a = function(cell, name) {
                return cell.getAttribute("data-" + name) !== null ? name : null;
              };
              $2(rowOne[0]).children("th, td").each(function(i2, cell) {
                var col = oSettings.aoColumns[i2];
                if (col.mData === i2) {
                  var sort = a(cell, "sort") || a(cell, "order");
                  var filter = a(cell, "filter") || a(cell, "search");
                  if (sort !== null || filter !== null) {
                    col.mData = {
                      _: i2 + ".display",
                      sort: sort !== null ? i2 + ".@data-" + sort : undefined2,
                      type: sort !== null ? i2 + ".@data-" + sort : undefined2,
                      filter: filter !== null ? i2 + ".@data-" + filter : undefined2
                    };
                    _fnColumnOptions(oSettings, i2);
                  }
                }
              });
            }
            var features = oSettings.oFeatures;
            var loadedInit = function() {
              if (oInit.aaSorting === undefined2) {
                var sorting = oSettings.aaSorting;
                for (i = 0, iLen = sorting.length; i < iLen; i++) {
                  sorting[i][1] = oSettings.aoColumns[i].asSorting[0];
                }
              }
              _fnSortingClasses(oSettings);
              if (features.bSort) {
                _fnCallbackReg(oSettings, "aoDrawCallback", function() {
                  if (oSettings.bSorted) {
                    var aSort = _fnSortFlatten(oSettings);
                    var sortedColumns = {};
                    $2.each(aSort, function(i2, val) {
                      sortedColumns[val.src] = val.dir;
                    });
                    _fnCallbackFire(oSettings, null, "order", [oSettings, aSort, sortedColumns]);
                    _fnSortAria(oSettings);
                  }
                });
              }
              _fnCallbackReg(oSettings, "aoDrawCallback", function() {
                if (oSettings.bSorted || _fnDataSource(oSettings) === "ssp" || features.bDeferRender) {
                  _fnSortingClasses(oSettings);
                }
              }, "sc");
              var captions = $this.children("caption").each(function() {
                this._captionSide = $2(this).css("caption-side");
              });
              var thead = $this.children("thead");
              if (thead.length === 0) {
                thead = $2("<thead/>").appendTo($this);
              }
              oSettings.nTHead = thead[0];
              var tbody = $this.children("tbody");
              if (tbody.length === 0) {
                tbody = $2("<tbody/>").insertAfter(thead);
              }
              oSettings.nTBody = tbody[0];
              var tfoot = $this.children("tfoot");
              if (tfoot.length === 0 && captions.length > 0 && (oSettings.oScroll.sX !== "" || oSettings.oScroll.sY !== "")) {
                tfoot = $2("<tfoot/>").appendTo($this);
              }
              if (tfoot.length === 0 || tfoot.children().length === 0) {
                $this.addClass(oClasses.sNoFooter);
              } else if (tfoot.length > 0) {
                oSettings.nTFoot = tfoot[0];
                _fnDetectHeader(oSettings.aoFooter, oSettings.nTFoot);
              }
              if (oInit.aaData) {
                for (i = 0; i < oInit.aaData.length; i++) {
                  _fnAddData(oSettings, oInit.aaData[i]);
                }
              } else if (oSettings.bDeferLoading || _fnDataSource(oSettings) == "dom") {
                _fnAddTr(oSettings, $2(oSettings.nTBody).children("tr"));
              }
              oSettings.aiDisplay = oSettings.aiDisplayMaster.slice();
              oSettings.bInitialised = true;
              if (bInitHandedOff === false) {
                _fnInitialise(oSettings);
              }
            };
            _fnCallbackReg(oSettings, "aoDrawCallback", _fnSaveState, "state_save");
            if (oInit.bStateSave) {
              features.bStateSave = true;
              _fnLoadState(oSettings, oInit, loadedInit);
            } else {
              loadedInit();
            }
          });
          _that = null;
          return this;
        };
        var _ext;
        var _Api;
        var _api_register;
        var _api_registerPlural;
        var _re_dic = {};
        var _re_new_lines = /[\r\n\u2028]/g;
        var _re_html = /<.*?>/g;
        var _re_date = /^\d{2,4}[\.\/\-]\d{1,2}[\.\/\-]\d{1,2}([T ]{1}\d{1,2}[:\.]\d{2}([\.:]\d{2})?)?$/;
        var _re_escape_regex = new RegExp("(\\" + ["/", ".", "*", "+", "?", "|", "(", ")", "[", "]", "{", "}", "\\", "$", "^", "-"].join("|\\") + ")", "g");
        var _re_formatted_numeric = /['\u00A0,$£€¥%\u2009\u202F\u20BD\u20a9\u20BArfkɃΞ]/gi;
        var _empty = function(d) {
          return !d || d === true || d === "-" ? true : false;
        };
        var _intVal = function(s) {
          var integer = parseInt(s, 10);
          return !isNaN(integer) && isFinite(s) ? integer : null;
        };
        var _numToDecimal = function(num, decimalPoint) {
          if (!_re_dic[decimalPoint]) {
            _re_dic[decimalPoint] = new RegExp(_fnEscapeRegex(decimalPoint), "g");
          }
          return typeof num === "string" && decimalPoint !== "." ? num.replace(/\./g, "").replace(_re_dic[decimalPoint], ".") : num;
        };
        var _isNumber = function(d, decimalPoint, formatted) {
          var strType = typeof d === "string";
          if (_empty(d)) {
            return true;
          }
          if (decimalPoint && strType) {
            d = _numToDecimal(d, decimalPoint);
          }
          if (formatted && strType) {
            d = d.replace(_re_formatted_numeric, "");
          }
          return !isNaN(parseFloat(d)) && isFinite(d);
        };
        var _isHtml = function(d) {
          return _empty(d) || typeof d === "string";
        };
        var _htmlNumeric = function(d, decimalPoint, formatted) {
          if (_empty(d)) {
            return true;
          }
          var html = _isHtml(d);
          return !html ? null : _isNumber(_stripHtml(d), decimalPoint, formatted) ? true : null;
        };
        var _pluck = function(a, prop, prop2) {
          var out = [];
          var i = 0, ien = a.length;
          if (prop2 !== undefined2) {
            for (; i < ien; i++) {
              if (a[i] && a[i][prop]) {
                out.push(a[i][prop][prop2]);
              }
            }
          } else {
            for (; i < ien; i++) {
              if (a[i]) {
                out.push(a[i][prop]);
              }
            }
          }
          return out;
        };
        var _pluck_order = function(a, order, prop, prop2) {
          var out = [];
          var i = 0, ien = order.length;
          if (prop2 !== undefined2) {
            for (; i < ien; i++) {
              if (a[order[i]][prop]) {
                out.push(a[order[i]][prop][prop2]);
              }
            }
          } else {
            for (; i < ien; i++) {
              out.push(a[order[i]][prop]);
            }
          }
          return out;
        };
        var _range = function(len, start) {
          var out = [];
          var end;
          if (start === undefined2) {
            start = 0;
            end = len;
          } else {
            end = start;
            start = len;
          }
          for (var i = start; i < end; i++) {
            out.push(i);
          }
          return out;
        };
        var _removeEmpty = function(a) {
          var out = [];
          for (var i = 0, ien = a.length; i < ien; i++) {
            if (a[i]) {
              out.push(a[i]);
            }
          }
          return out;
        };
        var _stripHtml = function(d) {
          return d.replace(_re_html, "");
        };
        var _areAllUnique = function(src) {
          if (src.length < 2) {
            return true;
          }
          var sorted = src.slice().sort();
          var last = sorted[0];
          for (var i = 1, ien = sorted.length; i < ien; i++) {
            if (sorted[i] === last) {
              return false;
            }
            last = sorted[i];
          }
          return true;
        };
        var _unique = function(src) {
          if (_areAllUnique(src)) {
            return src.slice();
          }
          var out = [], val, i, ien = src.length, j, k = 0;
          again:
            for (i = 0; i < ien; i++) {
              val = src[i];
              for (j = 0; j < k; j++) {
                if (out[j] === val) {
                  continue again;
                }
              }
              out.push(val);
              k++;
            }
          return out;
        };
        var _flatten = function(out, val) {
          if (Array.isArray(val)) {
            for (var i = 0; i < val.length; i++) {
              _flatten(out, val[i]);
            }
          } else {
            out.push(val);
          }
          return out;
        };
        var _includes = function(search, start) {
          if (start === undefined2) {
            start = 0;
          }
          return this.indexOf(search, start) !== -1;
        };
        if (!Array.isArray) {
          Array.isArray = function(arg) {
            return Object.prototype.toString.call(arg) === "[object Array]";
          };
        }
        if (!Array.prototype.includes) {
          Array.prototype.includes = _includes;
        }
        if (!String.prototype.trim) {
          String.prototype.trim = function() {
            return this.replace(/^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g, "");
          };
        }
        if (!String.prototype.includes) {
          String.prototype.includes = _includes;
        }
        DataTable.util = {
          throttle: function(fn, freq) {
            var frequency = freq !== undefined2 ? freq : 200, last, timer;
            return function() {
              var that = this, now = +new Date(), args = arguments;
              if (last && now < last + frequency) {
                clearTimeout(timer);
                timer = setTimeout(function() {
                  last = undefined2;
                  fn.apply(that, args);
                }, frequency);
              } else {
                last = now;
                fn.apply(that, args);
              }
            };
          },
          escapeRegex: function(val) {
            return val.replace(_re_escape_regex, "\\$1");
          },
          set: function(source) {
            if ($2.isPlainObject(source)) {
              return DataTable.util.set(source._);
            } else if (source === null) {
              return function() {
              };
            } else if (typeof source === "function") {
              return function(data, val, meta) {
                source(data, "set", val, meta);
              };
            } else if (typeof source === "string" && (source.indexOf(".") !== -1 || source.indexOf("[") !== -1 || source.indexOf("(") !== -1)) {
              var setData = function(data, val, src) {
                var a = _fnSplitObjNotation(src), b;
                var aLast = a[a.length - 1];
                var arrayNotation, funcNotation, o, innerSrc;
                for (var i = 0, iLen = a.length - 1; i < iLen; i++) {
                  if (a[i] === "__proto__" || a[i] === "constructor") {
                    throw new Error("Cannot set prototype values");
                  }
                  arrayNotation = a[i].match(__reArray);
                  funcNotation = a[i].match(__reFn);
                  if (arrayNotation) {
                    a[i] = a[i].replace(__reArray, "");
                    data[a[i]] = [];
                    b = a.slice();
                    b.splice(0, i + 1);
                    innerSrc = b.join(".");
                    if (Array.isArray(val)) {
                      for (var j = 0, jLen = val.length; j < jLen; j++) {
                        o = {};
                        setData(o, val[j], innerSrc);
                        data[a[i]].push(o);
                      }
                    } else {
                      data[a[i]] = val;
                    }
                    return;
                  } else if (funcNotation) {
                    a[i] = a[i].replace(__reFn, "");
                    data = data[a[i]](val);
                  }
                  if (data[a[i]] === null || data[a[i]] === undefined2) {
                    data[a[i]] = {};
                  }
                  data = data[a[i]];
                }
                if (aLast.match(__reFn)) {
                  data = data[aLast.replace(__reFn, "")](val);
                } else {
                  data[aLast.replace(__reArray, "")] = val;
                }
              };
              return function(data, val) {
                return setData(data, val, source);
              };
            } else {
              return function(data, val) {
                data[source] = val;
              };
            }
          },
          get: function(source) {
            if ($2.isPlainObject(source)) {
              var o = {};
              $2.each(source, function(key, val) {
                if (val) {
                  o[key] = DataTable.util.get(val);
                }
              });
              return function(data, type, row, meta) {
                var t = o[type] || o._;
                return t !== undefined2 ? t(data, type, row, meta) : data;
              };
            } else if (source === null) {
              return function(data) {
                return data;
              };
            } else if (typeof source === "function") {
              return function(data, type, row, meta) {
                return source(data, type, row, meta);
              };
            } else if (typeof source === "string" && (source.indexOf(".") !== -1 || source.indexOf("[") !== -1 || source.indexOf("(") !== -1)) {
              var fetchData = function(data, type, src) {
                var arrayNotation, funcNotation, out, innerSrc;
                if (src !== "") {
                  var a = _fnSplitObjNotation(src);
                  for (var i = 0, iLen = a.length; i < iLen; i++) {
                    arrayNotation = a[i].match(__reArray);
                    funcNotation = a[i].match(__reFn);
                    if (arrayNotation) {
                      a[i] = a[i].replace(__reArray, "");
                      if (a[i] !== "") {
                        data = data[a[i]];
                      }
                      out = [];
                      a.splice(0, i + 1);
                      innerSrc = a.join(".");
                      if (Array.isArray(data)) {
                        for (var j = 0, jLen = data.length; j < jLen; j++) {
                          out.push(fetchData(data[j], type, innerSrc));
                        }
                      }
                      var join = arrayNotation[0].substring(1, arrayNotation[0].length - 1);
                      data = join === "" ? out : out.join(join);
                      break;
                    } else if (funcNotation) {
                      a[i] = a[i].replace(__reFn, "");
                      data = data[a[i]]();
                      continue;
                    }
                    if (data === null || data[a[i]] === undefined2) {
                      return undefined2;
                    }
                    data = data[a[i]];
                  }
                }
                return data;
              };
              return function(data, type) {
                return fetchData(data, type, source);
              };
            } else {
              return function(data, type) {
                return data[source];
              };
            }
          }
        };
        function _fnHungarianMap(o) {
          var hungarian = "a aa ai ao as b fn i m o s ", match, newKey, map = {};
          $2.each(o, function(key, val) {
            match = key.match(/^([^A-Z]+?)([A-Z])/);
            if (match && hungarian.indexOf(match[1] + " ") !== -1) {
              newKey = key.replace(match[0], match[2].toLowerCase());
              map[newKey] = key;
              if (match[1] === "o") {
                _fnHungarianMap(o[key]);
              }
            }
          });
          o._hungarianMap = map;
        }
        function _fnCamelToHungarian(src, user, force) {
          if (!src._hungarianMap) {
            _fnHungarianMap(src);
          }
          var hungarianKey;
          $2.each(user, function(key, val) {
            hungarianKey = src._hungarianMap[key];
            if (hungarianKey !== undefined2 && (force || user[hungarianKey] === undefined2)) {
              if (hungarianKey.charAt(0) === "o") {
                if (!user[hungarianKey]) {
                  user[hungarianKey] = {};
                }
                $2.extend(true, user[hungarianKey], user[key]);
                _fnCamelToHungarian(src[hungarianKey], user[hungarianKey], force);
              } else {
                user[hungarianKey] = user[key];
              }
            }
          });
        }
        function _fnLanguageCompat(lang) {
          var defaults = DataTable.defaults.oLanguage;
          var defaultDecimal = defaults.sDecimal;
          if (defaultDecimal) {
            _addNumericSort(defaultDecimal);
          }
          if (lang) {
            var zeroRecords = lang.sZeroRecords;
            if (!lang.sEmptyTable && zeroRecords && defaults.sEmptyTable === "No data available in table") {
              _fnMap(lang, lang, "sZeroRecords", "sEmptyTable");
            }
            if (!lang.sLoadingRecords && zeroRecords && defaults.sLoadingRecords === "Loading...") {
              _fnMap(lang, lang, "sZeroRecords", "sLoadingRecords");
            }
            if (lang.sInfoThousands) {
              lang.sThousands = lang.sInfoThousands;
            }
            var decimal = lang.sDecimal;
            if (decimal && defaultDecimal !== decimal) {
              _addNumericSort(decimal);
            }
          }
        }
        var _fnCompatMap = function(o, knew, old) {
          if (o[knew] !== undefined2) {
            o[old] = o[knew];
          }
        };
        function _fnCompatOpts(init) {
          _fnCompatMap(init, "ordering", "bSort");
          _fnCompatMap(init, "orderMulti", "bSortMulti");
          _fnCompatMap(init, "orderClasses", "bSortClasses");
          _fnCompatMap(init, "orderCellsTop", "bSortCellsTop");
          _fnCompatMap(init, "order", "aaSorting");
          _fnCompatMap(init, "orderFixed", "aaSortingFixed");
          _fnCompatMap(init, "paging", "bPaginate");
          _fnCompatMap(init, "pagingType", "sPaginationType");
          _fnCompatMap(init, "pageLength", "iDisplayLength");
          _fnCompatMap(init, "searching", "bFilter");
          if (typeof init.sScrollX === "boolean") {
            init.sScrollX = init.sScrollX ? "100%" : "";
          }
          if (typeof init.scrollX === "boolean") {
            init.scrollX = init.scrollX ? "100%" : "";
          }
          var searchCols = init.aoSearchCols;
          if (searchCols) {
            for (var i = 0, ien = searchCols.length; i < ien; i++) {
              if (searchCols[i]) {
                _fnCamelToHungarian(DataTable.models.oSearch, searchCols[i]);
              }
            }
          }
        }
        function _fnCompatCols(init) {
          _fnCompatMap(init, "orderable", "bSortable");
          _fnCompatMap(init, "orderData", "aDataSort");
          _fnCompatMap(init, "orderSequence", "asSorting");
          _fnCompatMap(init, "orderDataType", "sortDataType");
          var dataSort = init.aDataSort;
          if (typeof dataSort === "number" && !Array.isArray(dataSort)) {
            init.aDataSort = [dataSort];
          }
        }
        function _fnBrowserDetect(settings) {
          if (!DataTable.__browser) {
            var browser = {};
            DataTable.__browser = browser;
            var n = $2("<div/>").css({
              position: "fixed",
              top: 0,
              left: $2(window2).scrollLeft() * -1,
              height: 1,
              width: 1,
              overflow: "hidden"
            }).append($2("<div/>").css({
              position: "absolute",
              top: 1,
              left: 1,
              width: 100,
              overflow: "scroll"
            }).append($2("<div/>").css({
              width: "100%",
              height: 10
            }))).appendTo("body");
            var outer = n.children();
            var inner = outer.children();
            browser.barWidth = outer[0].offsetWidth - outer[0].clientWidth;
            browser.bScrollOversize = inner[0].offsetWidth === 100 && outer[0].clientWidth !== 100;
            browser.bScrollbarLeft = Math.round(inner.offset().left) !== 1;
            browser.bBounding = n[0].getBoundingClientRect().width ? true : false;
            n.remove();
          }
          $2.extend(settings.oBrowser, DataTable.__browser);
          settings.oScroll.iBarWidth = DataTable.__browser.barWidth;
        }
        function _fnReduce(that, fn, init, start, end, inc) {
          var i = start, value, isSet = false;
          if (init !== undefined2) {
            value = init;
            isSet = true;
          }
          while (i !== end) {
            if (!that.hasOwnProperty(i)) {
              continue;
            }
            value = isSet ? fn(value, that[i], i, that) : that[i];
            isSet = true;
            i += inc;
          }
          return value;
        }
        function _fnAddColumn(oSettings, nTh) {
          var oDefaults = DataTable.defaults.column;
          var iCol = oSettings.aoColumns.length;
          var oCol = $2.extend({}, DataTable.models.oColumn, oDefaults, {
            "nTh": nTh ? nTh : document2.createElement("th"),
            "sTitle": oDefaults.sTitle ? oDefaults.sTitle : nTh ? nTh.innerHTML : "",
            "aDataSort": oDefaults.aDataSort ? oDefaults.aDataSort : [iCol],
            "mData": oDefaults.mData ? oDefaults.mData : iCol,
            idx: iCol
          });
          oSettings.aoColumns.push(oCol);
          var searchCols = oSettings.aoPreSearchCols;
          searchCols[iCol] = $2.extend({}, DataTable.models.oSearch, searchCols[iCol]);
          _fnColumnOptions(oSettings, iCol, $2(nTh).data());
        }
        function _fnColumnOptions(oSettings, iCol, oOptions) {
          var oCol = oSettings.aoColumns[iCol];
          var oClasses = oSettings.oClasses;
          var th = $2(oCol.nTh);
          if (!oCol.sWidthOrig) {
            oCol.sWidthOrig = th.attr("width") || null;
            var t = (th.attr("style") || "").match(/width:\s*(\d+[pxem%]+)/);
            if (t) {
              oCol.sWidthOrig = t[1];
            }
          }
          if (oOptions !== undefined2 && oOptions !== null) {
            _fnCompatCols(oOptions);
            _fnCamelToHungarian(DataTable.defaults.column, oOptions, true);
            if (oOptions.mDataProp !== undefined2 && !oOptions.mData) {
              oOptions.mData = oOptions.mDataProp;
            }
            if (oOptions.sType) {
              oCol._sManualType = oOptions.sType;
            }
            if (oOptions.className && !oOptions.sClass) {
              oOptions.sClass = oOptions.className;
            }
            if (oOptions.sClass) {
              th.addClass(oOptions.sClass);
            }
            $2.extend(oCol, oOptions);
            _fnMap(oCol, oOptions, "sWidth", "sWidthOrig");
            if (oOptions.iDataSort !== undefined2) {
              oCol.aDataSort = [oOptions.iDataSort];
            }
            _fnMap(oCol, oOptions, "aDataSort");
          }
          var mDataSrc = oCol.mData;
          var mData = _fnGetObjectDataFn(mDataSrc);
          var mRender = oCol.mRender ? _fnGetObjectDataFn(oCol.mRender) : null;
          var attrTest = function(src) {
            return typeof src === "string" && src.indexOf("@") !== -1;
          };
          oCol._bAttrSrc = $2.isPlainObject(mDataSrc) && (attrTest(mDataSrc.sort) || attrTest(mDataSrc.type) || attrTest(mDataSrc.filter));
          oCol._setter = null;
          oCol.fnGetData = function(rowData, type, meta) {
            var innerData = mData(rowData, type, undefined2, meta);
            return mRender && type ? mRender(innerData, type, rowData, meta) : innerData;
          };
          oCol.fnSetData = function(rowData, val, meta) {
            return _fnSetObjectDataFn(mDataSrc)(rowData, val, meta);
          };
          if (typeof mDataSrc !== "number") {
            oSettings._rowReadObject = true;
          }
          if (!oSettings.oFeatures.bSort) {
            oCol.bSortable = false;
            th.addClass(oClasses.sSortableNone);
          }
          var bAsc = $2.inArray("asc", oCol.asSorting) !== -1;
          var bDesc = $2.inArray("desc", oCol.asSorting) !== -1;
          if (!oCol.bSortable || !bAsc && !bDesc) {
            oCol.sSortingClass = oClasses.sSortableNone;
            oCol.sSortingClassJUI = "";
          } else if (bAsc && !bDesc) {
            oCol.sSortingClass = oClasses.sSortableAsc;
            oCol.sSortingClassJUI = oClasses.sSortJUIAscAllowed;
          } else if (!bAsc && bDesc) {
            oCol.sSortingClass = oClasses.sSortableDesc;
            oCol.sSortingClassJUI = oClasses.sSortJUIDescAllowed;
          } else {
            oCol.sSortingClass = oClasses.sSortable;
            oCol.sSortingClassJUI = oClasses.sSortJUI;
          }
        }
        function _fnAdjustColumnSizing(settings) {
          if (settings.oFeatures.bAutoWidth !== false) {
            var columns = settings.aoColumns;
            _fnCalculateColumnWidths(settings);
            for (var i = 0, iLen = columns.length; i < iLen; i++) {
              columns[i].nTh.style.width = columns[i].sWidth;
            }
          }
          var scroll = settings.oScroll;
          if (scroll.sY !== "" || scroll.sX !== "") {
            _fnScrollDraw(settings);
          }
          _fnCallbackFire(settings, null, "column-sizing", [settings]);
        }
        function _fnVisibleToColumnIndex(oSettings, iMatch) {
          var aiVis = _fnGetColumns(oSettings, "bVisible");
          return typeof aiVis[iMatch] === "number" ? aiVis[iMatch] : null;
        }
        function _fnColumnIndexToVisible(oSettings, iMatch) {
          var aiVis = _fnGetColumns(oSettings, "bVisible");
          var iPos = $2.inArray(iMatch, aiVis);
          return iPos !== -1 ? iPos : null;
        }
        function _fnVisbleColumns(oSettings) {
          var vis = 0;
          $2.each(oSettings.aoColumns, function(i, col) {
            if (col.bVisible && $2(col.nTh).css("display") !== "none") {
              vis++;
            }
          });
          return vis;
        }
        function _fnGetColumns(oSettings, sParam) {
          var a = [];
          $2.map(oSettings.aoColumns, function(val, i) {
            if (val[sParam]) {
              a.push(i);
            }
          });
          return a;
        }
        function _fnColumnTypes(settings) {
          var columns = settings.aoColumns;
          var data = settings.aoData;
          var types = DataTable.ext.type.detect;
          var i, ien, j, jen, k, ken;
          var col, cell, detectedType, cache;
          for (i = 0, ien = columns.length; i < ien; i++) {
            col = columns[i];
            cache = [];
            if (!col.sType && col._sManualType) {
              col.sType = col._sManualType;
            } else if (!col.sType) {
              for (j = 0, jen = types.length; j < jen; j++) {
                for (k = 0, ken = data.length; k < ken; k++) {
                  if (cache[k] === undefined2) {
                    cache[k] = _fnGetCellData(settings, k, i, "type");
                  }
                  detectedType = types[j](cache[k], settings);
                  if (!detectedType && j !== types.length - 1) {
                    break;
                  }
                  if (detectedType === "html" && !_empty(cache[k])) {
                    break;
                  }
                }
                if (detectedType) {
                  col.sType = detectedType;
                  break;
                }
              }
              if (!col.sType) {
                col.sType = "string";
              }
            }
          }
        }
        function _fnApplyColumnDefs(oSettings, aoColDefs, aoCols, fn) {
          var i, iLen, j, jLen, k, kLen, def;
          var columns = oSettings.aoColumns;
          if (aoColDefs) {
            for (i = aoColDefs.length - 1; i >= 0; i--) {
              def = aoColDefs[i];
              var aTargets = def.targets !== undefined2 ? def.targets : def.aTargets;
              if (!Array.isArray(aTargets)) {
                aTargets = [aTargets];
              }
              for (j = 0, jLen = aTargets.length; j < jLen; j++) {
                if (typeof aTargets[j] === "number" && aTargets[j] >= 0) {
                  while (columns.length <= aTargets[j]) {
                    _fnAddColumn(oSettings);
                  }
                  fn(aTargets[j], def);
                } else if (typeof aTargets[j] === "number" && aTargets[j] < 0) {
                  fn(columns.length + aTargets[j], def);
                } else if (typeof aTargets[j] === "string") {
                  for (k = 0, kLen = columns.length; k < kLen; k++) {
                    if (aTargets[j] == "_all" || $2(columns[k].nTh).hasClass(aTargets[j])) {
                      fn(k, def);
                    }
                  }
                }
              }
            }
          }
          if (aoCols) {
            for (i = 0, iLen = aoCols.length; i < iLen; i++) {
              fn(i, aoCols[i]);
            }
          }
        }
        function _fnAddData(oSettings, aDataIn, nTr, anTds) {
          var iRow = oSettings.aoData.length;
          var oData = $2.extend(true, {}, DataTable.models.oRow, {
            src: nTr ? "dom" : "data",
            idx: iRow
          });
          oData._aData = aDataIn;
          oSettings.aoData.push(oData);
          var nTd, sThisType;
          var columns = oSettings.aoColumns;
          for (var i = 0, iLen = columns.length; i < iLen; i++) {
            columns[i].sType = null;
          }
          oSettings.aiDisplayMaster.push(iRow);
          var id = oSettings.rowIdFn(aDataIn);
          if (id !== undefined2) {
            oSettings.aIds[id] = oData;
          }
          if (nTr || !oSettings.oFeatures.bDeferRender) {
            _fnCreateTr(oSettings, iRow, nTr, anTds);
          }
          return iRow;
        }
        function _fnAddTr(settings, trs) {
          var row;
          if (!(trs instanceof $2)) {
            trs = $2(trs);
          }
          return trs.map(function(i, el) {
            row = _fnGetRowElements(settings, el);
            return _fnAddData(settings, row.data, el, row.cells);
          });
        }
        function _fnNodeToDataIndex(oSettings, n) {
          return n._DT_RowIndex !== undefined2 ? n._DT_RowIndex : null;
        }
        function _fnNodeToColumnIndex(oSettings, iRow, n) {
          return $2.inArray(n, oSettings.aoData[iRow].anCells);
        }
        function _fnGetCellData(settings, rowIdx, colIdx, type) {
          if (type === "search") {
            type = "filter";
          } else if (type === "order") {
            type = "sort";
          }
          var draw = settings.iDraw;
          var col = settings.aoColumns[colIdx];
          var rowData = settings.aoData[rowIdx]._aData;
          var defaultContent = col.sDefaultContent;
          var cellData = col.fnGetData(rowData, type, {
            settings,
            row: rowIdx,
            col: colIdx
          });
          if (cellData === undefined2) {
            if (settings.iDrawError != draw && defaultContent === null) {
              _fnLog(settings, 0, "Requested unknown parameter " + (typeof col.mData == "function" ? "{function}" : "'" + col.mData + "'") + " for row " + rowIdx + ", column " + colIdx, 4);
              settings.iDrawError = draw;
            }
            return defaultContent;
          }
          if ((cellData === rowData || cellData === null) && defaultContent !== null && type !== undefined2) {
            cellData = defaultContent;
          } else if (typeof cellData === "function") {
            return cellData.call(rowData);
          }
          if (cellData === null && type === "display") {
            return "";
          }
          if (type === "filter") {
            var fomatters = DataTable.ext.type.search;
            if (fomatters[col.sType]) {
              cellData = fomatters[col.sType](cellData);
            }
          }
          return cellData;
        }
        function _fnSetCellData(settings, rowIdx, colIdx, val) {
          var col = settings.aoColumns[colIdx];
          var rowData = settings.aoData[rowIdx]._aData;
          col.fnSetData(rowData, val, {
            settings,
            row: rowIdx,
            col: colIdx
          });
        }
        var __reArray = /\[.*?\]$/;
        var __reFn = /\(\)$/;
        function _fnSplitObjNotation(str) {
          return $2.map(str.match(/(\\.|[^\.])+/g) || [""], function(s) {
            return s.replace(/\\\./g, ".");
          });
        }
        var _fnGetObjectDataFn = DataTable.util.get;
        var _fnSetObjectDataFn = DataTable.util.set;
        function _fnGetDataMaster(settings) {
          return _pluck(settings.aoData, "_aData");
        }
        function _fnClearTable(settings) {
          settings.aoData.length = 0;
          settings.aiDisplayMaster.length = 0;
          settings.aiDisplay.length = 0;
          settings.aIds = {};
        }
        function _fnDeleteIndex(a, iTarget, splice) {
          var iTargetIndex = -1;
          for (var i = 0, iLen = a.length; i < iLen; i++) {
            if (a[i] == iTarget) {
              iTargetIndex = i;
            } else if (a[i] > iTarget) {
              a[i]--;
            }
          }
          if (iTargetIndex != -1 && splice === undefined2) {
            a.splice(iTargetIndex, 1);
          }
        }
        function _fnInvalidate(settings, rowIdx, src, colIdx) {
          var row = settings.aoData[rowIdx];
          var i, ien;
          var cellWrite = function(cell, col) {
            while (cell.childNodes.length) {
              cell.removeChild(cell.firstChild);
            }
            cell.innerHTML = _fnGetCellData(settings, rowIdx, col, "display");
          };
          if (src === "dom" || (!src || src === "auto") && row.src === "dom") {
            row._aData = _fnGetRowElements(settings, row, colIdx, colIdx === undefined2 ? undefined2 : row._aData).data;
          } else {
            var cells = row.anCells;
            if (cells) {
              if (colIdx !== undefined2) {
                cellWrite(cells[colIdx], colIdx);
              } else {
                for (i = 0, ien = cells.length; i < ien; i++) {
                  cellWrite(cells[i], i);
                }
              }
            }
          }
          row._aSortData = null;
          row._aFilterData = null;
          var cols = settings.aoColumns;
          if (colIdx !== undefined2) {
            cols[colIdx].sType = null;
          } else {
            for (i = 0, ien = cols.length; i < ien; i++) {
              cols[i].sType = null;
            }
            _fnRowAttributes(settings, row);
          }
        }
        function _fnGetRowElements(settings, row, colIdx, d) {
          var tds = [], td = row.firstChild, name, col, o, i = 0, contents, columns = settings.aoColumns, objectRead = settings._rowReadObject;
          d = d !== undefined2 ? d : objectRead ? {} : [];
          var attr = function(str, td2) {
            if (typeof str === "string") {
              var idx = str.indexOf("@");
              if (idx !== -1) {
                var attr2 = str.substring(idx + 1);
                var setter = _fnSetObjectDataFn(str);
                setter(d, td2.getAttribute(attr2));
              }
            }
          };
          var cellProcess = function(cell) {
            if (colIdx === undefined2 || colIdx === i) {
              col = columns[i];
              contents = cell.innerHTML.trim();
              if (col && col._bAttrSrc) {
                var setter = _fnSetObjectDataFn(col.mData._);
                setter(d, contents);
                attr(col.mData.sort, cell);
                attr(col.mData.type, cell);
                attr(col.mData.filter, cell);
              } else {
                if (objectRead) {
                  if (!col._setter) {
                    col._setter = _fnSetObjectDataFn(col.mData);
                  }
                  col._setter(d, contents);
                } else {
                  d[i] = contents;
                }
              }
            }
            i++;
          };
          if (td) {
            while (td) {
              name = td.nodeName.toUpperCase();
              if (name == "TD" || name == "TH") {
                cellProcess(td);
                tds.push(td);
              }
              td = td.nextSibling;
            }
          } else {
            tds = row.anCells;
            for (var j = 0, jen = tds.length; j < jen; j++) {
              cellProcess(tds[j]);
            }
          }
          var rowNode = row.firstChild ? row : row.nTr;
          if (rowNode) {
            var id = rowNode.getAttribute("id");
            if (id) {
              _fnSetObjectDataFn(settings.rowId)(d, id);
            }
          }
          return {
            data: d,
            cells: tds
          };
        }
        function _fnCreateTr(oSettings, iRow, nTrIn, anTds) {
          var row = oSettings.aoData[iRow], rowData = row._aData, cells = [], nTr, nTd, oCol, i, iLen, create;
          if (row.nTr === null) {
            nTr = nTrIn || document2.createElement("tr");
            row.nTr = nTr;
            row.anCells = cells;
            nTr._DT_RowIndex = iRow;
            _fnRowAttributes(oSettings, row);
            for (i = 0, iLen = oSettings.aoColumns.length; i < iLen; i++) {
              oCol = oSettings.aoColumns[i];
              create = nTrIn ? false : true;
              nTd = create ? document2.createElement(oCol.sCellType) : anTds[i];
              nTd._DT_CellIndex = {
                row: iRow,
                column: i
              };
              cells.push(nTd);
              if (create || (oCol.mRender || oCol.mData !== i) && (!$2.isPlainObject(oCol.mData) || oCol.mData._ !== i + ".display")) {
                nTd.innerHTML = _fnGetCellData(oSettings, iRow, i, "display");
              }
              if (oCol.sClass) {
                nTd.className += " " + oCol.sClass;
              }
              if (oCol.bVisible && !nTrIn) {
                nTr.appendChild(nTd);
              } else if (!oCol.bVisible && nTrIn) {
                nTd.parentNode.removeChild(nTd);
              }
              if (oCol.fnCreatedCell) {
                oCol.fnCreatedCell.call(oSettings.oInstance, nTd, _fnGetCellData(oSettings, iRow, i), rowData, iRow, i);
              }
            }
            _fnCallbackFire(oSettings, "aoRowCreatedCallback", null, [nTr, rowData, iRow, cells]);
          }
        }
        function _fnRowAttributes(settings, row) {
          var tr = row.nTr;
          var data = row._aData;
          if (tr) {
            var id = settings.rowIdFn(data);
            if (id) {
              tr.id = id;
            }
            if (data.DT_RowClass) {
              var a = data.DT_RowClass.split(" ");
              row.__rowc = row.__rowc ? _unique(row.__rowc.concat(a)) : a;
              $2(tr).removeClass(row.__rowc.join(" ")).addClass(data.DT_RowClass);
            }
            if (data.DT_RowAttr) {
              $2(tr).attr(data.DT_RowAttr);
            }
            if (data.DT_RowData) {
              $2(tr).data(data.DT_RowData);
            }
          }
        }
        function _fnBuildHead(oSettings) {
          var i, ien, cell, row, column;
          var thead = oSettings.nTHead;
          var tfoot = oSettings.nTFoot;
          var createHeader = $2("th, td", thead).length === 0;
          var classes = oSettings.oClasses;
          var columns = oSettings.aoColumns;
          if (createHeader) {
            row = $2("<tr/>").appendTo(thead);
          }
          for (i = 0, ien = columns.length; i < ien; i++) {
            column = columns[i];
            cell = $2(column.nTh).addClass(column.sClass);
            if (createHeader) {
              cell.appendTo(row);
            }
            if (oSettings.oFeatures.bSort) {
              cell.addClass(column.sSortingClass);
              if (column.bSortable !== false) {
                cell.attr("tabindex", oSettings.iTabIndex).attr("aria-controls", oSettings.sTableId);
                _fnSortAttachListener(oSettings, column.nTh, i);
              }
            }
            if (column.sTitle != cell[0].innerHTML) {
              cell.html(column.sTitle);
            }
            _fnRenderer(oSettings, "header")(oSettings, cell, column, classes);
          }
          if (createHeader) {
            _fnDetectHeader(oSettings.aoHeader, thead);
          }
          $2(thead).children("tr").children("th, td").addClass(classes.sHeaderTH);
          $2(tfoot).children("tr").children("th, td").addClass(classes.sFooterTH);
          if (tfoot !== null) {
            var cells = oSettings.aoFooter[0];
            for (i = 0, ien = cells.length; i < ien; i++) {
              column = columns[i];
              column.nTf = cells[i].cell;
              if (column.sClass) {
                $2(column.nTf).addClass(column.sClass);
              }
            }
          }
        }
        function _fnDrawHead(oSettings, aoSource, bIncludeHidden) {
          var i, iLen, j, jLen, k, kLen, n, nLocalTr;
          var aoLocal = [];
          var aApplied = [];
          var iColumns = oSettings.aoColumns.length;
          var iRowspan, iColspan;
          if (!aoSource) {
            return;
          }
          if (bIncludeHidden === undefined2) {
            bIncludeHidden = false;
          }
          for (i = 0, iLen = aoSource.length; i < iLen; i++) {
            aoLocal[i] = aoSource[i].slice();
            aoLocal[i].nTr = aoSource[i].nTr;
            for (j = iColumns - 1; j >= 0; j--) {
              if (!oSettings.aoColumns[j].bVisible && !bIncludeHidden) {
                aoLocal[i].splice(j, 1);
              }
            }
            aApplied.push([]);
          }
          for (i = 0, iLen = aoLocal.length; i < iLen; i++) {
            nLocalTr = aoLocal[i].nTr;
            if (nLocalTr) {
              while (n = nLocalTr.firstChild) {
                nLocalTr.removeChild(n);
              }
            }
            for (j = 0, jLen = aoLocal[i].length; j < jLen; j++) {
              iRowspan = 1;
              iColspan = 1;
              if (aApplied[i][j] === undefined2) {
                nLocalTr.appendChild(aoLocal[i][j].cell);
                aApplied[i][j] = 1;
                while (aoLocal[i + iRowspan] !== undefined2 && aoLocal[i][j].cell == aoLocal[i + iRowspan][j].cell) {
                  aApplied[i + iRowspan][j] = 1;
                  iRowspan++;
                }
                while (aoLocal[i][j + iColspan] !== undefined2 && aoLocal[i][j].cell == aoLocal[i][j + iColspan].cell) {
                  for (k = 0; k < iRowspan; k++) {
                    aApplied[i + k][j + iColspan] = 1;
                  }
                  iColspan++;
                }
                $2(aoLocal[i][j].cell).attr("rowspan", iRowspan).attr("colspan", iColspan);
              }
            }
          }
        }
        function _fnDraw(oSettings, ajaxComplete) {
          _fnStart(oSettings);
          var aPreDraw = _fnCallbackFire(oSettings, "aoPreDrawCallback", "preDraw", [oSettings]);
          if ($2.inArray(false, aPreDraw) !== -1) {
            _fnProcessingDisplay(oSettings, false);
            return;
          }
          var anRows = [];
          var iRowCount = 0;
          var asStripeClasses = oSettings.asStripeClasses;
          var iStripes = asStripeClasses.length;
          var oLang = oSettings.oLanguage;
          var bServerSide = _fnDataSource(oSettings) == "ssp";
          var aiDisplay = oSettings.aiDisplay;
          var iDisplayStart = oSettings._iDisplayStart;
          var iDisplayEnd = oSettings.fnDisplayEnd();
          oSettings.bDrawing = true;
          if (oSettings.bDeferLoading) {
            oSettings.bDeferLoading = false;
            oSettings.iDraw++;
            _fnProcessingDisplay(oSettings, false);
          } else if (!bServerSide) {
            oSettings.iDraw++;
          } else if (!oSettings.bDestroying && !ajaxComplete) {
            _fnAjaxUpdate(oSettings);
            return;
          }
          if (aiDisplay.length !== 0) {
            var iStart = bServerSide ? 0 : iDisplayStart;
            var iEnd = bServerSide ? oSettings.aoData.length : iDisplayEnd;
            for (var j = iStart; j < iEnd; j++) {
              var iDataIndex = aiDisplay[j];
              var aoData = oSettings.aoData[iDataIndex];
              if (aoData.nTr === null) {
                _fnCreateTr(oSettings, iDataIndex);
              }
              var nRow = aoData.nTr;
              if (iStripes !== 0) {
                var sStripe = asStripeClasses[iRowCount % iStripes];
                if (aoData._sRowStripe != sStripe) {
                  $2(nRow).removeClass(aoData._sRowStripe).addClass(sStripe);
                  aoData._sRowStripe = sStripe;
                }
              }
              _fnCallbackFire(oSettings, "aoRowCallback", null, [nRow, aoData._aData, iRowCount, j, iDataIndex]);
              anRows.push(nRow);
              iRowCount++;
            }
          } else {
            var sZero = oLang.sZeroRecords;
            if (oSettings.iDraw == 1 && _fnDataSource(oSettings) == "ajax") {
              sZero = oLang.sLoadingRecords;
            } else if (oLang.sEmptyTable && oSettings.fnRecordsTotal() === 0) {
              sZero = oLang.sEmptyTable;
            }
            anRows[0] = $2("<tr/>", { "class": iStripes ? asStripeClasses[0] : "" }).append($2("<td />", {
              "valign": "top",
              "colSpan": _fnVisbleColumns(oSettings),
              "class": oSettings.oClasses.sRowEmpty
            }).html(sZero))[0];
          }
          _fnCallbackFire(oSettings, "aoHeaderCallback", "header", [
            $2(oSettings.nTHead).children("tr")[0],
            _fnGetDataMaster(oSettings),
            iDisplayStart,
            iDisplayEnd,
            aiDisplay
          ]);
          _fnCallbackFire(oSettings, "aoFooterCallback", "footer", [
            $2(oSettings.nTFoot).children("tr")[0],
            _fnGetDataMaster(oSettings),
            iDisplayStart,
            iDisplayEnd,
            aiDisplay
          ]);
          var body = $2(oSettings.nTBody);
          body.children().detach();
          body.append($2(anRows));
          _fnCallbackFire(oSettings, "aoDrawCallback", "draw", [oSettings]);
          oSettings.bSorted = false;
          oSettings.bFiltered = false;
          oSettings.bDrawing = false;
        }
        function _fnReDraw(settings, holdPosition) {
          var features = settings.oFeatures, sort = features.bSort, filter = features.bFilter;
          if (sort) {
            _fnSort(settings);
          }
          if (filter) {
            _fnFilterComplete(settings, settings.oPreviousSearch);
          } else {
            settings.aiDisplay = settings.aiDisplayMaster.slice();
          }
          if (holdPosition !== true) {
            settings._iDisplayStart = 0;
          }
          settings._drawHold = holdPosition;
          _fnDraw(settings);
          settings._drawHold = false;
        }
        function _fnAddOptionsHtml(oSettings) {
          var classes = oSettings.oClasses;
          var table = $2(oSettings.nTable);
          var holding = $2("<div/>").insertBefore(table);
          var features = oSettings.oFeatures;
          var insert = $2("<div/>", {
            id: oSettings.sTableId + "_wrapper",
            "class": classes.sWrapper + (oSettings.nTFoot ? "" : " " + classes.sNoFooter)
          });
          oSettings.nHolding = holding[0];
          oSettings.nTableWrapper = insert[0];
          oSettings.nTableReinsertBefore = oSettings.nTable.nextSibling;
          var aDom = oSettings.sDom.split("");
          var featureNode, cOption, nNewNode, cNext, sAttr, j;
          for (var i = 0; i < aDom.length; i++) {
            featureNode = null;
            cOption = aDom[i];
            if (cOption == "<") {
              nNewNode = $2("<div/>")[0];
              cNext = aDom[i + 1];
              if (cNext == "'" || cNext == '"') {
                sAttr = "";
                j = 2;
                while (aDom[i + j] != cNext) {
                  sAttr += aDom[i + j];
                  j++;
                }
                if (sAttr == "H") {
                  sAttr = classes.sJUIHeader;
                } else if (sAttr == "F") {
                  sAttr = classes.sJUIFooter;
                }
                if (sAttr.indexOf(".") != -1) {
                  var aSplit = sAttr.split(".");
                  nNewNode.id = aSplit[0].substr(1, aSplit[0].length - 1);
                  nNewNode.className = aSplit[1];
                } else if (sAttr.charAt(0) == "#") {
                  nNewNode.id = sAttr.substr(1, sAttr.length - 1);
                } else {
                  nNewNode.className = sAttr;
                }
                i += j;
              }
              insert.append(nNewNode);
              insert = $2(nNewNode);
            } else if (cOption == ">") {
              insert = insert.parent();
            } else if (cOption == "l" && features.bPaginate && features.bLengthChange) {
              featureNode = _fnFeatureHtmlLength(oSettings);
            } else if (cOption == "f" && features.bFilter) {
              featureNode = _fnFeatureHtmlFilter(oSettings);
            } else if (cOption == "r" && features.bProcessing) {
              featureNode = _fnFeatureHtmlProcessing(oSettings);
            } else if (cOption == "t") {
              featureNode = _fnFeatureHtmlTable(oSettings);
            } else if (cOption == "i" && features.bInfo) {
              featureNode = _fnFeatureHtmlInfo(oSettings);
            } else if (cOption == "p" && features.bPaginate) {
              featureNode = _fnFeatureHtmlPaginate(oSettings);
            } else if (DataTable.ext.feature.length !== 0) {
              var aoFeatures = DataTable.ext.feature;
              for (var k = 0, kLen = aoFeatures.length; k < kLen; k++) {
                if (cOption == aoFeatures[k].cFeature) {
                  featureNode = aoFeatures[k].fnInit(oSettings);
                  break;
                }
              }
            }
            if (featureNode) {
              var aanFeatures = oSettings.aanFeatures;
              if (!aanFeatures[cOption]) {
                aanFeatures[cOption] = [];
              }
              aanFeatures[cOption].push(featureNode);
              insert.append(featureNode);
            }
          }
          holding.replaceWith(insert);
          oSettings.nHolding = null;
        }
        function _fnDetectHeader(aLayout, nThead) {
          var nTrs = $2(nThead).children("tr");
          var nTr, nCell;
          var i, k, l, iLen, jLen, iColShifted, iColumn, iColspan, iRowspan;
          var bUnique;
          var fnShiftCol = function(a, i2, j) {
            var k2 = a[i2];
            while (k2[j]) {
              j++;
            }
            return j;
          };
          aLayout.splice(0, aLayout.length);
          for (i = 0, iLen = nTrs.length; i < iLen; i++) {
            aLayout.push([]);
          }
          for (i = 0, iLen = nTrs.length; i < iLen; i++) {
            nTr = nTrs[i];
            iColumn = 0;
            nCell = nTr.firstChild;
            while (nCell) {
              if (nCell.nodeName.toUpperCase() == "TD" || nCell.nodeName.toUpperCase() == "TH") {
                iColspan = nCell.getAttribute("colspan") * 1;
                iRowspan = nCell.getAttribute("rowspan") * 1;
                iColspan = !iColspan || iColspan === 0 || iColspan === 1 ? 1 : iColspan;
                iRowspan = !iRowspan || iRowspan === 0 || iRowspan === 1 ? 1 : iRowspan;
                iColShifted = fnShiftCol(aLayout, i, iColumn);
                bUnique = iColspan === 1 ? true : false;
                for (l = 0; l < iColspan; l++) {
                  for (k = 0; k < iRowspan; k++) {
                    aLayout[i + k][iColShifted + l] = {
                      "cell": nCell,
                      "unique": bUnique
                    };
                    aLayout[i + k].nTr = nTr;
                  }
                }
              }
              nCell = nCell.nextSibling;
            }
          }
        }
        function _fnGetUniqueThs(oSettings, nHeader, aLayout) {
          var aReturn = [];
          if (!aLayout) {
            aLayout = oSettings.aoHeader;
            if (nHeader) {
              aLayout = [];
              _fnDetectHeader(aLayout, nHeader);
            }
          }
          for (var i = 0, iLen = aLayout.length; i < iLen; i++) {
            for (var j = 0, jLen = aLayout[i].length; j < jLen; j++) {
              if (aLayout[i][j].unique && (!aReturn[j] || !oSettings.bSortCellsTop)) {
                aReturn[j] = aLayout[i][j].cell;
              }
            }
          }
          return aReturn;
        }
        function _fnStart(oSettings) {
          var bServerSide = _fnDataSource(oSettings) == "ssp";
          var iInitDisplayStart = oSettings.iInitDisplayStart;
          if (iInitDisplayStart !== undefined2 && iInitDisplayStart !== -1) {
            oSettings._iDisplayStart = bServerSide ? iInitDisplayStart : iInitDisplayStart >= oSettings.fnRecordsDisplay() ? 0 : iInitDisplayStart;
            oSettings.iInitDisplayStart = -1;
          }
        }
        function _fnBuildAjax(oSettings, data, fn) {
          _fnCallbackFire(oSettings, "aoServerParams", "serverParams", [data]);
          if (data && Array.isArray(data)) {
            var tmp = {};
            var rbracket = /(.*?)\[\]$/;
            $2.each(data, function(key, val) {
              var match = val.name.match(rbracket);
              if (match) {
                var name = match[0];
                if (!tmp[name]) {
                  tmp[name] = [];
                }
                tmp[name].push(val.value);
              } else {
                tmp[val.name] = val.value;
              }
            });
            data = tmp;
          }
          var ajaxData;
          var ajax = oSettings.ajax;
          var instance = oSettings.oInstance;
          var callback = function(json) {
            var status = oSettings.jqXHR ? oSettings.jqXHR.status : null;
            if (json === null || typeof status === "number" && status == 204) {
              json = {};
              _fnAjaxDataSrc(oSettings, json, []);
            }
            var error = json.error || json.sError;
            if (error) {
              _fnLog(oSettings, 0, error);
            }
            oSettings.json = json;
            _fnCallbackFire(oSettings, null, "xhr", [oSettings, json, oSettings.jqXHR]);
            fn(json);
          };
          if ($2.isPlainObject(ajax) && ajax.data) {
            ajaxData = ajax.data;
            var newData = typeof ajaxData === "function" ? ajaxData(data, oSettings) : ajaxData;
            data = typeof ajaxData === "function" && newData ? newData : $2.extend(true, data, newData);
            delete ajax.data;
          }
          var baseAjax = {
            "data": data,
            "success": callback,
            "dataType": "json",
            "cache": false,
            "type": oSettings.sServerMethod,
            "error": function(xhr, error, thrown) {
              var ret = _fnCallbackFire(oSettings, null, "xhr", [oSettings, null, oSettings.jqXHR]);
              if ($2.inArray(true, ret) === -1) {
                if (error == "parsererror") {
                  _fnLog(oSettings, 0, "Invalid JSON response", 1);
                } else if (xhr.readyState === 4) {
                  _fnLog(oSettings, 0, "Ajax error", 7);
                }
              }
              _fnProcessingDisplay(oSettings, false);
            }
          };
          oSettings.oAjaxData = data;
          _fnCallbackFire(oSettings, null, "preXhr", [oSettings, data]);
          if (oSettings.fnServerData) {
            oSettings.fnServerData.call(instance, oSettings.sAjaxSource, $2.map(data, function(val, key) {
              return { name: key, value: val };
            }), callback, oSettings);
          } else if (oSettings.sAjaxSource || typeof ajax === "string") {
            oSettings.jqXHR = $2.ajax($2.extend(baseAjax, {
              url: ajax || oSettings.sAjaxSource
            }));
          } else if (typeof ajax === "function") {
            oSettings.jqXHR = ajax.call(instance, data, callback, oSettings);
          } else {
            oSettings.jqXHR = $2.ajax($2.extend(baseAjax, ajax));
            ajax.data = ajaxData;
          }
        }
        function _fnAjaxUpdate(settings) {
          settings.iDraw++;
          _fnProcessingDisplay(settings, true);
          _fnBuildAjax(settings, _fnAjaxParameters(settings), function(json) {
            _fnAjaxUpdateDraw(settings, json);
          });
        }
        function _fnAjaxParameters(settings) {
          var columns = settings.aoColumns, columnCount = columns.length, features = settings.oFeatures, preSearch = settings.oPreviousSearch, preColSearch = settings.aoPreSearchCols, i, data = [], dataProp, column, columnSearch, sort = _fnSortFlatten(settings), displayStart = settings._iDisplayStart, displayLength = features.bPaginate !== false ? settings._iDisplayLength : -1;
          var param = function(name, value) {
            data.push({ "name": name, "value": value });
          };
          param("sEcho", settings.iDraw);
          param("iColumns", columnCount);
          param("sColumns", _pluck(columns, "sName").join(","));
          param("iDisplayStart", displayStart);
          param("iDisplayLength", displayLength);
          var d = {
            draw: settings.iDraw,
            columns: [],
            order: [],
            start: displayStart,
            length: displayLength,
            search: {
              value: preSearch.sSearch,
              regex: preSearch.bRegex
            }
          };
          for (i = 0; i < columnCount; i++) {
            column = columns[i];
            columnSearch = preColSearch[i];
            dataProp = typeof column.mData == "function" ? "function" : column.mData;
            d.columns.push({
              data: dataProp,
              name: column.sName,
              searchable: column.bSearchable,
              orderable: column.bSortable,
              search: {
                value: columnSearch.sSearch,
                regex: columnSearch.bRegex
              }
            });
            param("mDataProp_" + i, dataProp);
            if (features.bFilter) {
              param("sSearch_" + i, columnSearch.sSearch);
              param("bRegex_" + i, columnSearch.bRegex);
              param("bSearchable_" + i, column.bSearchable);
            }
            if (features.bSort) {
              param("bSortable_" + i, column.bSortable);
            }
          }
          if (features.bFilter) {
            param("sSearch", preSearch.sSearch);
            param("bRegex", preSearch.bRegex);
          }
          if (features.bSort) {
            $2.each(sort, function(i2, val) {
              d.order.push({ column: val.col, dir: val.dir });
              param("iSortCol_" + i2, val.col);
              param("sSortDir_" + i2, val.dir);
            });
            param("iSortingCols", sort.length);
          }
          var legacy = DataTable.ext.legacy.ajax;
          if (legacy === null) {
            return settings.sAjaxSource ? data : d;
          }
          return legacy ? data : d;
        }
        function _fnAjaxUpdateDraw(settings, json) {
          var compat = function(old, modern) {
            return json[old] !== undefined2 ? json[old] : json[modern];
          };
          var data = _fnAjaxDataSrc(settings, json);
          var draw = compat("sEcho", "draw");
          var recordsTotal = compat("iTotalRecords", "recordsTotal");
          var recordsFiltered = compat("iTotalDisplayRecords", "recordsFiltered");
          if (draw !== undefined2) {
            if (draw * 1 < settings.iDraw) {
              return;
            }
            settings.iDraw = draw * 1;
          }
          if (!data) {
            data = [];
          }
          _fnClearTable(settings);
          settings._iRecordsTotal = parseInt(recordsTotal, 10);
          settings._iRecordsDisplay = parseInt(recordsFiltered, 10);
          for (var i = 0, ien = data.length; i < ien; i++) {
            _fnAddData(settings, data[i]);
          }
          settings.aiDisplay = settings.aiDisplayMaster.slice();
          _fnDraw(settings, true);
          if (!settings._bInitComplete) {
            _fnInitComplete(settings, json);
          }
          _fnProcessingDisplay(settings, false);
        }
        function _fnAjaxDataSrc(oSettings, json, write) {
          var dataSrc = $2.isPlainObject(oSettings.ajax) && oSettings.ajax.dataSrc !== undefined2 ? oSettings.ajax.dataSrc : oSettings.sAjaxDataProp;
          if (!write) {
            if (dataSrc === "data") {
              return json.aaData || json[dataSrc];
            }
            return dataSrc !== "" ? _fnGetObjectDataFn(dataSrc)(json) : json;
          }
          _fnSetObjectDataFn(dataSrc)(json, write);
        }
        function _fnFeatureHtmlFilter(settings) {
          var classes = settings.oClasses;
          var tableId = settings.sTableId;
          var language = settings.oLanguage;
          var previousSearch = settings.oPreviousSearch;
          var features = settings.aanFeatures;
          var input = '<input type="search" class="' + classes.sFilterInput + '"/>';
          var str = language.sSearch;
          str = str.match(/_INPUT_/) ? str.replace("_INPUT_", input) : str + input;
          var filter = $2("<div/>", {
            "id": !features.f ? tableId + "_filter" : null,
            "class": classes.sFilter
          }).append($2("<label/>").append(str));
          var searchFn = function(event) {
            var n = features.f;
            var val = !this.value ? "" : this.value;
            if (previousSearch.return && event.key !== "Enter") {
              return;
            }
            if (val != previousSearch.sSearch) {
              _fnFilterComplete(settings, {
                "sSearch": val,
                "bRegex": previousSearch.bRegex,
                "bSmart": previousSearch.bSmart,
                "bCaseInsensitive": previousSearch.bCaseInsensitive,
                "return": previousSearch.return
              });
              settings._iDisplayStart = 0;
              _fnDraw(settings);
            }
          };
          var searchDelay = settings.searchDelay !== null ? settings.searchDelay : _fnDataSource(settings) === "ssp" ? 400 : 0;
          var jqFilter = $2("input", filter).val(previousSearch.sSearch).attr("placeholder", language.sSearchPlaceholder).on("keyup.DT search.DT input.DT paste.DT cut.DT", searchDelay ? _fnThrottle(searchFn, searchDelay) : searchFn).on("mouseup", function(e) {
            setTimeout(function() {
              searchFn.call(jqFilter[0], e);
            }, 10);
          }).on("keypress.DT", function(e) {
            if (e.keyCode == 13) {
              return false;
            }
          }).attr("aria-controls", tableId);
          $2(settings.nTable).on("search.dt.DT", function(ev, s) {
            if (settings === s) {
              try {
                if (jqFilter[0] !== document2.activeElement) {
                  jqFilter.val(previousSearch.sSearch);
                }
              } catch (e) {
              }
            }
          });
          return filter[0];
        }
        function _fnFilterComplete(oSettings, oInput, iForce) {
          var oPrevSearch = oSettings.oPreviousSearch;
          var aoPrevSearch = oSettings.aoPreSearchCols;
          var fnSaveFilter = function(oFilter) {
            oPrevSearch.sSearch = oFilter.sSearch;
            oPrevSearch.bRegex = oFilter.bRegex;
            oPrevSearch.bSmart = oFilter.bSmart;
            oPrevSearch.bCaseInsensitive = oFilter.bCaseInsensitive;
            oPrevSearch.return = oFilter.return;
          };
          var fnRegex = function(o) {
            return o.bEscapeRegex !== undefined2 ? !o.bEscapeRegex : o.bRegex;
          };
          _fnColumnTypes(oSettings);
          if (_fnDataSource(oSettings) != "ssp") {
            _fnFilter(oSettings, oInput.sSearch, iForce, fnRegex(oInput), oInput.bSmart, oInput.bCaseInsensitive, oInput.return);
            fnSaveFilter(oInput);
            for (var i = 0; i < aoPrevSearch.length; i++) {
              _fnFilterColumn(oSettings, aoPrevSearch[i].sSearch, i, fnRegex(aoPrevSearch[i]), aoPrevSearch[i].bSmart, aoPrevSearch[i].bCaseInsensitive);
            }
            _fnFilterCustom(oSettings);
          } else {
            fnSaveFilter(oInput);
          }
          oSettings.bFiltered = true;
          _fnCallbackFire(oSettings, null, "search", [oSettings]);
        }
        function _fnFilterCustom(settings) {
          var filters = DataTable.ext.search;
          var displayRows = settings.aiDisplay;
          var row, rowIdx;
          for (var i = 0, ien = filters.length; i < ien; i++) {
            var rows = [];
            for (var j = 0, jen = displayRows.length; j < jen; j++) {
              rowIdx = displayRows[j];
              row = settings.aoData[rowIdx];
              if (filters[i](settings, row._aFilterData, rowIdx, row._aData, j)) {
                rows.push(rowIdx);
              }
            }
            displayRows.length = 0;
            $2.merge(displayRows, rows);
          }
        }
        function _fnFilterColumn(settings, searchStr, colIdx, regex, smart, caseInsensitive) {
          if (searchStr === "") {
            return;
          }
          var data;
          var out = [];
          var display = settings.aiDisplay;
          var rpSearch = _fnFilterCreateSearch(searchStr, regex, smart, caseInsensitive);
          for (var i = 0; i < display.length; i++) {
            data = settings.aoData[display[i]]._aFilterData[colIdx];
            if (rpSearch.test(data)) {
              out.push(display[i]);
            }
          }
          settings.aiDisplay = out;
        }
        function _fnFilter(settings, input, force, regex, smart, caseInsensitive) {
          var rpSearch = _fnFilterCreateSearch(input, regex, smart, caseInsensitive);
          var prevSearch = settings.oPreviousSearch.sSearch;
          var displayMaster = settings.aiDisplayMaster;
          var display, invalidated, i;
          var filtered = [];
          if (DataTable.ext.search.length !== 0) {
            force = true;
          }
          invalidated = _fnFilterData(settings);
          if (input.length <= 0) {
            settings.aiDisplay = displayMaster.slice();
          } else {
            if (invalidated || force || regex || prevSearch.length > input.length || input.indexOf(prevSearch) !== 0 || settings.bSorted) {
              settings.aiDisplay = displayMaster.slice();
            }
            display = settings.aiDisplay;
            for (i = 0; i < display.length; i++) {
              if (rpSearch.test(settings.aoData[display[i]]._sFilterRow)) {
                filtered.push(display[i]);
              }
            }
            settings.aiDisplay = filtered;
          }
        }
        function _fnFilterCreateSearch(search, regex, smart, caseInsensitive) {
          search = regex ? search : _fnEscapeRegex(search);
          if (smart) {
            var a = $2.map(search.match(/"[^"]+"|[^ ]+/g) || [""], function(word) {
              if (word.charAt(0) === '"') {
                var m = word.match(/^"(.*)"$/);
                word = m ? m[1] : word;
              }
              return word.replace('"', "");
            });
            search = "^(?=.*?" + a.join(")(?=.*?") + ").*$";
          }
          return new RegExp(search, caseInsensitive ? "i" : "");
        }
        var _fnEscapeRegex = DataTable.util.escapeRegex;
        var __filter_div = $2("<div>")[0];
        var __filter_div_textContent = __filter_div.textContent !== undefined2;
        function _fnFilterData(settings) {
          var columns = settings.aoColumns;
          var column;
          var i, j, ien, jen, filterData, cellData, row;
          var wasInvalidated = false;
          for (i = 0, ien = settings.aoData.length; i < ien; i++) {
            row = settings.aoData[i];
            if (!row._aFilterData) {
              filterData = [];
              for (j = 0, jen = columns.length; j < jen; j++) {
                column = columns[j];
                if (column.bSearchable) {
                  cellData = _fnGetCellData(settings, i, j, "filter");
                  if (cellData === null) {
                    cellData = "";
                  }
                  if (typeof cellData !== "string" && cellData.toString) {
                    cellData = cellData.toString();
                  }
                } else {
                  cellData = "";
                }
                if (cellData.indexOf && cellData.indexOf("&") !== -1) {
                  __filter_div.innerHTML = cellData;
                  cellData = __filter_div_textContent ? __filter_div.textContent : __filter_div.innerText;
                }
                if (cellData.replace) {
                  cellData = cellData.replace(/[\r\n\u2028]/g, "");
                }
                filterData.push(cellData);
              }
              row._aFilterData = filterData;
              row._sFilterRow = filterData.join("  ");
              wasInvalidated = true;
            }
          }
          return wasInvalidated;
        }
        function _fnSearchToCamel(obj) {
          return {
            search: obj.sSearch,
            smart: obj.bSmart,
            regex: obj.bRegex,
            caseInsensitive: obj.bCaseInsensitive
          };
        }
        function _fnSearchToHung(obj) {
          return {
            sSearch: obj.search,
            bSmart: obj.smart,
            bRegex: obj.regex,
            bCaseInsensitive: obj.caseInsensitive
          };
        }
        function _fnFeatureHtmlInfo(settings) {
          var tid = settings.sTableId, nodes = settings.aanFeatures.i, n = $2("<div/>", {
            "class": settings.oClasses.sInfo,
            "id": !nodes ? tid + "_info" : null
          });
          if (!nodes) {
            settings.aoDrawCallback.push({
              "fn": _fnUpdateInfo,
              "sName": "information"
            });
            n.attr("role", "status").attr("aria-live", "polite");
            $2(settings.nTable).attr("aria-describedby", tid + "_info");
          }
          return n[0];
        }
        function _fnUpdateInfo(settings) {
          var nodes = settings.aanFeatures.i;
          if (nodes.length === 0) {
            return;
          }
          var lang = settings.oLanguage, start = settings._iDisplayStart + 1, end = settings.fnDisplayEnd(), max = settings.fnRecordsTotal(), total = settings.fnRecordsDisplay(), out = total ? lang.sInfo : lang.sInfoEmpty;
          if (total !== max) {
            out += " " + lang.sInfoFiltered;
          }
          out += lang.sInfoPostFix;
          out = _fnInfoMacros(settings, out);
          var callback = lang.fnInfoCallback;
          if (callback !== null) {
            out = callback.call(settings.oInstance, settings, start, end, max, total, out);
          }
          $2(nodes).html(out);
        }
        function _fnInfoMacros(settings, str) {
          var formatter = settings.fnFormatNumber, start = settings._iDisplayStart + 1, len = settings._iDisplayLength, vis = settings.fnRecordsDisplay(), all = len === -1;
          return str.replace(/_START_/g, formatter.call(settings, start)).replace(/_END_/g, formatter.call(settings, settings.fnDisplayEnd())).replace(/_MAX_/g, formatter.call(settings, settings.fnRecordsTotal())).replace(/_TOTAL_/g, formatter.call(settings, vis)).replace(/_PAGE_/g, formatter.call(settings, all ? 1 : Math.ceil(start / len))).replace(/_PAGES_/g, formatter.call(settings, all ? 1 : Math.ceil(vis / len)));
        }
        function _fnInitialise(settings) {
          var i, iLen, iAjaxStart = settings.iInitDisplayStart;
          var columns = settings.aoColumns, column;
          var features = settings.oFeatures;
          var deferLoading = settings.bDeferLoading;
          if (!settings.bInitialised) {
            setTimeout(function() {
              _fnInitialise(settings);
            }, 200);
            return;
          }
          _fnAddOptionsHtml(settings);
          _fnBuildHead(settings);
          _fnDrawHead(settings, settings.aoHeader);
          _fnDrawHead(settings, settings.aoFooter);
          _fnProcessingDisplay(settings, true);
          if (features.bAutoWidth) {
            _fnCalculateColumnWidths(settings);
          }
          for (i = 0, iLen = columns.length; i < iLen; i++) {
            column = columns[i];
            if (column.sWidth) {
              column.nTh.style.width = _fnStringToCss(column.sWidth);
            }
          }
          _fnCallbackFire(settings, null, "preInit", [settings]);
          _fnReDraw(settings);
          var dataSrc = _fnDataSource(settings);
          if (dataSrc != "ssp" || deferLoading) {
            if (dataSrc == "ajax") {
              _fnBuildAjax(settings, [], function(json) {
                var aData = _fnAjaxDataSrc(settings, json);
                for (i = 0; i < aData.length; i++) {
                  _fnAddData(settings, aData[i]);
                }
                settings.iInitDisplayStart = iAjaxStart;
                _fnReDraw(settings);
                _fnProcessingDisplay(settings, false);
                _fnInitComplete(settings, json);
              }, settings);
            } else {
              _fnProcessingDisplay(settings, false);
              _fnInitComplete(settings);
            }
          }
        }
        function _fnInitComplete(settings, json) {
          settings._bInitComplete = true;
          if (json || settings.oInit.aaData) {
            _fnAdjustColumnSizing(settings);
          }
          _fnCallbackFire(settings, null, "plugin-init", [settings, json]);
          _fnCallbackFire(settings, "aoInitComplete", "init", [settings, json]);
        }
        function _fnLengthChange(settings, val) {
          var len = parseInt(val, 10);
          settings._iDisplayLength = len;
          _fnLengthOverflow(settings);
          _fnCallbackFire(settings, null, "length", [settings, len]);
        }
        function _fnFeatureHtmlLength(settings) {
          var classes = settings.oClasses, tableId = settings.sTableId, menu = settings.aLengthMenu, d2 = Array.isArray(menu[0]), lengths = d2 ? menu[0] : menu, language = d2 ? menu[1] : menu;
          var select = $2("<select/>", {
            "name": tableId + "_length",
            "aria-controls": tableId,
            "class": classes.sLengthSelect
          });
          for (var i = 0, ien = lengths.length; i < ien; i++) {
            select[0][i] = new Option(typeof language[i] === "number" ? settings.fnFormatNumber(language[i]) : language[i], lengths[i]);
          }
          var div = $2("<div><label/></div>").addClass(classes.sLength);
          if (!settings.aanFeatures.l) {
            div[0].id = tableId + "_length";
          }
          div.children().append(settings.oLanguage.sLengthMenu.replace("_MENU_", select[0].outerHTML));
          $2("select", div).val(settings._iDisplayLength).on("change.DT", function(e) {
            _fnLengthChange(settings, $2(this).val());
            _fnDraw(settings);
          });
          $2(settings.nTable).on("length.dt.DT", function(e, s, len) {
            if (settings === s) {
              $2("select", div).val(len);
            }
          });
          return div[0];
        }
        function _fnFeatureHtmlPaginate(settings) {
          var type = settings.sPaginationType, plugin = DataTable.ext.pager[type], modern = typeof plugin === "function", redraw = function(settings2) {
            _fnDraw(settings2);
          }, node = $2("<div/>").addClass(settings.oClasses.sPaging + type)[0], features = settings.aanFeatures;
          if (!modern) {
            plugin.fnInit(settings, node, redraw);
          }
          if (!features.p) {
            node.id = settings.sTableId + "_paginate";
            settings.aoDrawCallback.push({
              "fn": function(settings2) {
                if (modern) {
                  var start = settings2._iDisplayStart, len = settings2._iDisplayLength, visRecords = settings2.fnRecordsDisplay(), all = len === -1, page = all ? 0 : Math.ceil(start / len), pages = all ? 1 : Math.ceil(visRecords / len), buttons = plugin(page, pages), i, ien;
                  for (i = 0, ien = features.p.length; i < ien; i++) {
                    _fnRenderer(settings2, "pageButton")(settings2, features.p[i], i, buttons, page, pages);
                  }
                } else {
                  plugin.fnUpdate(settings2, redraw);
                }
              },
              "sName": "pagination"
            });
          }
          return node;
        }
        function _fnPageChange(settings, action, redraw) {
          var start = settings._iDisplayStart, len = settings._iDisplayLength, records = settings.fnRecordsDisplay();
          if (records === 0 || len === -1) {
            start = 0;
          } else if (typeof action === "number") {
            start = action * len;
            if (start > records) {
              start = 0;
            }
          } else if (action == "first") {
            start = 0;
          } else if (action == "previous") {
            start = len >= 0 ? start - len : 0;
            if (start < 0) {
              start = 0;
            }
          } else if (action == "next") {
            if (start + len < records) {
              start += len;
            }
          } else if (action == "last") {
            start = Math.floor((records - 1) / len) * len;
          } else {
            _fnLog(settings, 0, "Unknown paging action: " + action, 5);
          }
          var changed = settings._iDisplayStart !== start;
          settings._iDisplayStart = start;
          if (changed) {
            _fnCallbackFire(settings, null, "page", [settings]);
            if (redraw) {
              _fnDraw(settings);
            }
          }
          return changed;
        }
        function _fnFeatureHtmlProcessing(settings) {
          return $2("<div/>", {
            "id": !settings.aanFeatures.r ? settings.sTableId + "_processing" : null,
            "class": settings.oClasses.sProcessing
          }).html(settings.oLanguage.sProcessing).insertBefore(settings.nTable)[0];
        }
        function _fnProcessingDisplay(settings, show) {
          if (settings.oFeatures.bProcessing) {
            $2(settings.aanFeatures.r).css("display", show ? "block" : "none");
          }
          _fnCallbackFire(settings, null, "processing", [settings, show]);
        }
        function _fnFeatureHtmlTable(settings) {
          var table = $2(settings.nTable);
          var scroll = settings.oScroll;
          if (scroll.sX === "" && scroll.sY === "") {
            return settings.nTable;
          }
          var scrollX = scroll.sX;
          var scrollY = scroll.sY;
          var classes = settings.oClasses;
          var caption = table.children("caption");
          var captionSide = caption.length ? caption[0]._captionSide : null;
          var headerClone = $2(table[0].cloneNode(false));
          var footerClone = $2(table[0].cloneNode(false));
          var footer = table.children("tfoot");
          var _div = "<div/>";
          var size = function(s) {
            return !s ? null : _fnStringToCss(s);
          };
          if (!footer.length) {
            footer = null;
          }
          var scroller = $2(_div, { "class": classes.sScrollWrapper }).append($2(_div, { "class": classes.sScrollHead }).css({
            overflow: "hidden",
            position: "relative",
            border: 0,
            width: scrollX ? size(scrollX) : "100%"
          }).append($2(_div, { "class": classes.sScrollHeadInner }).css({
            "box-sizing": "content-box",
            width: scroll.sXInner || "100%"
          }).append(headerClone.removeAttr("id").css("margin-left", 0).append(captionSide === "top" ? caption : null).append(table.children("thead"))))).append($2(_div, { "class": classes.sScrollBody }).css({
            position: "relative",
            overflow: "auto",
            width: size(scrollX)
          }).append(table));
          if (footer) {
            scroller.append($2(_div, { "class": classes.sScrollFoot }).css({
              overflow: "hidden",
              border: 0,
              width: scrollX ? size(scrollX) : "100%"
            }).append($2(_div, { "class": classes.sScrollFootInner }).append(footerClone.removeAttr("id").css("margin-left", 0).append(captionSide === "bottom" ? caption : null).append(table.children("tfoot")))));
          }
          var children = scroller.children();
          var scrollHead = children[0];
          var scrollBody = children[1];
          var scrollFoot = footer ? children[2] : null;
          if (scrollX) {
            $2(scrollBody).on("scroll.DT", function(e) {
              var scrollLeft = this.scrollLeft;
              scrollHead.scrollLeft = scrollLeft;
              if (footer) {
                scrollFoot.scrollLeft = scrollLeft;
              }
            });
          }
          $2(scrollBody).css("max-height", scrollY);
          if (!scroll.bCollapse) {
            $2(scrollBody).css("height", scrollY);
          }
          settings.nScrollHead = scrollHead;
          settings.nScrollBody = scrollBody;
          settings.nScrollFoot = scrollFoot;
          settings.aoDrawCallback.push({
            "fn": _fnScrollDraw,
            "sName": "scrolling"
          });
          return scroller[0];
        }
        function _fnScrollDraw(settings) {
          var scroll = settings.oScroll, scrollX = scroll.sX, scrollXInner = scroll.sXInner, scrollY = scroll.sY, barWidth = scroll.iBarWidth, divHeader = $2(settings.nScrollHead), divHeaderStyle = divHeader[0].style, divHeaderInner = divHeader.children("div"), divHeaderInnerStyle = divHeaderInner[0].style, divHeaderTable = divHeaderInner.children("table"), divBodyEl = settings.nScrollBody, divBody = $2(divBodyEl), divBodyStyle = divBodyEl.style, divFooter = $2(settings.nScrollFoot), divFooterInner = divFooter.children("div"), divFooterTable = divFooterInner.children("table"), header = $2(settings.nTHead), table = $2(settings.nTable), tableEl = table[0], tableStyle = tableEl.style, footer = settings.nTFoot ? $2(settings.nTFoot) : null, browser = settings.oBrowser, ie67 = browser.bScrollOversize, dtHeaderCells = _pluck(settings.aoColumns, "nTh"), headerTrgEls, footerTrgEls, headerSrcEls, footerSrcEls, headerCopy, footerCopy, headerWidths = [], footerWidths = [], headerContent = [], footerContent = [], idx, correction, sanityWidth, zeroOut = function(nSizer) {
            var style = nSizer.style;
            style.paddingTop = "0";
            style.paddingBottom = "0";
            style.borderTopWidth = "0";
            style.borderBottomWidth = "0";
            style.height = 0;
          };
          var scrollBarVis = divBodyEl.scrollHeight > divBodyEl.clientHeight;
          if (settings.scrollBarVis !== scrollBarVis && settings.scrollBarVis !== undefined2) {
            settings.scrollBarVis = scrollBarVis;
            _fnAdjustColumnSizing(settings);
            return;
          } else {
            settings.scrollBarVis = scrollBarVis;
          }
          table.children("thead, tfoot").remove();
          if (footer) {
            footerCopy = footer.clone().prependTo(table);
            footerTrgEls = footer.find("tr");
            footerSrcEls = footerCopy.find("tr");
          }
          headerCopy = header.clone().prependTo(table);
          headerTrgEls = header.find("tr");
          headerSrcEls = headerCopy.find("tr");
          headerCopy.find("th, td").removeAttr("tabindex");
          if (!scrollX) {
            divBodyStyle.width = "100%";
            divHeader[0].style.width = "100%";
          }
          $2.each(_fnGetUniqueThs(settings, headerCopy), function(i, el) {
            idx = _fnVisibleToColumnIndex(settings, i);
            el.style.width = settings.aoColumns[idx].sWidth;
          });
          if (footer) {
            _fnApplyToChildren(function(n) {
              n.style.width = "";
            }, footerSrcEls);
          }
          sanityWidth = table.outerWidth();
          if (scrollX === "") {
            tableStyle.width = "100%";
            if (ie67 && (table.find("tbody").height() > divBodyEl.offsetHeight || divBody.css("overflow-y") == "scroll")) {
              tableStyle.width = _fnStringToCss(table.outerWidth() - barWidth);
            }
            sanityWidth = table.outerWidth();
          } else if (scrollXInner !== "") {
            tableStyle.width = _fnStringToCss(scrollXInner);
            sanityWidth = table.outerWidth();
          }
          _fnApplyToChildren(zeroOut, headerSrcEls);
          _fnApplyToChildren(function(nSizer) {
            var style = window2.getComputedStyle ? window2.getComputedStyle(nSizer).width : _fnStringToCss($2(nSizer).width());
            headerContent.push(nSizer.innerHTML);
            headerWidths.push(style);
          }, headerSrcEls);
          _fnApplyToChildren(function(nToSize, i) {
            nToSize.style.width = headerWidths[i];
          }, headerTrgEls);
          $2(headerSrcEls).css("height", 0);
          if (footer) {
            _fnApplyToChildren(zeroOut, footerSrcEls);
            _fnApplyToChildren(function(nSizer) {
              footerContent.push(nSizer.innerHTML);
              footerWidths.push(_fnStringToCss($2(nSizer).css("width")));
            }, footerSrcEls);
            _fnApplyToChildren(function(nToSize, i) {
              nToSize.style.width = footerWidths[i];
            }, footerTrgEls);
            $2(footerSrcEls).height(0);
          }
          _fnApplyToChildren(function(nSizer, i) {
            nSizer.innerHTML = '<div class="dataTables_sizing">' + headerContent[i] + "</div>";
            nSizer.childNodes[0].style.height = "0";
            nSizer.childNodes[0].style.overflow = "hidden";
            nSizer.style.width = headerWidths[i];
          }, headerSrcEls);
          if (footer) {
            _fnApplyToChildren(function(nSizer, i) {
              nSizer.innerHTML = '<div class="dataTables_sizing">' + footerContent[i] + "</div>";
              nSizer.childNodes[0].style.height = "0";
              nSizer.childNodes[0].style.overflow = "hidden";
              nSizer.style.width = footerWidths[i];
            }, footerSrcEls);
          }
          if (Math.round(table.outerWidth()) < Math.round(sanityWidth)) {
            correction = divBodyEl.scrollHeight > divBodyEl.offsetHeight || divBody.css("overflow-y") == "scroll" ? sanityWidth + barWidth : sanityWidth;
            if (ie67 && (divBodyEl.scrollHeight > divBodyEl.offsetHeight || divBody.css("overflow-y") == "scroll")) {
              tableStyle.width = _fnStringToCss(correction - barWidth);
            }
            if (scrollX === "" || scrollXInner !== "") {
              _fnLog(settings, 1, "Possible column misalignment", 6);
            }
          } else {
            correction = "100%";
          }
          divBodyStyle.width = _fnStringToCss(correction);
          divHeaderStyle.width = _fnStringToCss(correction);
          if (footer) {
            settings.nScrollFoot.style.width = _fnStringToCss(correction);
          }
          if (!scrollY) {
            if (ie67) {
              divBodyStyle.height = _fnStringToCss(tableEl.offsetHeight + barWidth);
            }
          }
          var iOuterWidth = table.outerWidth();
          divHeaderTable[0].style.width = _fnStringToCss(iOuterWidth);
          divHeaderInnerStyle.width = _fnStringToCss(iOuterWidth);
          var bScrolling = table.height() > divBodyEl.clientHeight || divBody.css("overflow-y") == "scroll";
          var padding = "padding" + (browser.bScrollbarLeft ? "Left" : "Right");
          divHeaderInnerStyle[padding] = bScrolling ? barWidth + "px" : "0px";
          if (footer) {
            divFooterTable[0].style.width = _fnStringToCss(iOuterWidth);
            divFooterInner[0].style.width = _fnStringToCss(iOuterWidth);
            divFooterInner[0].style[padding] = bScrolling ? barWidth + "px" : "0px";
          }
          table.children("colgroup").insertBefore(table.children("thead"));
          divBody.trigger("scroll");
          if ((settings.bSorted || settings.bFiltered) && !settings._drawHold) {
            divBodyEl.scrollTop = 0;
          }
        }
        function _fnApplyToChildren(fn, an1, an2) {
          var index = 0, i = 0, iLen = an1.length;
          var nNode1, nNode2;
          while (i < iLen) {
            nNode1 = an1[i].firstChild;
            nNode2 = an2 ? an2[i].firstChild : null;
            while (nNode1) {
              if (nNode1.nodeType === 1) {
                if (an2) {
                  fn(nNode1, nNode2, index);
                } else {
                  fn(nNode1, index);
                }
                index++;
              }
              nNode1 = nNode1.nextSibling;
              nNode2 = an2 ? nNode2.nextSibling : null;
            }
            i++;
          }
        }
        var __re_html_remove = /<.*?>/g;
        function _fnCalculateColumnWidths(oSettings) {
          var table = oSettings.nTable, columns = oSettings.aoColumns, scroll = oSettings.oScroll, scrollY = scroll.sY, scrollX = scroll.sX, scrollXInner = scroll.sXInner, columnCount = columns.length, visibleColumns = _fnGetColumns(oSettings, "bVisible"), headerCells = $2("th", oSettings.nTHead), tableWidthAttr = table.getAttribute("width"), tableContainer = table.parentNode, userInputs = false, i, column, columnIdx, width, outerWidth, browser = oSettings.oBrowser, ie67 = browser.bScrollOversize;
          var styleWidth = table.style.width;
          if (styleWidth && styleWidth.indexOf("%") !== -1) {
            tableWidthAttr = styleWidth;
          }
          for (i = 0; i < visibleColumns.length; i++) {
            column = columns[visibleColumns[i]];
            if (column.sWidth !== null) {
              column.sWidth = _fnConvertToWidth(column.sWidthOrig, tableContainer);
              userInputs = true;
            }
          }
          if (ie67 || !userInputs && !scrollX && !scrollY && columnCount == _fnVisbleColumns(oSettings) && columnCount == headerCells.length) {
            for (i = 0; i < columnCount; i++) {
              var colIdx = _fnVisibleToColumnIndex(oSettings, i);
              if (colIdx !== null) {
                columns[colIdx].sWidth = _fnStringToCss(headerCells.eq(i).width());
              }
            }
          } else {
            var tmpTable = $2(table).clone().css("visibility", "hidden").removeAttr("id");
            tmpTable.find("tbody tr").remove();
            var tr = $2("<tr/>").appendTo(tmpTable.find("tbody"));
            tmpTable.find("thead, tfoot").remove();
            tmpTable.append($2(oSettings.nTHead).clone()).append($2(oSettings.nTFoot).clone());
            tmpTable.find("tfoot th, tfoot td").css("width", "");
            headerCells = _fnGetUniqueThs(oSettings, tmpTable.find("thead")[0]);
            for (i = 0; i < visibleColumns.length; i++) {
              column = columns[visibleColumns[i]];
              headerCells[i].style.width = column.sWidthOrig !== null && column.sWidthOrig !== "" ? _fnStringToCss(column.sWidthOrig) : "";
              if (column.sWidthOrig && scrollX) {
                $2(headerCells[i]).append($2("<div/>").css({
                  width: column.sWidthOrig,
                  margin: 0,
                  padding: 0,
                  border: 0,
                  height: 1
                }));
              }
            }
            if (oSettings.aoData.length) {
              for (i = 0; i < visibleColumns.length; i++) {
                columnIdx = visibleColumns[i];
                column = columns[columnIdx];
                $2(_fnGetWidestNode(oSettings, columnIdx)).clone(false).append(column.sContentPadding).appendTo(tr);
              }
            }
            $2("[name]", tmpTable).removeAttr("name");
            var holder = $2("<div/>").css(scrollX || scrollY ? {
              position: "absolute",
              top: 0,
              left: 0,
              height: 1,
              right: 0,
              overflow: "hidden"
            } : {}).append(tmpTable).appendTo(tableContainer);
            if (scrollX && scrollXInner) {
              tmpTable.width(scrollXInner);
            } else if (scrollX) {
              tmpTable.css("width", "auto");
              tmpTable.removeAttr("width");
              if (tmpTable.width() < tableContainer.clientWidth && tableWidthAttr) {
                tmpTable.width(tableContainer.clientWidth);
              }
            } else if (scrollY) {
              tmpTable.width(tableContainer.clientWidth);
            } else if (tableWidthAttr) {
              tmpTable.width(tableWidthAttr);
            }
            var total = 0;
            for (i = 0; i < visibleColumns.length; i++) {
              var cell = $2(headerCells[i]);
              var border = cell.outerWidth() - cell.width();
              var bounding = browser.bBounding ? Math.ceil(headerCells[i].getBoundingClientRect().width) : cell.outerWidth();
              total += bounding;
              columns[visibleColumns[i]].sWidth = _fnStringToCss(bounding - border);
            }
            table.style.width = _fnStringToCss(total);
            holder.remove();
          }
          if (tableWidthAttr) {
            table.style.width = _fnStringToCss(tableWidthAttr);
          }
          if ((tableWidthAttr || scrollX) && !oSettings._reszEvt) {
            var bindResize = function() {
              $2(window2).on("resize.DT-" + oSettings.sInstance, _fnThrottle(function() {
                _fnAdjustColumnSizing(oSettings);
              }));
            };
            if (ie67) {
              setTimeout(bindResize, 1e3);
            } else {
              bindResize();
            }
            oSettings._reszEvt = true;
          }
        }
        var _fnThrottle = DataTable.util.throttle;
        function _fnConvertToWidth(width, parent) {
          if (!width) {
            return 0;
          }
          var n = $2("<div/>").css("width", _fnStringToCss(width)).appendTo(parent || document2.body);
          var val = n[0].offsetWidth;
          n.remove();
          return val;
        }
        function _fnGetWidestNode(settings, colIdx) {
          var idx = _fnGetMaxLenString(settings, colIdx);
          if (idx < 0) {
            return null;
          }
          var data = settings.aoData[idx];
          return !data.nTr ? $2("<td/>").html(_fnGetCellData(settings, idx, colIdx, "display"))[0] : data.anCells[colIdx];
        }
        function _fnGetMaxLenString(settings, colIdx) {
          var s, max = -1, maxIdx = -1;
          for (var i = 0, ien = settings.aoData.length; i < ien; i++) {
            s = _fnGetCellData(settings, i, colIdx, "display") + "";
            s = s.replace(__re_html_remove, "");
            s = s.replace(/&nbsp;/g, " ");
            if (s.length > max) {
              max = s.length;
              maxIdx = i;
            }
          }
          return maxIdx;
        }
        function _fnStringToCss(s) {
          if (s === null) {
            return "0px";
          }
          if (typeof s == "number") {
            return s < 0 ? "0px" : s + "px";
          }
          return s.match(/\d$/) ? s + "px" : s;
        }
        function _fnSortFlatten(settings) {
          var i, iLen, k, kLen, aSort = [], aiOrig = [], aoColumns = settings.aoColumns, aDataSort, iCol, sType, srcCol, fixed = settings.aaSortingFixed, fixedObj = $2.isPlainObject(fixed), nestedSort = [], add = function(a) {
            if (a.length && !Array.isArray(a[0])) {
              nestedSort.push(a);
            } else {
              $2.merge(nestedSort, a);
            }
          };
          if (Array.isArray(fixed)) {
            add(fixed);
          }
          if (fixedObj && fixed.pre) {
            add(fixed.pre);
          }
          add(settings.aaSorting);
          if (fixedObj && fixed.post) {
            add(fixed.post);
          }
          for (i = 0; i < nestedSort.length; i++) {
            srcCol = nestedSort[i][0];
            aDataSort = aoColumns[srcCol].aDataSort;
            for (k = 0, kLen = aDataSort.length; k < kLen; k++) {
              iCol = aDataSort[k];
              sType = aoColumns[iCol].sType || "string";
              if (nestedSort[i]._idx === undefined2) {
                nestedSort[i]._idx = $2.inArray(nestedSort[i][1], aoColumns[iCol].asSorting);
              }
              aSort.push({
                src: srcCol,
                col: iCol,
                dir: nestedSort[i][1],
                index: nestedSort[i]._idx,
                type: sType,
                formatter: DataTable.ext.type.order[sType + "-pre"]
              });
            }
          }
          return aSort;
        }
        function _fnSort(oSettings) {
          var i, ien, iLen, j, jLen, k, kLen, sDataType, nTh, aiOrig = [], oExtSort = DataTable.ext.type.order, aoData = oSettings.aoData, aoColumns = oSettings.aoColumns, aDataSort, data, iCol, sType, oSort, formatters = 0, sortCol, displayMaster = oSettings.aiDisplayMaster, aSort;
          _fnColumnTypes(oSettings);
          aSort = _fnSortFlatten(oSettings);
          for (i = 0, ien = aSort.length; i < ien; i++) {
            sortCol = aSort[i];
            if (sortCol.formatter) {
              formatters++;
            }
            _fnSortData(oSettings, sortCol.col);
          }
          if (_fnDataSource(oSettings) != "ssp" && aSort.length !== 0) {
            for (i = 0, iLen = displayMaster.length; i < iLen; i++) {
              aiOrig[displayMaster[i]] = i;
            }
            if (formatters === aSort.length) {
              displayMaster.sort(function(a, b) {
                var x, y, k2, test, sort, len = aSort.length, dataA = aoData[a]._aSortData, dataB = aoData[b]._aSortData;
                for (k2 = 0; k2 < len; k2++) {
                  sort = aSort[k2];
                  x = dataA[sort.col];
                  y = dataB[sort.col];
                  test = x < y ? -1 : x > y ? 1 : 0;
                  if (test !== 0) {
                    return sort.dir === "asc" ? test : -test;
                  }
                }
                x = aiOrig[a];
                y = aiOrig[b];
                return x < y ? -1 : x > y ? 1 : 0;
              });
            } else {
              displayMaster.sort(function(a, b) {
                var x, y, k2, l, test, sort, fn, len = aSort.length, dataA = aoData[a]._aSortData, dataB = aoData[b]._aSortData;
                for (k2 = 0; k2 < len; k2++) {
                  sort = aSort[k2];
                  x = dataA[sort.col];
                  y = dataB[sort.col];
                  fn = oExtSort[sort.type + "-" + sort.dir] || oExtSort["string-" + sort.dir];
                  test = fn(x, y);
                  if (test !== 0) {
                    return test;
                  }
                }
                x = aiOrig[a];
                y = aiOrig[b];
                return x < y ? -1 : x > y ? 1 : 0;
              });
            }
          }
          oSettings.bSorted = true;
        }
        function _fnSortAria(settings) {
          var label;
          var nextSort;
          var columns = settings.aoColumns;
          var aSort = _fnSortFlatten(settings);
          var oAria = settings.oLanguage.oAria;
          for (var i = 0, iLen = columns.length; i < iLen; i++) {
            var col = columns[i];
            var asSorting = col.asSorting;
            var sTitle = col.ariaTitle || col.sTitle.replace(/<.*?>/g, "");
            var th = col.nTh;
            th.removeAttribute("aria-sort");
            if (col.bSortable) {
              if (aSort.length > 0 && aSort[0].col == i) {
                th.setAttribute("aria-sort", aSort[0].dir == "asc" ? "ascending" : "descending");
                nextSort = asSorting[aSort[0].index + 1] || asSorting[0];
              } else {
                nextSort = asSorting[0];
              }
              label = sTitle + (nextSort === "asc" ? oAria.sSortAscending : oAria.sSortDescending);
            } else {
              label = sTitle;
            }
            th.setAttribute("aria-label", label);
          }
        }
        function _fnSortListener(settings, colIdx, append, callback) {
          var col = settings.aoColumns[colIdx];
          var sorting = settings.aaSorting;
          var asSorting = col.asSorting;
          var nextSortIdx;
          var next = function(a, overflow) {
            var idx = a._idx;
            if (idx === undefined2) {
              idx = $2.inArray(a[1], asSorting);
            }
            return idx + 1 < asSorting.length ? idx + 1 : overflow ? null : 0;
          };
          if (typeof sorting[0] === "number") {
            sorting = settings.aaSorting = [sorting];
          }
          if (append && settings.oFeatures.bSortMulti) {
            var sortIdx = $2.inArray(colIdx, _pluck(sorting, "0"));
            if (sortIdx !== -1) {
              nextSortIdx = next(sorting[sortIdx], true);
              if (nextSortIdx === null && sorting.length === 1) {
                nextSortIdx = 0;
              }
              if (nextSortIdx === null) {
                sorting.splice(sortIdx, 1);
              } else {
                sorting[sortIdx][1] = asSorting[nextSortIdx];
                sorting[sortIdx]._idx = nextSortIdx;
              }
            } else {
              sorting.push([colIdx, asSorting[0], 0]);
              sorting[sorting.length - 1]._idx = 0;
            }
          } else if (sorting.length && sorting[0][0] == colIdx) {
            nextSortIdx = next(sorting[0]);
            sorting.length = 1;
            sorting[0][1] = asSorting[nextSortIdx];
            sorting[0]._idx = nextSortIdx;
          } else {
            sorting.length = 0;
            sorting.push([colIdx, asSorting[0]]);
            sorting[0]._idx = 0;
          }
          _fnReDraw(settings);
          if (typeof callback == "function") {
            callback(settings);
          }
        }
        function _fnSortAttachListener(settings, attachTo, colIdx, callback) {
          var col = settings.aoColumns[colIdx];
          _fnBindAction(attachTo, {}, function(e) {
            if (col.bSortable === false) {
              return;
            }
            if (settings.oFeatures.bProcessing) {
              _fnProcessingDisplay(settings, true);
              setTimeout(function() {
                _fnSortListener(settings, colIdx, e.shiftKey, callback);
                if (_fnDataSource(settings) !== "ssp") {
                  _fnProcessingDisplay(settings, false);
                }
              }, 0);
            } else {
              _fnSortListener(settings, colIdx, e.shiftKey, callback);
            }
          });
        }
        function _fnSortingClasses(settings) {
          var oldSort = settings.aLastSort;
          var sortClass = settings.oClasses.sSortColumn;
          var sort = _fnSortFlatten(settings);
          var features = settings.oFeatures;
          var i, ien, colIdx;
          if (features.bSort && features.bSortClasses) {
            for (i = 0, ien = oldSort.length; i < ien; i++) {
              colIdx = oldSort[i].src;
              $2(_pluck(settings.aoData, "anCells", colIdx)).removeClass(sortClass + (i < 2 ? i + 1 : 3));
            }
            for (i = 0, ien = sort.length; i < ien; i++) {
              colIdx = sort[i].src;
              $2(_pluck(settings.aoData, "anCells", colIdx)).addClass(sortClass + (i < 2 ? i + 1 : 3));
            }
          }
          settings.aLastSort = sort;
        }
        function _fnSortData(settings, idx) {
          var column = settings.aoColumns[idx];
          var customSort = DataTable.ext.order[column.sSortDataType];
          var customData;
          if (customSort) {
            customData = customSort.call(settings.oInstance, settings, idx, _fnColumnIndexToVisible(settings, idx));
          }
          var row, cellData;
          var formatter = DataTable.ext.type.order[column.sType + "-pre"];
          for (var i = 0, ien = settings.aoData.length; i < ien; i++) {
            row = settings.aoData[i];
            if (!row._aSortData) {
              row._aSortData = [];
            }
            if (!row._aSortData[idx] || customSort) {
              cellData = customSort ? customData[i] : _fnGetCellData(settings, i, idx, "sort");
              row._aSortData[idx] = formatter ? formatter(cellData) : cellData;
            }
          }
        }
        function _fnSaveState(settings) {
          if (settings._bLoadingState) {
            return;
          }
          var state = {
            time: +new Date(),
            start: settings._iDisplayStart,
            length: settings._iDisplayLength,
            order: $2.extend(true, [], settings.aaSorting),
            search: _fnSearchToCamel(settings.oPreviousSearch),
            columns: $2.map(settings.aoColumns, function(col, i) {
              return {
                visible: col.bVisible,
                search: _fnSearchToCamel(settings.aoPreSearchCols[i])
              };
            })
          };
          settings.oSavedState = state;
          _fnCallbackFire(settings, "aoStateSaveParams", "stateSaveParams", [settings, state]);
          if (settings.oFeatures.bStateSave && !settings.bDestroying) {
            settings.fnStateSaveCallback.call(settings.oInstance, settings, state);
          }
        }
        function _fnLoadState(settings, oInit, callback) {
          if (!settings.oFeatures.bStateSave) {
            callback();
            return;
          }
          var loaded = function(state2) {
            _fnImplementState(settings, state2, callback);
          };
          var state = settings.fnStateLoadCallback.call(settings.oInstance, settings, loaded);
          if (state !== undefined2) {
            _fnImplementState(settings, state, callback);
          }
          return true;
        }
        function _fnImplementState(settings, s, callback) {
          var i, ien;
          var columns = settings.aoColumns;
          settings._bLoadingState = true;
          var api = settings._bInitComplete ? new DataTable.Api(settings) : null;
          if (!s || !s.time) {
            settings._bLoadingState = false;
            callback();
            return;
          }
          var abStateLoad = _fnCallbackFire(settings, "aoStateLoadParams", "stateLoadParams", [settings, s]);
          if ($2.inArray(false, abStateLoad) !== -1) {
            settings._bLoadingState = false;
            callback();
            return;
          }
          var duration = settings.iStateDuration;
          if (duration > 0 && s.time < +new Date() - duration * 1e3) {
            settings._bLoadingState = false;
            callback();
            return;
          }
          if (s.columns && columns.length !== s.columns.length) {
            settings._bLoadingState = false;
            callback();
            return;
          }
          settings.oLoadedState = $2.extend(true, {}, s);
          if (s.start !== undefined2) {
            if (api === null) {
              settings._iDisplayStart = s.start;
              settings.iInitDisplayStart = s.start;
            } else {
              _fnPageChange(settings, s.start / s.length);
            }
          }
          if (s.length !== undefined2) {
            settings._iDisplayLength = s.length;
          }
          if (s.order !== undefined2) {
            settings.aaSorting = [];
            $2.each(s.order, function(i2, col2) {
              settings.aaSorting.push(col2[0] >= columns.length ? [0, col2[1]] : col2);
            });
          }
          if (s.search !== undefined2) {
            $2.extend(settings.oPreviousSearch, _fnSearchToHung(s.search));
          }
          if (s.columns) {
            for (i = 0, ien = s.columns.length; i < ien; i++) {
              var col = s.columns[i];
              if (col.visible !== undefined2) {
                if (api) {
                  api.column(i).visible(col.visible, false);
                } else {
                  columns[i].bVisible = col.visible;
                }
              }
              if (col.search !== undefined2) {
                $2.extend(settings.aoPreSearchCols[i], _fnSearchToHung(col.search));
              }
            }
            if (api) {
              api.columns.adjust();
            }
          }
          settings._bLoadingState = false;
          _fnCallbackFire(settings, "aoStateLoaded", "stateLoaded", [settings, s]);
          callback();
        }
        ;
        function _fnSettingsFromNode(table) {
          var settings = DataTable.settings;
          var idx = $2.inArray(table, _pluck(settings, "nTable"));
          return idx !== -1 ? settings[idx] : null;
        }
        function _fnLog(settings, level, msg, tn) {
          msg = "DataTables warning: " + (settings ? "table id=" + settings.sTableId + " - " : "") + msg;
          if (tn) {
            msg += ". For more information about this error, please see http://datatables.net/tn/" + tn;
          }
          if (!level) {
            var ext = DataTable.ext;
            var type = ext.sErrMode || ext.errMode;
            if (settings) {
              _fnCallbackFire(settings, null, "error", [settings, tn, msg]);
            }
            if (type == "alert") {
              alert(msg);
            } else if (type == "throw") {
              throw new Error(msg);
            } else if (typeof type == "function") {
              type(settings, tn, msg);
            }
          } else if (window2.console && console.log) {
            console.log(msg);
          }
        }
        function _fnMap(ret, src, name, mappedName) {
          if (Array.isArray(name)) {
            $2.each(name, function(i, val) {
              if (Array.isArray(val)) {
                _fnMap(ret, src, val[0], val[1]);
              } else {
                _fnMap(ret, src, val);
              }
            });
            return;
          }
          if (mappedName === undefined2) {
            mappedName = name;
          }
          if (src[name] !== undefined2) {
            ret[mappedName] = src[name];
          }
        }
        function _fnExtend(out, extender, breakRefs) {
          var val;
          for (var prop in extender) {
            if (extender.hasOwnProperty(prop)) {
              val = extender[prop];
              if ($2.isPlainObject(val)) {
                if (!$2.isPlainObject(out[prop])) {
                  out[prop] = {};
                }
                $2.extend(true, out[prop], val);
              } else if (breakRefs && prop !== "data" && prop !== "aaData" && Array.isArray(val)) {
                out[prop] = val.slice();
              } else {
                out[prop] = val;
              }
            }
          }
          return out;
        }
        function _fnBindAction(n, oData, fn) {
          $2(n).on("click.DT", oData, function(e) {
            $2(n).trigger("blur");
            fn(e);
          }).on("keypress.DT", oData, function(e) {
            if (e.which === 13) {
              e.preventDefault();
              fn(e);
            }
          }).on("selectstart.DT", function() {
            return false;
          });
        }
        function _fnCallbackReg(oSettings, sStore, fn, sName) {
          if (fn) {
            oSettings[sStore].push({
              "fn": fn,
              "sName": sName
            });
          }
        }
        function _fnCallbackFire(settings, callbackArr, eventName, args) {
          var ret = [];
          if (callbackArr) {
            ret = $2.map(settings[callbackArr].slice().reverse(), function(val, i) {
              return val.fn.apply(settings.oInstance, args);
            });
          }
          if (eventName !== null) {
            var e = $2.Event(eventName + ".dt");
            $2(settings.nTable).trigger(e, args);
            ret.push(e.result);
          }
          return ret;
        }
        function _fnLengthOverflow(settings) {
          var start = settings._iDisplayStart, end = settings.fnDisplayEnd(), len = settings._iDisplayLength;
          if (start >= end) {
            start = end - len;
          }
          start -= start % len;
          if (len === -1 || start < 0) {
            start = 0;
          }
          settings._iDisplayStart = start;
        }
        function _fnRenderer(settings, type) {
          var renderer = settings.renderer;
          var host = DataTable.ext.renderer[type];
          if ($2.isPlainObject(renderer) && renderer[type]) {
            return host[renderer[type]] || host._;
          } else if (typeof renderer === "string") {
            return host[renderer] || host._;
          }
          return host._;
        }
        function _fnDataSource(settings) {
          if (settings.oFeatures.bServerSide) {
            return "ssp";
          } else if (settings.ajax || settings.sAjaxSource) {
            return "ajax";
          }
          return "dom";
        }
        var __apiStruct = [];
        var __arrayProto = Array.prototype;
        var _toSettings = function(mixed) {
          var idx, jq;
          var settings = DataTable.settings;
          var tables = $2.map(settings, function(el, i) {
            return el.nTable;
          });
          if (!mixed) {
            return [];
          } else if (mixed.nTable && mixed.oApi) {
            return [mixed];
          } else if (mixed.nodeName && mixed.nodeName.toLowerCase() === "table") {
            idx = $2.inArray(mixed, tables);
            return idx !== -1 ? [settings[idx]] : null;
          } else if (mixed && typeof mixed.settings === "function") {
            return mixed.settings().toArray();
          } else if (typeof mixed === "string") {
            jq = $2(mixed);
          } else if (mixed instanceof $2) {
            jq = mixed;
          }
          if (jq) {
            return jq.map(function(i) {
              idx = $2.inArray(this, tables);
              return idx !== -1 ? settings[idx] : null;
            }).toArray();
          }
        };
        _Api = function(context, data) {
          if (!(this instanceof _Api)) {
            return new _Api(context, data);
          }
          var settings = [];
          var ctxSettings = function(o) {
            var a = _toSettings(o);
            if (a) {
              settings.push.apply(settings, a);
            }
          };
          if (Array.isArray(context)) {
            for (var i = 0, ien = context.length; i < ien; i++) {
              ctxSettings(context[i]);
            }
          } else {
            ctxSettings(context);
          }
          this.context = _unique(settings);
          if (data) {
            $2.merge(this, data);
          }
          this.selector = {
            rows: null,
            cols: null,
            opts: null
          };
          _Api.extend(this, this, __apiStruct);
        };
        DataTable.Api = _Api;
        $2.extend(_Api.prototype, {
          any: function() {
            return this.count() !== 0;
          },
          concat: __arrayProto.concat,
          context: [],
          count: function() {
            return this.flatten().length;
          },
          each: function(fn) {
            for (var i = 0, ien = this.length; i < ien; i++) {
              fn.call(this, this[i], i, this);
            }
            return this;
          },
          eq: function(idx) {
            var ctx = this.context;
            return ctx.length > idx ? new _Api(ctx[idx], this[idx]) : null;
          },
          filter: function(fn) {
            var a = [];
            if (__arrayProto.filter) {
              a = __arrayProto.filter.call(this, fn, this);
            } else {
              for (var i = 0, ien = this.length; i < ien; i++) {
                if (fn.call(this, this[i], i, this)) {
                  a.push(this[i]);
                }
              }
            }
            return new _Api(this.context, a);
          },
          flatten: function() {
            var a = [];
            return new _Api(this.context, a.concat.apply(a, this.toArray()));
          },
          join: __arrayProto.join,
          indexOf: __arrayProto.indexOf || function(obj, start) {
            for (var i = start || 0, ien = this.length; i < ien; i++) {
              if (this[i] === obj) {
                return i;
              }
            }
            return -1;
          },
          iterator: function(flatten, type, fn, alwaysNew) {
            var a = [], ret, i, ien, j, jen, context = this.context, rows, items, item, selector = this.selector;
            if (typeof flatten === "string") {
              alwaysNew = fn;
              fn = type;
              type = flatten;
              flatten = false;
            }
            for (i = 0, ien = context.length; i < ien; i++) {
              var apiInst = new _Api(context[i]);
              if (type === "table") {
                ret = fn.call(apiInst, context[i], i);
                if (ret !== undefined2) {
                  a.push(ret);
                }
              } else if (type === "columns" || type === "rows") {
                ret = fn.call(apiInst, context[i], this[i], i);
                if (ret !== undefined2) {
                  a.push(ret);
                }
              } else if (type === "column" || type === "column-rows" || type === "row" || type === "cell") {
                items = this[i];
                if (type === "column-rows") {
                  rows = _selector_row_indexes(context[i], selector.opts);
                }
                for (j = 0, jen = items.length; j < jen; j++) {
                  item = items[j];
                  if (type === "cell") {
                    ret = fn.call(apiInst, context[i], item.row, item.column, i, j);
                  } else {
                    ret = fn.call(apiInst, context[i], item, i, j, rows);
                  }
                  if (ret !== undefined2) {
                    a.push(ret);
                  }
                }
              }
            }
            if (a.length || alwaysNew) {
              var api = new _Api(context, flatten ? a.concat.apply([], a) : a);
              var apiSelector = api.selector;
              apiSelector.rows = selector.rows;
              apiSelector.cols = selector.cols;
              apiSelector.opts = selector.opts;
              return api;
            }
            return this;
          },
          lastIndexOf: __arrayProto.lastIndexOf || function(obj, start) {
            return this.indexOf.apply(this.toArray.reverse(), arguments);
          },
          length: 0,
          map: function(fn) {
            var a = [];
            if (__arrayProto.map) {
              a = __arrayProto.map.call(this, fn, this);
            } else {
              for (var i = 0, ien = this.length; i < ien; i++) {
                a.push(fn.call(this, this[i], i));
              }
            }
            return new _Api(this.context, a);
          },
          pluck: function(prop) {
            return this.map(function(el) {
              return el[prop];
            });
          },
          pop: __arrayProto.pop,
          push: __arrayProto.push,
          reduce: __arrayProto.reduce || function(fn, init) {
            return _fnReduce(this, fn, init, 0, this.length, 1);
          },
          reduceRight: __arrayProto.reduceRight || function(fn, init) {
            return _fnReduce(this, fn, init, this.length - 1, -1, -1);
          },
          reverse: __arrayProto.reverse,
          selector: null,
          shift: __arrayProto.shift,
          slice: function() {
            return new _Api(this.context, this);
          },
          sort: __arrayProto.sort,
          splice: __arrayProto.splice,
          toArray: function() {
            return __arrayProto.slice.call(this);
          },
          to$: function() {
            return $2(this);
          },
          toJQuery: function() {
            return $2(this);
          },
          unique: function() {
            return new _Api(this.context, _unique(this));
          },
          unshift: __arrayProto.unshift
        });
        _Api.extend = function(scope, obj, ext) {
          if (!ext.length || !obj || !(obj instanceof _Api) && !obj.__dt_wrapper) {
            return;
          }
          var i, ien, struct, methodScoping = function(scope2, fn, struc) {
            return function() {
              var ret = fn.apply(scope2, arguments);
              _Api.extend(ret, ret, struc.methodExt);
              return ret;
            };
          };
          for (i = 0, ien = ext.length; i < ien; i++) {
            struct = ext[i];
            obj[struct.name] = struct.type === "function" ? methodScoping(scope, struct.val, struct) : struct.type === "object" ? {} : struct.val;
            obj[struct.name].__dt_wrapper = true;
            _Api.extend(scope, obj[struct.name], struct.propExt);
          }
        };
        _Api.register = _api_register = function(name, val) {
          if (Array.isArray(name)) {
            for (var j = 0, jen = name.length; j < jen; j++) {
              _Api.register(name[j], val);
            }
            return;
          }
          var i, ien, heir = name.split("."), struct = __apiStruct, key, method;
          var find = function(src2, name2) {
            for (var i2 = 0, ien2 = src2.length; i2 < ien2; i2++) {
              if (src2[i2].name === name2) {
                return src2[i2];
              }
            }
            return null;
          };
          for (i = 0, ien = heir.length; i < ien; i++) {
            method = heir[i].indexOf("()") !== -1;
            key = method ? heir[i].replace("()", "") : heir[i];
            var src = find(struct, key);
            if (!src) {
              src = {
                name: key,
                val: {},
                methodExt: [],
                propExt: [],
                type: "object"
              };
              struct.push(src);
            }
            if (i === ien - 1) {
              src.val = val;
              src.type = typeof val === "function" ? "function" : $2.isPlainObject(val) ? "object" : "other";
            } else {
              struct = method ? src.methodExt : src.propExt;
            }
          }
        };
        _Api.registerPlural = _api_registerPlural = function(pluralName, singularName, val) {
          _Api.register(pluralName, val);
          _Api.register(singularName, function() {
            var ret = val.apply(this, arguments);
            if (ret === this) {
              return this;
            } else if (ret instanceof _Api) {
              return ret.length ? Array.isArray(ret[0]) ? new _Api(ret.context, ret[0]) : ret[0] : undefined2;
            }
            return ret;
          });
        };
        var __table_selector = function(selector, a) {
          if (Array.isArray(selector)) {
            return $2.map(selector, function(item) {
              return __table_selector(item, a);
            });
          }
          if (typeof selector === "number") {
            return [a[selector]];
          }
          var nodes = $2.map(a, function(el, i) {
            return el.nTable;
          });
          return $2(nodes).filter(selector).map(function(i) {
            var idx = $2.inArray(this, nodes);
            return a[idx];
          }).toArray();
        };
        _api_register("tables()", function(selector) {
          return selector !== undefined2 && selector !== null ? new _Api(__table_selector(selector, this.context)) : this;
        });
        _api_register("table()", function(selector) {
          var tables = this.tables(selector);
          var ctx = tables.context;
          return ctx.length ? new _Api(ctx[0]) : tables;
        });
        _api_registerPlural("tables().nodes()", "table().node()", function() {
          return this.iterator("table", function(ctx) {
            return ctx.nTable;
          }, 1);
        });
        _api_registerPlural("tables().body()", "table().body()", function() {
          return this.iterator("table", function(ctx) {
            return ctx.nTBody;
          }, 1);
        });
        _api_registerPlural("tables().header()", "table().header()", function() {
          return this.iterator("table", function(ctx) {
            return ctx.nTHead;
          }, 1);
        });
        _api_registerPlural("tables().footer()", "table().footer()", function() {
          return this.iterator("table", function(ctx) {
            return ctx.nTFoot;
          }, 1);
        });
        _api_registerPlural("tables().containers()", "table().container()", function() {
          return this.iterator("table", function(ctx) {
            return ctx.nTableWrapper;
          }, 1);
        });
        _api_register("draw()", function(paging) {
          return this.iterator("table", function(settings) {
            if (paging === "page") {
              _fnDraw(settings);
            } else {
              if (typeof paging === "string") {
                paging = paging === "full-hold" ? false : true;
              }
              _fnReDraw(settings, paging === false);
            }
          });
        });
        _api_register("page()", function(action) {
          if (action === undefined2) {
            return this.page.info().page;
          }
          return this.iterator("table", function(settings) {
            _fnPageChange(settings, action);
          });
        });
        _api_register("page.info()", function(action) {
          if (this.context.length === 0) {
            return undefined2;
          }
          var settings = this.context[0], start = settings._iDisplayStart, len = settings.oFeatures.bPaginate ? settings._iDisplayLength : -1, visRecords = settings.fnRecordsDisplay(), all = len === -1;
          return {
            "page": all ? 0 : Math.floor(start / len),
            "pages": all ? 1 : Math.ceil(visRecords / len),
            "start": start,
            "end": settings.fnDisplayEnd(),
            "length": len,
            "recordsTotal": settings.fnRecordsTotal(),
            "recordsDisplay": visRecords,
            "serverSide": _fnDataSource(settings) === "ssp"
          };
        });
        _api_register("page.len()", function(len) {
          if (len === undefined2) {
            return this.context.length !== 0 ? this.context[0]._iDisplayLength : undefined2;
          }
          return this.iterator("table", function(settings) {
            _fnLengthChange(settings, len);
          });
        });
        var __reload = function(settings, holdPosition, callback) {
          if (callback) {
            var api = new _Api(settings);
            api.one("draw", function() {
              callback(api.ajax.json());
            });
          }
          if (_fnDataSource(settings) == "ssp") {
            _fnReDraw(settings, holdPosition);
          } else {
            _fnProcessingDisplay(settings, true);
            var xhr = settings.jqXHR;
            if (xhr && xhr.readyState !== 4) {
              xhr.abort();
            }
            _fnBuildAjax(settings, [], function(json) {
              _fnClearTable(settings);
              var data = _fnAjaxDataSrc(settings, json);
              for (var i = 0, ien = data.length; i < ien; i++) {
                _fnAddData(settings, data[i]);
              }
              _fnReDraw(settings, holdPosition);
              _fnProcessingDisplay(settings, false);
            });
          }
        };
        _api_register("ajax.json()", function() {
          var ctx = this.context;
          if (ctx.length > 0) {
            return ctx[0].json;
          }
        });
        _api_register("ajax.params()", function() {
          var ctx = this.context;
          if (ctx.length > 0) {
            return ctx[0].oAjaxData;
          }
        });
        _api_register("ajax.reload()", function(callback, resetPaging) {
          return this.iterator("table", function(settings) {
            __reload(settings, resetPaging === false, callback);
          });
        });
        _api_register("ajax.url()", function(url) {
          var ctx = this.context;
          if (url === undefined2) {
            if (ctx.length === 0) {
              return undefined2;
            }
            ctx = ctx[0];
            return ctx.ajax ? $2.isPlainObject(ctx.ajax) ? ctx.ajax.url : ctx.ajax : ctx.sAjaxSource;
          }
          return this.iterator("table", function(settings) {
            if ($2.isPlainObject(settings.ajax)) {
              settings.ajax.url = url;
            } else {
              settings.ajax = url;
            }
          });
        });
        _api_register("ajax.url().load()", function(callback, resetPaging) {
          return this.iterator("table", function(ctx) {
            __reload(ctx, resetPaging === false, callback);
          });
        });
        var _selector_run = function(type, selector, selectFn, settings, opts) {
          var out = [], res, a, i, ien, j, jen, selectorType = typeof selector;
          if (!selector || selectorType === "string" || selectorType === "function" || selector.length === undefined2) {
            selector = [selector];
          }
          for (i = 0, ien = selector.length; i < ien; i++) {
            a = selector[i] && selector[i].split && !selector[i].match(/[\[\(:]/) ? selector[i].split(",") : [selector[i]];
            for (j = 0, jen = a.length; j < jen; j++) {
              res = selectFn(typeof a[j] === "string" ? a[j].trim() : a[j]);
              if (res && res.length) {
                out = out.concat(res);
              }
            }
          }
          var ext = _ext.selector[type];
          if (ext.length) {
            for (i = 0, ien = ext.length; i < ien; i++) {
              out = ext[i](settings, opts, out);
            }
          }
          return _unique(out);
        };
        var _selector_opts = function(opts) {
          if (!opts) {
            opts = {};
          }
          if (opts.filter && opts.search === undefined2) {
            opts.search = opts.filter;
          }
          return $2.extend({
            search: "none",
            order: "current",
            page: "all"
          }, opts);
        };
        var _selector_first = function(inst) {
          for (var i = 0, ien = inst.length; i < ien; i++) {
            if (inst[i].length > 0) {
              inst[0] = inst[i];
              inst[0].length = 1;
              inst.length = 1;
              inst.context = [inst.context[i]];
              return inst;
            }
          }
          inst.length = 0;
          return inst;
        };
        var _selector_row_indexes = function(settings, opts) {
          var i, ien, tmp, a = [], displayFiltered = settings.aiDisplay, displayMaster = settings.aiDisplayMaster;
          var search = opts.search, order = opts.order, page = opts.page;
          if (_fnDataSource(settings) == "ssp") {
            return search === "removed" ? [] : _range(0, displayMaster.length);
          } else if (page == "current") {
            for (i = settings._iDisplayStart, ien = settings.fnDisplayEnd(); i < ien; i++) {
              a.push(displayFiltered[i]);
            }
          } else if (order == "current" || order == "applied") {
            if (search == "none") {
              a = displayMaster.slice();
            } else if (search == "applied") {
              a = displayFiltered.slice();
            } else if (search == "removed") {
              var displayFilteredMap = {};
              for (var i = 0, ien = displayFiltered.length; i < ien; i++) {
                displayFilteredMap[displayFiltered[i]] = null;
              }
              a = $2.map(displayMaster, function(el) {
                return !displayFilteredMap.hasOwnProperty(el) ? el : null;
              });
            }
          } else if (order == "index" || order == "original") {
            for (i = 0, ien = settings.aoData.length; i < ien; i++) {
              if (search == "none") {
                a.push(i);
              } else {
                tmp = $2.inArray(i, displayFiltered);
                if (tmp === -1 && search == "removed" || tmp >= 0 && search == "applied") {
                  a.push(i);
                }
              }
            }
          }
          return a;
        };
        var __row_selector = function(settings, selector, opts) {
          var rows;
          var run = function(sel) {
            var selInt = _intVal(sel);
            var i, ien;
            var aoData = settings.aoData;
            if (selInt !== null && !opts) {
              return [selInt];
            }
            if (!rows) {
              rows = _selector_row_indexes(settings, opts);
            }
            if (selInt !== null && $2.inArray(selInt, rows) !== -1) {
              return [selInt];
            } else if (sel === null || sel === undefined2 || sel === "") {
              return rows;
            }
            if (typeof sel === "function") {
              return $2.map(rows, function(idx) {
                var row = aoData[idx];
                return sel(idx, row._aData, row.nTr) ? idx : null;
              });
            }
            if (sel.nodeName) {
              var rowIdx = sel._DT_RowIndex;
              var cellIdx = sel._DT_CellIndex;
              if (rowIdx !== undefined2) {
                return aoData[rowIdx] && aoData[rowIdx].nTr === sel ? [rowIdx] : [];
              } else if (cellIdx) {
                return aoData[cellIdx.row] && aoData[cellIdx.row].nTr === sel.parentNode ? [cellIdx.row] : [];
              } else {
                var host = $2(sel).closest("*[data-dt-row]");
                return host.length ? [host.data("dt-row")] : [];
              }
            }
            if (typeof sel === "string" && sel.charAt(0) === "#") {
              var rowObj = settings.aIds[sel.replace(/^#/, "")];
              if (rowObj !== undefined2) {
                return [rowObj.idx];
              }
            }
            var nodes = _removeEmpty(_pluck_order(settings.aoData, rows, "nTr"));
            return $2(nodes).filter(sel).map(function() {
              return this._DT_RowIndex;
            }).toArray();
          };
          return _selector_run("row", selector, run, settings, opts);
        };
        _api_register("rows()", function(selector, opts) {
          if (selector === undefined2) {
            selector = "";
          } else if ($2.isPlainObject(selector)) {
            opts = selector;
            selector = "";
          }
          opts = _selector_opts(opts);
          var inst = this.iterator("table", function(settings) {
            return __row_selector(settings, selector, opts);
          }, 1);
          inst.selector.rows = selector;
          inst.selector.opts = opts;
          return inst;
        });
        _api_register("rows().nodes()", function() {
          return this.iterator("row", function(settings, row) {
            return settings.aoData[row].nTr || undefined2;
          }, 1);
        });
        _api_register("rows().data()", function() {
          return this.iterator(true, "rows", function(settings, rows) {
            return _pluck_order(settings.aoData, rows, "_aData");
          }, 1);
        });
        _api_registerPlural("rows().cache()", "row().cache()", function(type) {
          return this.iterator("row", function(settings, row) {
            var r = settings.aoData[row];
            return type === "search" ? r._aFilterData : r._aSortData;
          }, 1);
        });
        _api_registerPlural("rows().invalidate()", "row().invalidate()", function(src) {
          return this.iterator("row", function(settings, row) {
            _fnInvalidate(settings, row, src);
          });
        });
        _api_registerPlural("rows().indexes()", "row().index()", function() {
          return this.iterator("row", function(settings, row) {
            return row;
          }, 1);
        });
        _api_registerPlural("rows().ids()", "row().id()", function(hash) {
          var a = [];
          var context = this.context;
          for (var i = 0, ien = context.length; i < ien; i++) {
            for (var j = 0, jen = this[i].length; j < jen; j++) {
              var id = context[i].rowIdFn(context[i].aoData[this[i][j]]._aData);
              a.push((hash === true ? "#" : "") + id);
            }
          }
          return new _Api(context, a);
        });
        _api_registerPlural("rows().remove()", "row().remove()", function() {
          var that = this;
          this.iterator("row", function(settings, row, thatIdx) {
            var data = settings.aoData;
            var rowData = data[row];
            var i, ien, j, jen;
            var loopRow, loopCells;
            data.splice(row, 1);
            for (i = 0, ien = data.length; i < ien; i++) {
              loopRow = data[i];
              loopCells = loopRow.anCells;
              if (loopRow.nTr !== null) {
                loopRow.nTr._DT_RowIndex = i;
              }
              if (loopCells !== null) {
                for (j = 0, jen = loopCells.length; j < jen; j++) {
                  loopCells[j]._DT_CellIndex.row = i;
                }
              }
            }
            _fnDeleteIndex(settings.aiDisplayMaster, row);
            _fnDeleteIndex(settings.aiDisplay, row);
            _fnDeleteIndex(that[thatIdx], row, false);
            if (settings._iRecordsDisplay > 0) {
              settings._iRecordsDisplay--;
            }
            _fnLengthOverflow(settings);
            var id = settings.rowIdFn(rowData._aData);
            if (id !== undefined2) {
              delete settings.aIds[id];
            }
          });
          this.iterator("table", function(settings) {
            for (var i = 0, ien = settings.aoData.length; i < ien; i++) {
              settings.aoData[i].idx = i;
            }
          });
          return this;
        });
        _api_register("rows.add()", function(rows) {
          var newRows = this.iterator("table", function(settings) {
            var row, i, ien;
            var out = [];
            for (i = 0, ien = rows.length; i < ien; i++) {
              row = rows[i];
              if (row.nodeName && row.nodeName.toUpperCase() === "TR") {
                out.push(_fnAddTr(settings, row)[0]);
              } else {
                out.push(_fnAddData(settings, row));
              }
            }
            return out;
          }, 1);
          var modRows = this.rows(-1);
          modRows.pop();
          $2.merge(modRows, newRows);
          return modRows;
        });
        _api_register("row()", function(selector, opts) {
          return _selector_first(this.rows(selector, opts));
        });
        _api_register("row().data()", function(data) {
          var ctx = this.context;
          if (data === undefined2) {
            return ctx.length && this.length ? ctx[0].aoData[this[0]]._aData : undefined2;
          }
          var row = ctx[0].aoData[this[0]];
          row._aData = data;
          if (Array.isArray(data) && row.nTr && row.nTr.id) {
            _fnSetObjectDataFn(ctx[0].rowId)(data, row.nTr.id);
          }
          _fnInvalidate(ctx[0], this[0], "data");
          return this;
        });
        _api_register("row().node()", function() {
          var ctx = this.context;
          return ctx.length && this.length ? ctx[0].aoData[this[0]].nTr || null : null;
        });
        _api_register("row.add()", function(row) {
          if (row instanceof $2 && row.length) {
            row = row[0];
          }
          var rows = this.iterator("table", function(settings) {
            if (row.nodeName && row.nodeName.toUpperCase() === "TR") {
              return _fnAddTr(settings, row)[0];
            }
            return _fnAddData(settings, row);
          });
          return this.row(rows[0]);
        });
        $2(document2).on("plugin-init.dt", function(e, context) {
          var api = new _Api(context);
          api.on("stateSaveParams", function(e2, settings, d) {
            var idFn = settings.rowIdFn;
            var data = settings.aoData;
            var ids = [];
            for (var i = 0; i < data.length; i++) {
              if (data[i]._detailsShow) {
                ids.push("#" + idFn(data[i]._aData));
              }
            }
            d.childRows = ids;
          });
          var loaded = api.state.loaded();
          if (loaded && loaded.childRows) {
            api.rows($2.map(loaded.childRows, function(id) {
              return id.replace(/:/g, "\\:");
            })).every(function() {
              _fnCallbackFire(context, null, "requestChild", [this]);
            });
          }
        });
        var __details_add = function(ctx, row, data, klass) {
          var rows = [];
          var addRow = function(r, k) {
            if (Array.isArray(r) || r instanceof $2) {
              for (var i = 0, ien = r.length; i < ien; i++) {
                addRow(r[i], k);
              }
              return;
            }
            if (r.nodeName && r.nodeName.toLowerCase() === "tr") {
              rows.push(r);
            } else {
              var created = $2("<tr><td></td></tr>").addClass(k);
              $2("td", created).addClass(k).html(r)[0].colSpan = _fnVisbleColumns(ctx);
              rows.push(created[0]);
            }
          };
          addRow(data, klass);
          if (row._details) {
            row._details.detach();
          }
          row._details = $2(rows);
          if (row._detailsShow) {
            row._details.insertAfter(row.nTr);
          }
        };
        var __details_state = DataTable.util.throttle(function(ctx) {
          _fnSaveState(ctx[0]);
        }, 500);
        var __details_remove = function(api, idx) {
          var ctx = api.context;
          if (ctx.length) {
            var row = ctx[0].aoData[idx !== undefined2 ? idx : api[0]];
            if (row && row._details) {
              row._details.remove();
              row._detailsShow = undefined2;
              row._details = undefined2;
              $2(row.nTr).removeClass("dt-hasChild");
              __details_state(ctx);
            }
          }
        };
        var __details_display = function(api, show) {
          var ctx = api.context;
          if (ctx.length && api.length) {
            var row = ctx[0].aoData[api[0]];
            if (row._details) {
              row._detailsShow = show;
              if (show) {
                row._details.insertAfter(row.nTr);
                $2(row.nTr).addClass("dt-hasChild");
              } else {
                row._details.detach();
                $2(row.nTr).removeClass("dt-hasChild");
              }
              _fnCallbackFire(ctx[0], null, "childRow", [show, api.row(api[0])]);
              __details_events(ctx[0]);
              __details_state(ctx);
            }
          }
        };
        var __details_events = function(settings) {
          var api = new _Api(settings);
          var namespace = ".dt.DT_details";
          var drawEvent = "draw" + namespace;
          var colvisEvent = "column-visibility" + namespace;
          var destroyEvent = "destroy" + namespace;
          var data = settings.aoData;
          api.off(drawEvent + " " + colvisEvent + " " + destroyEvent);
          if (_pluck(data, "_details").length > 0) {
            api.on(drawEvent, function(e, ctx) {
              if (settings !== ctx) {
                return;
              }
              api.rows({ page: "current" }).eq(0).each(function(idx) {
                var row = data[idx];
                if (row._detailsShow) {
                  row._details.insertAfter(row.nTr);
                }
              });
            });
            api.on(colvisEvent, function(e, ctx, idx, vis) {
              if (settings !== ctx) {
                return;
              }
              var row, visible = _fnVisbleColumns(ctx);
              for (var i = 0, ien = data.length; i < ien; i++) {
                row = data[i];
                if (row._details) {
                  row._details.children("td[colspan]").attr("colspan", visible);
                }
              }
            });
            api.on(destroyEvent, function(e, ctx) {
              if (settings !== ctx) {
                return;
              }
              for (var i = 0, ien = data.length; i < ien; i++) {
                if (data[i]._details) {
                  __details_remove(api, i);
                }
              }
            });
          }
        };
        var _emp = "";
        var _child_obj = _emp + "row().child";
        var _child_mth = _child_obj + "()";
        _api_register(_child_mth, function(data, klass) {
          var ctx = this.context;
          if (data === undefined2) {
            return ctx.length && this.length ? ctx[0].aoData[this[0]]._details : undefined2;
          } else if (data === true) {
            this.child.show();
          } else if (data === false) {
            __details_remove(this);
          } else if (ctx.length && this.length) {
            __details_add(ctx[0], ctx[0].aoData[this[0]], data, klass);
          }
          return this;
        });
        _api_register([
          _child_obj + ".show()",
          _child_mth + ".show()"
        ], function(show) {
          __details_display(this, true);
          return this;
        });
        _api_register([
          _child_obj + ".hide()",
          _child_mth + ".hide()"
        ], function() {
          __details_display(this, false);
          return this;
        });
        _api_register([
          _child_obj + ".remove()",
          _child_mth + ".remove()"
        ], function() {
          __details_remove(this);
          return this;
        });
        _api_register(_child_obj + ".isShown()", function() {
          var ctx = this.context;
          if (ctx.length && this.length) {
            return ctx[0].aoData[this[0]]._detailsShow || false;
          }
          return false;
        });
        var __re_column_selector = /^([^:]+):(name|visIdx|visible)$/;
        var __columnData = function(settings, column, r1, r2, rows) {
          var a = [];
          for (var row = 0, ien = rows.length; row < ien; row++) {
            a.push(_fnGetCellData(settings, rows[row], column));
          }
          return a;
        };
        var __column_selector = function(settings, selector, opts) {
          var columns = settings.aoColumns, names = _pluck(columns, "sName"), nodes = _pluck(columns, "nTh");
          var run = function(s) {
            var selInt = _intVal(s);
            if (s === "") {
              return _range(columns.length);
            }
            if (selInt !== null) {
              return [
                selInt >= 0 ? selInt : columns.length + selInt
              ];
            }
            if (typeof s === "function") {
              var rows = _selector_row_indexes(settings, opts);
              return $2.map(columns, function(col, idx2) {
                return s(idx2, __columnData(settings, idx2, 0, 0, rows), nodes[idx2]) ? idx2 : null;
              });
            }
            var match = typeof s === "string" ? s.match(__re_column_selector) : "";
            if (match) {
              switch (match[2]) {
                case "visIdx":
                case "visible":
                  var idx = parseInt(match[1], 10);
                  if (idx < 0) {
                    var visColumns = $2.map(columns, function(col, i) {
                      return col.bVisible ? i : null;
                    });
                    return [visColumns[visColumns.length + idx]];
                  }
                  return [_fnVisibleToColumnIndex(settings, idx)];
                case "name":
                  return $2.map(names, function(name, i) {
                    return name === match[1] ? i : null;
                  });
                default:
                  return [];
              }
            }
            if (s.nodeName && s._DT_CellIndex) {
              return [s._DT_CellIndex.column];
            }
            var jqResult = $2(nodes).filter(s).map(function() {
              return $2.inArray(this, nodes);
            }).toArray();
            if (jqResult.length || !s.nodeName) {
              return jqResult;
            }
            var host = $2(s).closest("*[data-dt-column]");
            return host.length ? [host.data("dt-column")] : [];
          };
          return _selector_run("column", selector, run, settings, opts);
        };
        var __setColumnVis = function(settings, column, vis) {
          var cols = settings.aoColumns, col = cols[column], data = settings.aoData, row, cells, i, ien, tr;
          if (vis === undefined2) {
            return col.bVisible;
          }
          if (col.bVisible === vis) {
            return;
          }
          if (vis) {
            var insertBefore = $2.inArray(true, _pluck(cols, "bVisible"), column + 1);
            for (i = 0, ien = data.length; i < ien; i++) {
              tr = data[i].nTr;
              cells = data[i].anCells;
              if (tr) {
                tr.insertBefore(cells[column], cells[insertBefore] || null);
              }
            }
          } else {
            $2(_pluck(settings.aoData, "anCells", column)).detach();
          }
          col.bVisible = vis;
        };
        _api_register("columns()", function(selector, opts) {
          if (selector === undefined2) {
            selector = "";
          } else if ($2.isPlainObject(selector)) {
            opts = selector;
            selector = "";
          }
          opts = _selector_opts(opts);
          var inst = this.iterator("table", function(settings) {
            return __column_selector(settings, selector, opts);
          }, 1);
          inst.selector.cols = selector;
          inst.selector.opts = opts;
          return inst;
        });
        _api_registerPlural("columns().header()", "column().header()", function(selector, opts) {
          return this.iterator("column", function(settings, column) {
            return settings.aoColumns[column].nTh;
          }, 1);
        });
        _api_registerPlural("columns().footer()", "column().footer()", function(selector, opts) {
          return this.iterator("column", function(settings, column) {
            return settings.aoColumns[column].nTf;
          }, 1);
        });
        _api_registerPlural("columns().data()", "column().data()", function() {
          return this.iterator("column-rows", __columnData, 1);
        });
        _api_registerPlural("columns().dataSrc()", "column().dataSrc()", function() {
          return this.iterator("column", function(settings, column) {
            return settings.aoColumns[column].mData;
          }, 1);
        });
        _api_registerPlural("columns().cache()", "column().cache()", function(type) {
          return this.iterator("column-rows", function(settings, column, i, j, rows) {
            return _pluck_order(settings.aoData, rows, type === "search" ? "_aFilterData" : "_aSortData", column);
          }, 1);
        });
        _api_registerPlural("columns().nodes()", "column().nodes()", function() {
          return this.iterator("column-rows", function(settings, column, i, j, rows) {
            return _pluck_order(settings.aoData, rows, "anCells", column);
          }, 1);
        });
        _api_registerPlural("columns().visible()", "column().visible()", function(vis, calc) {
          var that = this;
          var ret = this.iterator("column", function(settings, column) {
            if (vis === undefined2) {
              return settings.aoColumns[column].bVisible;
            }
            __setColumnVis(settings, column, vis);
          });
          if (vis !== undefined2) {
            this.iterator("table", function(settings) {
              _fnDrawHead(settings, settings.aoHeader);
              _fnDrawHead(settings, settings.aoFooter);
              if (!settings.aiDisplay.length) {
                $2(settings.nTBody).find("td[colspan]").attr("colspan", _fnVisbleColumns(settings));
              }
              _fnSaveState(settings);
              that.iterator("column", function(settings2, column) {
                _fnCallbackFire(settings2, null, "column-visibility", [settings2, column, vis, calc]);
              });
              if (calc === undefined2 || calc) {
                that.columns.adjust();
              }
            });
          }
          return ret;
        });
        _api_registerPlural("columns().indexes()", "column().index()", function(type) {
          return this.iterator("column", function(settings, column) {
            return type === "visible" ? _fnColumnIndexToVisible(settings, column) : column;
          }, 1);
        });
        _api_register("columns.adjust()", function() {
          return this.iterator("table", function(settings) {
            _fnAdjustColumnSizing(settings);
          }, 1);
        });
        _api_register("column.index()", function(type, idx) {
          if (this.context.length !== 0) {
            var ctx = this.context[0];
            if (type === "fromVisible" || type === "toData") {
              return _fnVisibleToColumnIndex(ctx, idx);
            } else if (type === "fromData" || type === "toVisible") {
              return _fnColumnIndexToVisible(ctx, idx);
            }
          }
        });
        _api_register("column()", function(selector, opts) {
          return _selector_first(this.columns(selector, opts));
        });
        var __cell_selector = function(settings, selector, opts) {
          var data = settings.aoData;
          var rows = _selector_row_indexes(settings, opts);
          var cells = _removeEmpty(_pluck_order(data, rows, "anCells"));
          var allCells = $2(_flatten([], cells));
          var row;
          var columns = settings.aoColumns.length;
          var a, i, ien, j, o, host;
          var run = function(s) {
            var fnSelector = typeof s === "function";
            if (s === null || s === undefined2 || fnSelector) {
              a = [];
              for (i = 0, ien = rows.length; i < ien; i++) {
                row = rows[i];
                for (j = 0; j < columns; j++) {
                  o = {
                    row,
                    column: j
                  };
                  if (fnSelector) {
                    host = data[row];
                    if (s(o, _fnGetCellData(settings, row, j), host.anCells ? host.anCells[j] : null)) {
                      a.push(o);
                    }
                  } else {
                    a.push(o);
                  }
                }
              }
              return a;
            }
            if ($2.isPlainObject(s)) {
              return s.column !== undefined2 && s.row !== undefined2 && $2.inArray(s.row, rows) !== -1 ? [s] : [];
            }
            var jqResult = allCells.filter(s).map(function(i2, el) {
              return {
                row: el._DT_CellIndex.row,
                column: el._DT_CellIndex.column
              };
            }).toArray();
            if (jqResult.length || !s.nodeName) {
              return jqResult;
            }
            host = $2(s).closest("*[data-dt-row]");
            return host.length ? [{
              row: host.data("dt-row"),
              column: host.data("dt-column")
            }] : [];
          };
          return _selector_run("cell", selector, run, settings, opts);
        };
        _api_register("cells()", function(rowSelector, columnSelector, opts) {
          if ($2.isPlainObject(rowSelector)) {
            if (rowSelector.row === undefined2) {
              opts = rowSelector;
              rowSelector = null;
            } else {
              opts = columnSelector;
              columnSelector = null;
            }
          }
          if ($2.isPlainObject(columnSelector)) {
            opts = columnSelector;
            columnSelector = null;
          }
          if (columnSelector === null || columnSelector === undefined2) {
            return this.iterator("table", function(settings) {
              return __cell_selector(settings, rowSelector, _selector_opts(opts));
            });
          }
          var internalOpts = opts ? {
            page: opts.page,
            order: opts.order,
            search: opts.search
          } : {};
          var columns = this.columns(columnSelector, internalOpts);
          var rows = this.rows(rowSelector, internalOpts);
          var i, ien, j, jen;
          var cellsNoOpts = this.iterator("table", function(settings, idx) {
            var a = [];
            for (i = 0, ien = rows[idx].length; i < ien; i++) {
              for (j = 0, jen = columns[idx].length; j < jen; j++) {
                a.push({
                  row: rows[idx][i],
                  column: columns[idx][j]
                });
              }
            }
            return a;
          }, 1);
          var cells = opts && opts.selected ? this.cells(cellsNoOpts, opts) : cellsNoOpts;
          $2.extend(cells.selector, {
            cols: columnSelector,
            rows: rowSelector,
            opts
          });
          return cells;
        });
        _api_registerPlural("cells().nodes()", "cell().node()", function() {
          return this.iterator("cell", function(settings, row, column) {
            var data = settings.aoData[row];
            return data && data.anCells ? data.anCells[column] : undefined2;
          }, 1);
        });
        _api_register("cells().data()", function() {
          return this.iterator("cell", function(settings, row, column) {
            return _fnGetCellData(settings, row, column);
          }, 1);
        });
        _api_registerPlural("cells().cache()", "cell().cache()", function(type) {
          type = type === "search" ? "_aFilterData" : "_aSortData";
          return this.iterator("cell", function(settings, row, column) {
            return settings.aoData[row][type][column];
          }, 1);
        });
        _api_registerPlural("cells().render()", "cell().render()", function(type) {
          return this.iterator("cell", function(settings, row, column) {
            return _fnGetCellData(settings, row, column, type);
          }, 1);
        });
        _api_registerPlural("cells().indexes()", "cell().index()", function() {
          return this.iterator("cell", function(settings, row, column) {
            return {
              row,
              column,
              columnVisible: _fnColumnIndexToVisible(settings, column)
            };
          }, 1);
        });
        _api_registerPlural("cells().invalidate()", "cell().invalidate()", function(src) {
          return this.iterator("cell", function(settings, row, column) {
            _fnInvalidate(settings, row, src, column);
          });
        });
        _api_register("cell()", function(rowSelector, columnSelector, opts) {
          return _selector_first(this.cells(rowSelector, columnSelector, opts));
        });
        _api_register("cell().data()", function(data) {
          var ctx = this.context;
          var cell = this[0];
          if (data === undefined2) {
            return ctx.length && cell.length ? _fnGetCellData(ctx[0], cell[0].row, cell[0].column) : undefined2;
          }
          _fnSetCellData(ctx[0], cell[0].row, cell[0].column, data);
          _fnInvalidate(ctx[0], cell[0].row, "data", cell[0].column);
          return this;
        });
        _api_register("order()", function(order, dir) {
          var ctx = this.context;
          if (order === undefined2) {
            return ctx.length !== 0 ? ctx[0].aaSorting : undefined2;
          }
          if (typeof order === "number") {
            order = [[order, dir]];
          } else if (order.length && !Array.isArray(order[0])) {
            order = Array.prototype.slice.call(arguments);
          }
          return this.iterator("table", function(settings) {
            settings.aaSorting = order.slice();
          });
        });
        _api_register("order.listener()", function(node, column, callback) {
          return this.iterator("table", function(settings) {
            _fnSortAttachListener(settings, node, column, callback);
          });
        });
        _api_register("order.fixed()", function(set) {
          if (!set) {
            var ctx = this.context;
            var fixed = ctx.length ? ctx[0].aaSortingFixed : undefined2;
            return Array.isArray(fixed) ? { pre: fixed } : fixed;
          }
          return this.iterator("table", function(settings) {
            settings.aaSortingFixed = $2.extend(true, {}, set);
          });
        });
        _api_register([
          "columns().order()",
          "column().order()"
        ], function(dir) {
          var that = this;
          return this.iterator("table", function(settings, i) {
            var sort = [];
            $2.each(that[i], function(j, col) {
              sort.push([col, dir]);
            });
            settings.aaSorting = sort;
          });
        });
        _api_register("search()", function(input, regex, smart, caseInsen) {
          var ctx = this.context;
          if (input === undefined2) {
            return ctx.length !== 0 ? ctx[0].oPreviousSearch.sSearch : undefined2;
          }
          return this.iterator("table", function(settings) {
            if (!settings.oFeatures.bFilter) {
              return;
            }
            _fnFilterComplete(settings, $2.extend({}, settings.oPreviousSearch, {
              "sSearch": input + "",
              "bRegex": regex === null ? false : regex,
              "bSmart": smart === null ? true : smart,
              "bCaseInsensitive": caseInsen === null ? true : caseInsen
            }), 1);
          });
        });
        _api_registerPlural("columns().search()", "column().search()", function(input, regex, smart, caseInsen) {
          return this.iterator("column", function(settings, column) {
            var preSearch = settings.aoPreSearchCols;
            if (input === undefined2) {
              return preSearch[column].sSearch;
            }
            if (!settings.oFeatures.bFilter) {
              return;
            }
            $2.extend(preSearch[column], {
              "sSearch": input + "",
              "bRegex": regex === null ? false : regex,
              "bSmart": smart === null ? true : smart,
              "bCaseInsensitive": caseInsen === null ? true : caseInsen
            });
            _fnFilterComplete(settings, settings.oPreviousSearch, 1);
          });
        });
        _api_register("state()", function() {
          return this.context.length ? this.context[0].oSavedState : null;
        });
        _api_register("state.clear()", function() {
          return this.iterator("table", function(settings) {
            settings.fnStateSaveCallback.call(settings.oInstance, settings, {});
          });
        });
        _api_register("state.loaded()", function() {
          return this.context.length ? this.context[0].oLoadedState : null;
        });
        _api_register("state.save()", function() {
          return this.iterator("table", function(settings) {
            _fnSaveState(settings);
          });
        });
        DataTable.versionCheck = DataTable.fnVersionCheck = function(version) {
          var aThis = DataTable.version.split(".");
          var aThat = version.split(".");
          var iThis, iThat;
          for (var i = 0, iLen = aThat.length; i < iLen; i++) {
            iThis = parseInt(aThis[i], 10) || 0;
            iThat = parseInt(aThat[i], 10) || 0;
            if (iThis === iThat) {
              continue;
            }
            return iThis > iThat;
          }
          return true;
        };
        DataTable.isDataTable = DataTable.fnIsDataTable = function(table) {
          var t = $2(table).get(0);
          var is = false;
          if (table instanceof DataTable.Api) {
            return true;
          }
          $2.each(DataTable.settings, function(i, o) {
            var head = o.nScrollHead ? $2("table", o.nScrollHead)[0] : null;
            var foot = o.nScrollFoot ? $2("table", o.nScrollFoot)[0] : null;
            if (o.nTable === t || head === t || foot === t) {
              is = true;
            }
          });
          return is;
        };
        DataTable.tables = DataTable.fnTables = function(visible) {
          var api = false;
          if ($2.isPlainObject(visible)) {
            api = visible.api;
            visible = visible.visible;
          }
          var a = $2.map(DataTable.settings, function(o) {
            if (!visible || visible && $2(o.nTable).is(":visible")) {
              return o.nTable;
            }
          });
          return api ? new _Api(a) : a;
        };
        DataTable.camelToHungarian = _fnCamelToHungarian;
        _api_register("$()", function(selector, opts) {
          var rows = this.rows(opts).nodes(), jqRows = $2(rows);
          return $2([].concat(jqRows.filter(selector).toArray(), jqRows.find(selector).toArray()));
        });
        $2.each(["on", "one", "off"], function(i, key) {
          _api_register(key + "()", function() {
            var args = Array.prototype.slice.call(arguments);
            args[0] = $2.map(args[0].split(/\s/), function(e) {
              return !e.match(/\.dt\b/) ? e + ".dt" : e;
            }).join(" ");
            var inst = $2(this.tables().nodes());
            inst[key].apply(inst, args);
            return this;
          });
        });
        _api_register("clear()", function() {
          return this.iterator("table", function(settings) {
            _fnClearTable(settings);
          });
        });
        _api_register("settings()", function() {
          return new _Api(this.context, this.context);
        });
        _api_register("init()", function() {
          var ctx = this.context;
          return ctx.length ? ctx[0].oInit : null;
        });
        _api_register("data()", function() {
          return this.iterator("table", function(settings) {
            return _pluck(settings.aoData, "_aData");
          }).flatten();
        });
        _api_register("destroy()", function(remove) {
          remove = remove || false;
          return this.iterator("table", function(settings) {
            var orig = settings.nTableWrapper.parentNode;
            var classes = settings.oClasses;
            var table = settings.nTable;
            var tbody = settings.nTBody;
            var thead = settings.nTHead;
            var tfoot = settings.nTFoot;
            var jqTable = $2(table);
            var jqTbody = $2(tbody);
            var jqWrapper = $2(settings.nTableWrapper);
            var rows = $2.map(settings.aoData, function(r) {
              return r.nTr;
            });
            var i, ien;
            settings.bDestroying = true;
            _fnCallbackFire(settings, "aoDestroyCallback", "destroy", [settings]);
            if (!remove) {
              new _Api(settings).columns().visible(true);
            }
            jqWrapper.off(".DT").find(":not(tbody *)").off(".DT");
            $2(window2).off(".DT-" + settings.sInstance);
            if (table != thead.parentNode) {
              jqTable.children("thead").detach();
              jqTable.append(thead);
            }
            if (tfoot && table != tfoot.parentNode) {
              jqTable.children("tfoot").detach();
              jqTable.append(tfoot);
            }
            settings.aaSorting = [];
            settings.aaSortingFixed = [];
            _fnSortingClasses(settings);
            $2(rows).removeClass(settings.asStripeClasses.join(" "));
            $2("th, td", thead).removeClass(classes.sSortable + " " + classes.sSortableAsc + " " + classes.sSortableDesc + " " + classes.sSortableNone);
            jqTbody.children().detach();
            jqTbody.append(rows);
            var removedMethod = remove ? "remove" : "detach";
            jqTable[removedMethod]();
            jqWrapper[removedMethod]();
            if (!remove && orig) {
              orig.insertBefore(table, settings.nTableReinsertBefore);
              jqTable.css("width", settings.sDestroyWidth).removeClass(classes.sTable);
              ien = settings.asDestroyStripes.length;
              if (ien) {
                jqTbody.children().each(function(i2) {
                  $2(this).addClass(settings.asDestroyStripes[i2 % ien]);
                });
              }
            }
            var idx = $2.inArray(settings, DataTable.settings);
            if (idx !== -1) {
              DataTable.settings.splice(idx, 1);
            }
          });
        });
        $2.each(["column", "row", "cell"], function(i, type) {
          _api_register(type + "s().every()", function(fn) {
            var opts = this.selector.opts;
            var api = this;
            return this.iterator(type, function(settings, arg1, arg2, arg3, arg4) {
              fn.call(api[type](arg1, type === "cell" ? arg2 : opts, type === "cell" ? opts : undefined2), arg1, arg2, arg3, arg4);
            });
          });
        });
        _api_register("i18n()", function(token, def, plural) {
          var ctx = this.context[0];
          var resolved = _fnGetObjectDataFn(token)(ctx.oLanguage);
          if (resolved === undefined2) {
            resolved = def;
          }
          if (plural !== undefined2 && $2.isPlainObject(resolved)) {
            resolved = resolved[plural] !== undefined2 ? resolved[plural] : resolved._;
          }
          return resolved.replace("%d", plural);
        });
        DataTable.version = "1.11.5";
        DataTable.settings = [];
        DataTable.models = {};
        DataTable.models.oSearch = {
          "bCaseInsensitive": true,
          "sSearch": "",
          "bRegex": false,
          "bSmart": true,
          "return": false
        };
        DataTable.models.oRow = {
          "nTr": null,
          "anCells": null,
          "_aData": [],
          "_aSortData": null,
          "_aFilterData": null,
          "_sFilterRow": null,
          "_sRowStripe": "",
          "src": null,
          "idx": -1
        };
        DataTable.models.oColumn = {
          "idx": null,
          "aDataSort": null,
          "asSorting": null,
          "bSearchable": null,
          "bSortable": null,
          "bVisible": null,
          "_sManualType": null,
          "_bAttrSrc": false,
          "fnCreatedCell": null,
          "fnGetData": null,
          "fnSetData": null,
          "mData": null,
          "mRender": null,
          "nTh": null,
          "nTf": null,
          "sClass": null,
          "sContentPadding": null,
          "sDefaultContent": null,
          "sName": null,
          "sSortDataType": "std",
          "sSortingClass": null,
          "sSortingClassJUI": null,
          "sTitle": null,
          "sType": null,
          "sWidth": null,
          "sWidthOrig": null
        };
        DataTable.defaults = {
          "aaData": null,
          "aaSorting": [[0, "asc"]],
          "aaSortingFixed": [],
          "ajax": null,
          "aLengthMenu": [10, 25, 50, 100],
          "aoColumns": null,
          "aoColumnDefs": null,
          "aoSearchCols": [],
          "asStripeClasses": null,
          "bAutoWidth": true,
          "bDeferRender": false,
          "bDestroy": false,
          "bFilter": true,
          "bInfo": true,
          "bLengthChange": true,
          "bPaginate": true,
          "bProcessing": false,
          "bRetrieve": false,
          "bScrollCollapse": false,
          "bServerSide": false,
          "bSort": true,
          "bSortMulti": true,
          "bSortCellsTop": false,
          "bSortClasses": true,
          "bStateSave": false,
          "fnCreatedRow": null,
          "fnDrawCallback": null,
          "fnFooterCallback": null,
          "fnFormatNumber": function(toFormat) {
            return toFormat.toString().replace(/\B(?=(\d{3})+(?!\d))/g, this.oLanguage.sThousands);
          },
          "fnHeaderCallback": null,
          "fnInfoCallback": null,
          "fnInitComplete": null,
          "fnPreDrawCallback": null,
          "fnRowCallback": null,
          "fnServerData": null,
          "fnServerParams": null,
          "fnStateLoadCallback": function(settings) {
            try {
              return JSON.parse((settings.iStateDuration === -1 ? sessionStorage : localStorage).getItem("DataTables_" + settings.sInstance + "_" + location.pathname));
            } catch (e) {
              return {};
            }
          },
          "fnStateLoadParams": null,
          "fnStateLoaded": null,
          "fnStateSaveCallback": function(settings, data) {
            try {
              (settings.iStateDuration === -1 ? sessionStorage : localStorage).setItem("DataTables_" + settings.sInstance + "_" + location.pathname, JSON.stringify(data));
            } catch (e) {
            }
          },
          "fnStateSaveParams": null,
          "iStateDuration": 7200,
          "iDeferLoading": null,
          "iDisplayLength": 10,
          "iDisplayStart": 0,
          "iTabIndex": 0,
          "oClasses": {},
          "oLanguage": {
            "oAria": {
              "sSortAscending": ": activate to sort column ascending",
              "sSortDescending": ": activate to sort column descending"
            },
            "oPaginate": {
              "sFirst": "First",
              "sLast": "Last",
              "sNext": "Next",
              "sPrevious": "Previous"
            },
            "sEmptyTable": "No data available in table",
            "sInfo": "Showing _START_ to _END_ of _TOTAL_ entries",
            "sInfoEmpty": "Showing 0 to 0 of 0 entries",
            "sInfoFiltered": "(filtered from _MAX_ total entries)",
            "sInfoPostFix": "",
            "sDecimal": "",
            "sThousands": ",",
            "sLengthMenu": "Show _MENU_ entries",
            "sLoadingRecords": "Loading...",
            "sProcessing": "Processing...",
            "sSearch": "Search:",
            "sSearchPlaceholder": "",
            "sUrl": "",
            "sZeroRecords": "No matching records found"
          },
          "oSearch": $2.extend({}, DataTable.models.oSearch),
          "sAjaxDataProp": "data",
          "sAjaxSource": null,
          "sDom": "lfrtip",
          "searchDelay": null,
          "sPaginationType": "simple_numbers",
          "sScrollX": "",
          "sScrollXInner": "",
          "sScrollY": "",
          "sServerMethod": "GET",
          "renderer": null,
          "rowId": "DT_RowId"
        };
        _fnHungarianMap(DataTable.defaults);
        DataTable.defaults.column = {
          "aDataSort": null,
          "iDataSort": -1,
          "asSorting": ["asc", "desc"],
          "bSearchable": true,
          "bSortable": true,
          "bVisible": true,
          "fnCreatedCell": null,
          "mData": null,
          "mRender": null,
          "sCellType": "td",
          "sClass": "",
          "sContentPadding": "",
          "sDefaultContent": null,
          "sName": "",
          "sSortDataType": "std",
          "sTitle": null,
          "sType": null,
          "sWidth": null
        };
        _fnHungarianMap(DataTable.defaults.column);
        DataTable.models.oSettings = {
          "oFeatures": {
            "bAutoWidth": null,
            "bDeferRender": null,
            "bFilter": null,
            "bInfo": null,
            "bLengthChange": null,
            "bPaginate": null,
            "bProcessing": null,
            "bServerSide": null,
            "bSort": null,
            "bSortMulti": null,
            "bSortClasses": null,
            "bStateSave": null
          },
          "oScroll": {
            "bCollapse": null,
            "iBarWidth": 0,
            "sX": null,
            "sXInner": null,
            "sY": null
          },
          "oLanguage": {
            "fnInfoCallback": null
          },
          "oBrowser": {
            "bScrollOversize": false,
            "bScrollbarLeft": false,
            "bBounding": false,
            "barWidth": 0
          },
          "ajax": null,
          "aanFeatures": [],
          "aoData": [],
          "aiDisplay": [],
          "aiDisplayMaster": [],
          "aIds": {},
          "aoColumns": [],
          "aoHeader": [],
          "aoFooter": [],
          "oPreviousSearch": {},
          "aoPreSearchCols": [],
          "aaSorting": null,
          "aaSortingFixed": [],
          "asStripeClasses": null,
          "asDestroyStripes": [],
          "sDestroyWidth": 0,
          "aoRowCallback": [],
          "aoHeaderCallback": [],
          "aoFooterCallback": [],
          "aoDrawCallback": [],
          "aoRowCreatedCallback": [],
          "aoPreDrawCallback": [],
          "aoInitComplete": [],
          "aoStateSaveParams": [],
          "aoStateLoadParams": [],
          "aoStateLoaded": [],
          "sTableId": "",
          "nTable": null,
          "nTHead": null,
          "nTFoot": null,
          "nTBody": null,
          "nTableWrapper": null,
          "bDeferLoading": false,
          "bInitialised": false,
          "aoOpenRows": [],
          "sDom": null,
          "searchDelay": null,
          "sPaginationType": "two_button",
          "iStateDuration": 0,
          "aoStateSave": [],
          "aoStateLoad": [],
          "oSavedState": null,
          "oLoadedState": null,
          "sAjaxSource": null,
          "sAjaxDataProp": null,
          "jqXHR": null,
          "json": undefined2,
          "oAjaxData": undefined2,
          "fnServerData": null,
          "aoServerParams": [],
          "sServerMethod": null,
          "fnFormatNumber": null,
          "aLengthMenu": null,
          "iDraw": 0,
          "bDrawing": false,
          "iDrawError": -1,
          "_iDisplayLength": 10,
          "_iDisplayStart": 0,
          "_iRecordsTotal": 0,
          "_iRecordsDisplay": 0,
          "oClasses": {},
          "bFiltered": false,
          "bSorted": false,
          "bSortCellsTop": null,
          "oInit": null,
          "aoDestroyCallback": [],
          "fnRecordsTotal": function() {
            return _fnDataSource(this) == "ssp" ? this._iRecordsTotal * 1 : this.aiDisplayMaster.length;
          },
          "fnRecordsDisplay": function() {
            return _fnDataSource(this) == "ssp" ? this._iRecordsDisplay * 1 : this.aiDisplay.length;
          },
          "fnDisplayEnd": function() {
            var len = this._iDisplayLength, start = this._iDisplayStart, calc = start + len, records = this.aiDisplay.length, features = this.oFeatures, paginate = features.bPaginate;
            if (features.bServerSide) {
              return paginate === false || len === -1 ? start + records : Math.min(start + len, this._iRecordsDisplay);
            } else {
              return !paginate || calc > records || len === -1 ? records : calc;
            }
          },
          "oInstance": null,
          "sInstance": null,
          "iTabIndex": 0,
          "nScrollHead": null,
          "nScrollFoot": null,
          "aLastSort": [],
          "oPlugins": {},
          "rowIdFn": null,
          "rowId": null
        };
        DataTable.ext = _ext = {
          buttons: {},
          classes: {},
          builder: "-source-",
          errMode: "alert",
          feature: [],
          search: [],
          selector: {
            cell: [],
            column: [],
            row: []
          },
          internal: {},
          legacy: {
            ajax: null
          },
          pager: {},
          renderer: {
            pageButton: {},
            header: {}
          },
          order: {},
          type: {
            detect: [],
            search: {},
            order: {}
          },
          _unique: 0,
          fnVersionCheck: DataTable.fnVersionCheck,
          iApiIndex: 0,
          oJUIClasses: {},
          sVersion: DataTable.version
        };
        $2.extend(_ext, {
          afnFiltering: _ext.search,
          aTypes: _ext.type.detect,
          ofnSearch: _ext.type.search,
          oSort: _ext.type.order,
          afnSortData: _ext.order,
          aoFeatures: _ext.feature,
          oApi: _ext.internal,
          oStdClasses: _ext.classes,
          oPagination: _ext.pager
        });
        $2.extend(DataTable.ext.classes, {
          "sTable": "dataTable",
          "sNoFooter": "no-footer",
          "sPageButton": "paginate_button",
          "sPageButtonActive": "current",
          "sPageButtonDisabled": "disabled",
          "sStripeOdd": "odd",
          "sStripeEven": "even",
          "sRowEmpty": "dataTables_empty",
          "sWrapper": "dataTables_wrapper",
          "sFilter": "dataTables_filter",
          "sInfo": "dataTables_info",
          "sPaging": "dataTables_paginate paging_",
          "sLength": "dataTables_length",
          "sProcessing": "dataTables_processing",
          "sSortAsc": "sorting_asc",
          "sSortDesc": "sorting_desc",
          "sSortable": "sorting",
          "sSortableAsc": "sorting_desc_disabled",
          "sSortableDesc": "sorting_asc_disabled",
          "sSortableNone": "sorting_disabled",
          "sSortColumn": "sorting_",
          "sFilterInput": "",
          "sLengthSelect": "",
          "sScrollWrapper": "dataTables_scroll",
          "sScrollHead": "dataTables_scrollHead",
          "sScrollHeadInner": "dataTables_scrollHeadInner",
          "sScrollBody": "dataTables_scrollBody",
          "sScrollFoot": "dataTables_scrollFoot",
          "sScrollFootInner": "dataTables_scrollFootInner",
          "sHeaderTH": "",
          "sFooterTH": "",
          "sSortJUIAsc": "",
          "sSortJUIDesc": "",
          "sSortJUI": "",
          "sSortJUIAscAllowed": "",
          "sSortJUIDescAllowed": "",
          "sSortJUIWrapper": "",
          "sSortIcon": "",
          "sJUIHeader": "",
          "sJUIFooter": ""
        });
        var extPagination = DataTable.ext.pager;
        function _numbers(page, pages) {
          var numbers = [], buttons = extPagination.numbers_length, half = Math.floor(buttons / 2), i = 1;
          if (pages <= buttons) {
            numbers = _range(0, pages);
          } else if (page <= half) {
            numbers = _range(0, buttons - 2);
            numbers.push("ellipsis");
            numbers.push(pages - 1);
          } else if (page >= pages - 1 - half) {
            numbers = _range(pages - (buttons - 2), pages);
            numbers.splice(0, 0, "ellipsis");
            numbers.splice(0, 0, 0);
          } else {
            numbers = _range(page - half + 2, page + half - 1);
            numbers.push("ellipsis");
            numbers.push(pages - 1);
            numbers.splice(0, 0, "ellipsis");
            numbers.splice(0, 0, 0);
          }
          numbers.DT_el = "span";
          return numbers;
        }
        $2.extend(extPagination, {
          simple: function(page, pages) {
            return ["previous", "next"];
          },
          full: function(page, pages) {
            return ["first", "previous", "next", "last"];
          },
          numbers: function(page, pages) {
            return [_numbers(page, pages)];
          },
          simple_numbers: function(page, pages) {
            return ["previous", _numbers(page, pages), "next"];
          },
          full_numbers: function(page, pages) {
            return ["first", "previous", _numbers(page, pages), "next", "last"];
          },
          first_last_numbers: function(page, pages) {
            return ["first", _numbers(page, pages), "last"];
          },
          _numbers,
          numbers_length: 7
        });
        $2.extend(true, DataTable.ext.renderer, {
          pageButton: {
            _: function(settings, host, idx, buttons, page, pages) {
              var classes = settings.oClasses;
              var lang = settings.oLanguage.oPaginate;
              var aria = settings.oLanguage.oAria.paginate || {};
              var btnDisplay, btnClass, counter = 0;
              var attach = function(container, buttons2) {
                var i, ien, node, button, tabIndex;
                var disabledClass = classes.sPageButtonDisabled;
                var clickHandler = function(e) {
                  _fnPageChange(settings, e.data.action, true);
                };
                for (i = 0, ien = buttons2.length; i < ien; i++) {
                  button = buttons2[i];
                  if (Array.isArray(button)) {
                    var inner = $2("<" + (button.DT_el || "div") + "/>").appendTo(container);
                    attach(inner, button);
                  } else {
                    btnDisplay = null;
                    btnClass = button;
                    tabIndex = settings.iTabIndex;
                    switch (button) {
                      case "ellipsis":
                        container.append('<span class="ellipsis">&#x2026;</span>');
                        break;
                      case "first":
                        btnDisplay = lang.sFirst;
                        if (page === 0) {
                          tabIndex = -1;
                          btnClass += " " + disabledClass;
                        }
                        break;
                      case "previous":
                        btnDisplay = lang.sPrevious;
                        if (page === 0) {
                          tabIndex = -1;
                          btnClass += " " + disabledClass;
                        }
                        break;
                      case "next":
                        btnDisplay = lang.sNext;
                        if (pages === 0 || page === pages - 1) {
                          tabIndex = -1;
                          btnClass += " " + disabledClass;
                        }
                        break;
                      case "last":
                        btnDisplay = lang.sLast;
                        if (pages === 0 || page === pages - 1) {
                          tabIndex = -1;
                          btnClass += " " + disabledClass;
                        }
                        break;
                      default:
                        btnDisplay = settings.fnFormatNumber(button + 1);
                        btnClass = page === button ? classes.sPageButtonActive : "";
                        break;
                    }
                    if (btnDisplay !== null) {
                      node = $2("<a>", {
                        "class": classes.sPageButton + " " + btnClass,
                        "aria-controls": settings.sTableId,
                        "aria-label": aria[button],
                        "data-dt-idx": counter,
                        "tabindex": tabIndex,
                        "id": idx === 0 && typeof button === "string" ? settings.sTableId + "_" + button : null
                      }).html(btnDisplay).appendTo(container);
                      _fnBindAction(node, { action: button }, clickHandler);
                      counter++;
                    }
                  }
                }
              };
              var activeEl;
              try {
                activeEl = $2(host).find(document2.activeElement).data("dt-idx");
              } catch (e) {
              }
              attach($2(host).empty(), buttons);
              if (activeEl !== undefined2) {
                $2(host).find("[data-dt-idx=" + activeEl + "]").trigger("focus");
              }
            }
          }
        });
        $2.extend(DataTable.ext.type.detect, [
          function(d, settings) {
            var decimal = settings.oLanguage.sDecimal;
            return _isNumber(d, decimal) ? "num" + decimal : null;
          },
          function(d, settings) {
            if (d && !(d instanceof Date) && !_re_date.test(d)) {
              return null;
            }
            var parsed = Date.parse(d);
            return parsed !== null && !isNaN(parsed) || _empty(d) ? "date" : null;
          },
          function(d, settings) {
            var decimal = settings.oLanguage.sDecimal;
            return _isNumber(d, decimal, true) ? "num-fmt" + decimal : null;
          },
          function(d, settings) {
            var decimal = settings.oLanguage.sDecimal;
            return _htmlNumeric(d, decimal) ? "html-num" + decimal : null;
          },
          function(d, settings) {
            var decimal = settings.oLanguage.sDecimal;
            return _htmlNumeric(d, decimal, true) ? "html-num-fmt" + decimal : null;
          },
          function(d, settings) {
            return _empty(d) || typeof d === "string" && d.indexOf("<") !== -1 ? "html" : null;
          }
        ]);
        $2.extend(DataTable.ext.type.search, {
          html: function(data) {
            return _empty(data) ? data : typeof data === "string" ? data.replace(_re_new_lines, " ").replace(_re_html, "") : "";
          },
          string: function(data) {
            return _empty(data) ? data : typeof data === "string" ? data.replace(_re_new_lines, " ") : data;
          }
        });
        var __numericReplace = function(d, decimalPlace, re1, re2) {
          if (d !== 0 && (!d || d === "-")) {
            return -Infinity;
          }
          if (decimalPlace) {
            d = _numToDecimal(d, decimalPlace);
          }
          if (d.replace) {
            if (re1) {
              d = d.replace(re1, "");
            }
            if (re2) {
              d = d.replace(re2, "");
            }
          }
          return d * 1;
        };
        function _addNumericSort(decimalPlace) {
          $2.each({
            "num": function(d) {
              return __numericReplace(d, decimalPlace);
            },
            "num-fmt": function(d) {
              return __numericReplace(d, decimalPlace, _re_formatted_numeric);
            },
            "html-num": function(d) {
              return __numericReplace(d, decimalPlace, _re_html);
            },
            "html-num-fmt": function(d) {
              return __numericReplace(d, decimalPlace, _re_html, _re_formatted_numeric);
            }
          }, function(key, fn) {
            _ext.type.order[key + decimalPlace + "-pre"] = fn;
            if (key.match(/^html\-/)) {
              _ext.type.search[key + decimalPlace] = _ext.type.search.html;
            }
          });
        }
        $2.extend(_ext.type.order, {
          "date-pre": function(d) {
            var ts = Date.parse(d);
            return isNaN(ts) ? -Infinity : ts;
          },
          "html-pre": function(a) {
            return _empty(a) ? "" : a.replace ? a.replace(/<.*?>/g, "").toLowerCase() : a + "";
          },
          "string-pre": function(a) {
            return _empty(a) ? "" : typeof a === "string" ? a.toLowerCase() : !a.toString ? "" : a.toString();
          },
          "string-asc": function(x, y) {
            return x < y ? -1 : x > y ? 1 : 0;
          },
          "string-desc": function(x, y) {
            return x < y ? 1 : x > y ? -1 : 0;
          }
        });
        _addNumericSort("");
        $2.extend(true, DataTable.ext.renderer, {
          header: {
            _: function(settings, cell, column, classes) {
              $2(settings.nTable).on("order.dt.DT", function(e, ctx, sorting, columns) {
                if (settings !== ctx) {
                  return;
                }
                var colIdx = column.idx;
                cell.removeClass(classes.sSortAsc + " " + classes.sSortDesc).addClass(columns[colIdx] == "asc" ? classes.sSortAsc : columns[colIdx] == "desc" ? classes.sSortDesc : column.sSortingClass);
              });
            },
            jqueryui: function(settings, cell, column, classes) {
              $2("<div/>").addClass(classes.sSortJUIWrapper).append(cell.contents()).append($2("<span/>").addClass(classes.sSortIcon + " " + column.sSortingClassJUI)).appendTo(cell);
              $2(settings.nTable).on("order.dt.DT", function(e, ctx, sorting, columns) {
                if (settings !== ctx) {
                  return;
                }
                var colIdx = column.idx;
                cell.removeClass(classes.sSortAsc + " " + classes.sSortDesc).addClass(columns[colIdx] == "asc" ? classes.sSortAsc : columns[colIdx] == "desc" ? classes.sSortDesc : column.sSortingClass);
                cell.find("span." + classes.sSortIcon).removeClass(classes.sSortJUIAsc + " " + classes.sSortJUIDesc + " " + classes.sSortJUI + " " + classes.sSortJUIAscAllowed + " " + classes.sSortJUIDescAllowed).addClass(columns[colIdx] == "asc" ? classes.sSortJUIAsc : columns[colIdx] == "desc" ? classes.sSortJUIDesc : column.sSortingClassJUI);
              });
            }
          }
        });
        var __htmlEscapeEntities = function(d) {
          if (Array.isArray(d)) {
            d = d.join(",");
          }
          return typeof d === "string" ? d.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;") : d;
        };
        DataTable.render = {
          number: function(thousands, decimal, precision, prefix, postfix) {
            return {
              display: function(d) {
                if (typeof d !== "number" && typeof d !== "string") {
                  return d;
                }
                var negative = d < 0 ? "-" : "";
                var flo = parseFloat(d);
                if (isNaN(flo)) {
                  return __htmlEscapeEntities(d);
                }
                flo = flo.toFixed(precision);
                d = Math.abs(flo);
                var intPart = parseInt(d, 10);
                var floatPart = precision ? decimal + (d - intPart).toFixed(precision).substring(2) : "";
                if (intPart === 0 && parseFloat(floatPart) === 0) {
                  negative = "";
                }
                return negative + (prefix || "") + intPart.toString().replace(/\B(?=(\d{3})+(?!\d))/g, thousands) + floatPart + (postfix || "");
              }
            };
          },
          text: function() {
            return {
              display: __htmlEscapeEntities,
              filter: __htmlEscapeEntities
            };
          }
        };
        function _fnExternApiFunc(fn) {
          return function() {
            var args = [_fnSettingsFromNode(this[DataTable.ext.iApiIndex])].concat(Array.prototype.slice.call(arguments));
            return DataTable.ext.internal[fn].apply(this, args);
          };
        }
        $2.extend(DataTable.ext.internal, {
          _fnExternApiFunc,
          _fnBuildAjax,
          _fnAjaxUpdate,
          _fnAjaxParameters,
          _fnAjaxUpdateDraw,
          _fnAjaxDataSrc,
          _fnAddColumn,
          _fnColumnOptions,
          _fnAdjustColumnSizing,
          _fnVisibleToColumnIndex,
          _fnColumnIndexToVisible,
          _fnVisbleColumns,
          _fnGetColumns,
          _fnColumnTypes,
          _fnApplyColumnDefs,
          _fnHungarianMap,
          _fnCamelToHungarian,
          _fnLanguageCompat,
          _fnBrowserDetect,
          _fnAddData,
          _fnAddTr,
          _fnNodeToDataIndex,
          _fnNodeToColumnIndex,
          _fnGetCellData,
          _fnSetCellData,
          _fnSplitObjNotation,
          _fnGetObjectDataFn,
          _fnSetObjectDataFn,
          _fnGetDataMaster,
          _fnClearTable,
          _fnDeleteIndex,
          _fnInvalidate,
          _fnGetRowElements,
          _fnCreateTr,
          _fnBuildHead,
          _fnDrawHead,
          _fnDraw,
          _fnReDraw,
          _fnAddOptionsHtml,
          _fnDetectHeader,
          _fnGetUniqueThs,
          _fnFeatureHtmlFilter,
          _fnFilterComplete,
          _fnFilterCustom,
          _fnFilterColumn,
          _fnFilter,
          _fnFilterCreateSearch,
          _fnEscapeRegex,
          _fnFilterData,
          _fnFeatureHtmlInfo,
          _fnUpdateInfo,
          _fnInfoMacros,
          _fnInitialise,
          _fnInitComplete,
          _fnLengthChange,
          _fnFeatureHtmlLength,
          _fnFeatureHtmlPaginate,
          _fnPageChange,
          _fnFeatureHtmlProcessing,
          _fnProcessingDisplay,
          _fnFeatureHtmlTable,
          _fnScrollDraw,
          _fnApplyToChildren,
          _fnCalculateColumnWidths,
          _fnThrottle,
          _fnConvertToWidth,
          _fnGetWidestNode,
          _fnGetMaxLenString,
          _fnStringToCss,
          _fnSortFlatten,
          _fnSort,
          _fnSortAria,
          _fnSortListener,
          _fnSortAttachListener,
          _fnSortingClasses,
          _fnSortData,
          _fnSaveState,
          _fnLoadState,
          _fnImplementState,
          _fnSettingsFromNode,
          _fnLog,
          _fnMap,
          _fnBindAction,
          _fnCallbackReg,
          _fnCallbackFire,
          _fnLengthOverflow,
          _fnRenderer,
          _fnDataSource,
          _fnRowAttributes,
          _fnExtend,
          _fnCalculateEnd: function() {
          }
        });
        $2.fn.dataTable = DataTable;
        DataTable.$ = $2;
        $2.fn.dataTableSettings = DataTable.settings;
        $2.fn.dataTableExt = DataTable.ext;
        $2.fn.DataTable = function(opts) {
          return $2(this).dataTable(opts).api();
        };
        $2.each(DataTable, function(prop, val) {
          $2.fn.DataTable[prop] = val;
        });
        return DataTable;
      });
    }
  });

  // node_modules/datatables.net-bs4/js/dataTables.bootstrap4.js
  var require_dataTables_bootstrap4 = __commonJS({
    "node_modules/datatables.net-bs4/js/dataTables.bootstrap4.js"(exports, module) {
      (function(factory) {
        if (typeof define === "function" && define.amd) {
          define(["jquery", "datatables.net"], function($2) {
            return factory($2, window, document);
          });
        } else if (typeof exports === "object") {
          module.exports = function(root, $2) {
            if (!root) {
              root = window;
            }
            if (!$2 || !$2.fn.dataTable) {
              $2 = require_jquery_dataTables()(root, $2).$;
            }
            return factory($2, root, root.document);
          };
        } else {
          factory(jQuery, window, document);
        }
      })(function($2, window2, document2, undefined2) {
        "use strict";
        var DataTable = $2.fn.dataTable;
        $2.extend(true, DataTable.defaults, {
          dom: "<'row'<'col-sm-12 col-md-6'l><'col-sm-12 col-md-6'f>><'row'<'col-sm-12'tr>><'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7'p>>",
          renderer: "bootstrap"
        });
        $2.extend(DataTable.ext.classes, {
          sWrapper: "dataTables_wrapper dt-bootstrap4",
          sFilterInput: "form-control form-control-sm",
          sLengthSelect: "custom-select custom-select-sm form-control form-control-sm",
          sProcessing: "dataTables_processing card",
          sPageButton: "paginate_button page-item"
        });
        DataTable.ext.renderer.pageButton.bootstrap = function(settings, host, idx, buttons, page, pages) {
          var api = new DataTable.Api(settings);
          var classes = settings.oClasses;
          var lang = settings.oLanguage.oPaginate;
          var aria = settings.oLanguage.oAria.paginate || {};
          var btnDisplay, btnClass, counter = 0;
          var attach = function(container, buttons2) {
            var i, ien, node, button;
            var clickHandler = function(e) {
              e.preventDefault();
              if (!$2(e.currentTarget).hasClass("disabled") && api.page() != e.data.action) {
                api.page(e.data.action).draw("page");
              }
            };
            for (i = 0, ien = buttons2.length; i < ien; i++) {
              button = buttons2[i];
              if (Array.isArray(button)) {
                attach(container, button);
              } else {
                btnDisplay = "";
                btnClass = "";
                switch (button) {
                  case "ellipsis":
                    btnDisplay = "&#x2026;";
                    btnClass = "disabled";
                    break;
                  case "first":
                    btnDisplay = lang.sFirst;
                    btnClass = button + (page > 0 ? "" : " disabled");
                    break;
                  case "previous":
                    btnDisplay = lang.sPrevious;
                    btnClass = button + (page > 0 ? "" : " disabled");
                    break;
                  case "next":
                    btnDisplay = lang.sNext;
                    btnClass = button + (page < pages - 1 ? "" : " disabled");
                    break;
                  case "last":
                    btnDisplay = lang.sLast;
                    btnClass = button + (page < pages - 1 ? "" : " disabled");
                    break;
                  default:
                    btnDisplay = button + 1;
                    btnClass = page === button ? "active" : "";
                    break;
                }
                if (btnDisplay) {
                  node = $2("<li>", {
                    "class": classes.sPageButton + " " + btnClass,
                    "id": idx === 0 && typeof button === "string" ? settings.sTableId + "_" + button : null
                  }).append($2("<a>", {
                    "href": "#",
                    "aria-controls": settings.sTableId,
                    "aria-label": aria[button],
                    "data-dt-idx": counter,
                    "tabindex": settings.iTabIndex,
                    "class": "page-link"
                  }).html(btnDisplay)).appendTo(container);
                  settings.oApi._fnBindAction(node, { action: button }, clickHandler);
                  counter++;
                }
              }
            }
          };
          var activeEl;
          try {
            activeEl = $2(host).find(document2.activeElement).data("dt-idx");
          } catch (e) {
          }
          attach($2(host).empty().html('<ul class="pagination"/>').children("ul"), buttons);
          if (activeEl !== undefined2) {
            $2(host).find("[data-dt-idx=" + activeEl + "]").trigger("focus");
          }
        };
        return DataTable;
      });
    }
  });

  // app/javascript/packs/active_jobs.js
  var import_oboe = __toESM(require_oboe_browser());
  var import_datatables = __toESM(require_jquery_dataTables());
  var import_dataTables = __toESM(require_dataTables_bootstrap4());

  // node_modules/datatables.net-plugins/api/processing().js
  jQuery.fn.dataTable.Api.register("processing()", function(show) {
    return this.iterator("table", function(ctx) {
      ctx.oApi._fnProcessingDisplay(ctx, show);
    });
  });

  // app/javascript/packs/active_jobs.js
  window.fetch_table_data = fetch_table_data;
  window.create_datatable = create_datatable;
  window.set_cluster_id = set_cluster_id;
  window.set_filter_id = set_filter_id;
  var entityMap = {
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#39;",
    "/": "&#x2F;",
    "`": "&#x60;",
    "=": "&#x3D;"
  };
  function escapeHtml(string) {
    return String(string).replace(/[&<>"'`=\/]/g, function fromEntityMap(s) {
      return entityMap[s];
    });
  }
  function human_time(seconds_total) {
    var hours = parseInt(seconds_total / 3600), minutes = parseInt((seconds_total - hours * 3600) / 60), seconds = parseInt(seconds_total - 3600 * hours - 60 * minutes), hours_str = ("" + hours).padStart(2, "0"), minutes_str = ("" + minutes).padStart(2, "0"), seconds_str = ("" + seconds).padStart(2, "0");
    return hours_str + ":" + minutes_str + ":" + seconds_str;
  }
  function fetch_job_data(tr, row, options) {
    let btn = tr.find("button.details-control");
    if (row.child.isShown()) {
      row.child.hide();
      tr.removeClass("shown");
      btn.removeClass("fa-chevron-down");
      btn.addClass("fa-chevron-right");
      btn.attr("aria-expanded", false);
    } else {
      tr.addClass("shown");
      btn.removeClass("fa-chevron-right");
      btn.addClass("fa-chevron-down");
      btn.attr("aria-expanded", true);
      let data = {
        pbsid: row.data().pbsid,
        cluster: row.data().cluster
      };
      let jobDataUrl = `${options.base_uri}/activejobs/json?${new URLSearchParams(data)}`;
      $.getJSON(jobDataUrl, function(data2) {
        row.child(data2.html_ganglia_graphs_table).show();
        $(`div[data-jobid="${escapeHtml(row.data().pbsid)}"]`).hide().html(data2.html_extended_panel).fadeIn(250);
        tr.find(".status-label").html(data2.status);
      }).fail(function(jqXHR, textStatus, errorThrown) {
        let error_panel = `
        <div class="alert alert-danger" role="alert">
          <strong>Error:</strong> The information could not be displayed.
          <em>${jqXHR.status} (${errorThrown})</em>
        </div>
      `;
        $(`div[data-jobid="${row.data().pbsid}]"`).hide().html(error_panel).fadeIn(250);
      });
    }
  }
  function fetch_table_data(table, options) {
    if (!options)
      options = {};
    if (!options.doneCallback)
      options.doneCallback = null;
    if (!options.base_uri)
      options.base_uri = window.location.pathname;
    (0, import_oboe.default)({
      url: options.base_uri + "/activejobs.json?" + get_request_params(),
      headers: {
        "X-CSRF-Token": $('meta[name="csrf-token"]').attr("content"),
        "X-Requested-With": "XMLHttpRequest",
        "Content-Type": "application/json"
      }
    }).start(function() {
      table.processing(true);
    }).node("data.*", function(jobs) {
      table.rows.add(jobs).draw();
      table.processing(false);
    }).node("errors.*", function(error) {
      show_errors([error]);
    }).done(function() {
      table.processing(false);
      if (options.doneCallback) {
        options.doneCallback();
      }
    }).fail(function(errorReport) {
      if (errorReport.statusCode != null) {
        show_errors(["Request for jobs failed with status code: " + errorReport.statusCode]);
      } else {
        show_errors(["Request for jobs failed due to body parsing error."]);
      }
      table.processing(false);
    });
  }
  function status_label(status) {
    var label = "Undetermined", labelclass = "badge-default";
    if (status == "completed") {
      label = "Completed";
      labelclass = "badge-success";
    }
    if (status == "running") {
      label = "Running";
      labelclass = "badge-primary";
    }
    if (status == "queued") {
      label = "Queued";
      labelclass = "badge-info";
    }
    if (status == "queued_held") {
      label = "Hold";
      labelclass = "badge-warning";
    }
    if (status == "suspended") {
      label = "Suspend";
      labelclass = "badge-warning";
    }
    return `<span class="badge ${labelclass}">${escapeHtml(label)}</span>`;
  }
  function create_datatable(options) {
    if (!options)
      options = {};
    if (!options.drawCallback)
      options.drawCallback = null;
    if (!options.base_uri)
      options.base_uri = window.location.pathname;
    $("#selected-filter-label").text($("#filter-id-" + filter_id).text());
    $("#selected-cluster-label").text($("#cluster-id-" + cluster_id).text());
    $("#" + filter_id).addClass("active");
    var table = $("#job_status_table").DataTable({
      autoWidth: true,
      "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
      "bStateSave": true,
      "aaSorting": [],
      "pageLength": 50,
      "oLanguage": {
        "sSearch": "Filter: "
      },
      "fnInitComplete": function(oSettings) {
        for (var i = 0, iLen = oSettings.aoData.length; i < iLen; i++) {
          if (oSettings.aoData[i]._aData.username == JobStatusapp.username) {
            oSettings.aoData[i].nTr.className += " bg-info";
          }
        }
      },
      processing: true,
      drawCallback: function(settings) {
        if (options.drawCallback) {
          options.drawCallback(settings);
        }
      },
      columns: [
        {
          "orderable": false,
          "data": "extended_available",
          "defaultContent": "",
          "width": "20px",
          "searchable": false,
          render: function(data, type, row, meta) {
            let { cluster_title, jobname } = row;
            return `<button class="details-control fa fa-chevron-right btn btn-default" aria-expanded="false" aria-label="Toggle visibility of job details for job ${escapeHtml(jobname)} on ${cluster_title}"></button>`;
          }
        },
        {
          data: "pbsid",
          "autoWidth": true,
          render: function(data) {
            var data = escapeHtml(data);
            return `<span title="${data}">${data}</span>`;
          }
        },
        {
          data: "jobname",
          width: "25%",
          render: function(data) {
            var data = escapeHtml(data);
            return `<span title="${data}" class="text-break">${data}</span>`;
          }
        },
        {
          data: "username",
          "autoWidth": true,
          render: function(data) {
            var data = escapeHtml(data);
            return `<span title="${data}">${data}</span>`;
          }
        },
        {
          data: "account",
          "autoWidth": true,
          render: function(data) {
            var data = escapeHtml(data);
            return `<span title="${data}">${data}</span>`;
          }
        },
        {
          data: "walltime_used",
          className: "text-right",
          "autoWidth": true,
          render: function(data) {
            return `
                    <span title="${human_time(data)}">
                      ${human_time(data)}
                    </span>
                  `;
          }
        },
        {
          data: "queue",
          "autoWidth": true,
          "render": function(data) {
            var data = escapeHtml(data);
            return `<span title="${data}">${data}</span>`;
          }
        },
        {
          data: "status",
          className: "status-label",
          "autoWidth": true,
          "render": function(data) {
            return status_label(data);
          }
        },
        {
          data: "cluster_title",
          "autoWidth": true
        },
        {
          data: null,
          "autoWidth": true,
          render: function(data, type, row, meta) {
            let { jobname, pbsid, delete_path } = data;
            if (data.delete_path == "" || data.status == "completed") {
              return "";
            } else {
              return `
                      <div>
                        <a
                          class="btn btn-danger btn-xs"
                          data-method="delete"
                          data-confirm="Are you sure you want to delete ${escapeHtml(jobname)} - ${pbsid}"
                          href="${escapeHtml(delete_path)}"
                          aria-labeled-by"title"
                          aria-label="Delete job ${escapeHtml(jobname)} with ID ${pbsid}"
                          data-toggle="tooltip"
                          title="Delete Job"
                        >
                          <i class='fas fa-trash-alt fa-fw' aria-hidden='true'></i>
                        </a>
                      </div>
                    `;
            }
          }
        }
      ]
    }).on("error.dt", function(e, settings, techNote, message) {
      show_errors(["There was an error getting data from the remote server."]);
    });
    $.fn.dataTable.ext.errMode = "none";
    $("#job_status_table tbody").on("click", ".details-control", function() {
      var tr = $(this).closest("tr");
      var row = table.row(tr);
      fetch_job_data(tr, row, options);
    });
    table.columns.adjust().draw();
    return table;
  }
  function show_errors(errors) {
    for (var i = 0; i < errors.length; i++) {
      $("#ajax-error-message-text").append(`<div>${errors[i]}</div>`);
    }
    $("#ajax-error-message").removeAttr("hidden");
  }
  function get_request_params() {
    return jQuery.param({
      jobcluster: cluster_id,
      jobfilter: filter_id
    });
  }
  function set_filter_id(id) {
    localStorage.setItem("jobfilter", id);
    filter_id = id;
    reload_page();
  }
  function set_cluster_id(id) {
    localStorage.setItem("jobcluster", id);
    cluster_id = id;
    reload_page();
  }
  function reload_page() {
    window.location = "?" + get_request_params();
  }
})();
/*!
 * jQuery JavaScript Library v3.6.0
 * https://jquery.com/
 *
 * Includes Sizzle.js
 * https://sizzlejs.com/
 *
 * Copyright OpenJS Foundation and other contributors
 * Released under the MIT license
 * https://jquery.org/license
 *
 * Date: 2021-03-02T17:08Z
 */
/*!
 * v2.1.4-104-gc868b3a
 * 
 */
/*! DataTables 1.11.5
 * ©2008-2021 SpryMedia Ltd - datatables.net/license
 */
/*! DataTables Bootstrap 4 integration
 * ©2011-2017 SpryMedia Ltd - datatables.net/license
 */
//# sourceMappingURL=active_jobs.js.map
