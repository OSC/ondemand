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

  // node_modules/jquery/dist/jquery.js
  var require_jquery = __commonJS({
    "node_modules/jquery/dist/jquery.js"(exports, module) {
      (function(global2, factory) {
        "use strict";
        if (typeof module === "object" && typeof module.exports === "object") {
          module.exports = global2.document ? factory(global2, true) : function(w) {
            if (!w.document) {
              throw new Error("jQuery requires a window with a document");
            }
            return factory(w);
          };
        } else {
          factory(global2);
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
        var version = "3.6.0", jQuery3 = function(selector, context) {
          return new jQuery3.fn.init(selector, context);
        };
        jQuery3.fn = jQuery3.prototype = {
          jquery: version,
          constructor: jQuery3,
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
            var ret = jQuery3.merge(this.constructor(), elems);
            ret.prevObject = this;
            return ret;
          },
          each: function(callback) {
            return jQuery3.each(this, callback);
          },
          map: function(callback) {
            return this.pushStack(jQuery3.map(this, function(elem, i) {
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
            return this.pushStack(jQuery3.grep(this, function(_elem, i) {
              return (i + 1) % 2;
            }));
          },
          odd: function() {
            return this.pushStack(jQuery3.grep(this, function(_elem, i) {
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
        jQuery3.extend = jQuery3.fn.extend = function() {
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
                if (deep && copy && (jQuery3.isPlainObject(copy) || (copyIsArray = Array.isArray(copy)))) {
                  src = target[name];
                  if (copyIsArray && !Array.isArray(src)) {
                    clone = [];
                  } else if (!copyIsArray && !jQuery3.isPlainObject(src)) {
                    clone = {};
                  } else {
                    clone = src;
                  }
                  copyIsArray = false;
                  target[name] = jQuery3.extend(deep, clone, copy);
                } else if (copy !== void 0) {
                  target[name] = copy;
                }
              }
            }
          }
          return target;
        };
        jQuery3.extend({
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
                jQuery3.merge(ret, typeof arr2 === "string" ? [arr2] : arr2);
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
          jQuery3.fn[Symbol.iterator] = arr[Symbol.iterator];
        }
        jQuery3.each("Boolean Number String Function Array Date RegExp Object Error Symbol".split(" "), function(_i, name) {
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
        jQuery3.find = Sizzle;
        jQuery3.expr = Sizzle.selectors;
        jQuery3.expr[":"] = jQuery3.expr.pseudos;
        jQuery3.uniqueSort = jQuery3.unique = Sizzle.uniqueSort;
        jQuery3.text = Sizzle.getText;
        jQuery3.isXMLDoc = Sizzle.isXML;
        jQuery3.contains = Sizzle.contains;
        jQuery3.escapeSelector = Sizzle.escape;
        var dir = function(elem, dir2, until) {
          var matched = [], truncate = until !== void 0;
          while ((elem = elem[dir2]) && elem.nodeType !== 9) {
            if (elem.nodeType === 1) {
              if (truncate && jQuery3(elem).is(until)) {
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
        var rneedsContext = jQuery3.expr.match.needsContext;
        function nodeName(elem, name) {
          return elem.nodeName && elem.nodeName.toLowerCase() === name.toLowerCase();
        }
        var rsingleTag = /^<([a-z][^\/\0>:\x20\t\r\n\f]*)[\x20\t\r\n\f]*\/?>(?:<\/\1>|)$/i;
        function winnow(elements, qualifier, not) {
          if (isFunction(qualifier)) {
            return jQuery3.grep(elements, function(elem, i) {
              return !!qualifier.call(elem, i, elem) !== not;
            });
          }
          if (qualifier.nodeType) {
            return jQuery3.grep(elements, function(elem) {
              return elem === qualifier !== not;
            });
          }
          if (typeof qualifier !== "string") {
            return jQuery3.grep(elements, function(elem) {
              return indexOf.call(qualifier, elem) > -1 !== not;
            });
          }
          return jQuery3.filter(qualifier, elements, not);
        }
        jQuery3.filter = function(expr, elems, not) {
          var elem = elems[0];
          if (not) {
            expr = ":not(" + expr + ")";
          }
          if (elems.length === 1 && elem.nodeType === 1) {
            return jQuery3.find.matchesSelector(elem, expr) ? [elem] : [];
          }
          return jQuery3.find.matches(expr, jQuery3.grep(elems, function(elem2) {
            return elem2.nodeType === 1;
          }));
        };
        jQuery3.fn.extend({
          find: function(selector) {
            var i, ret, len = this.length, self2 = this;
            if (typeof selector !== "string") {
              return this.pushStack(jQuery3(selector).filter(function() {
                for (i = 0; i < len; i++) {
                  if (jQuery3.contains(self2[i], this)) {
                    return true;
                  }
                }
              }));
            }
            ret = this.pushStack([]);
            for (i = 0; i < len; i++) {
              jQuery3.find(selector, self2[i], ret);
            }
            return len > 1 ? jQuery3.uniqueSort(ret) : ret;
          },
          filter: function(selector) {
            return this.pushStack(winnow(this, selector || [], false));
          },
          not: function(selector) {
            return this.pushStack(winnow(this, selector || [], true));
          },
          is: function(selector) {
            return !!winnow(this, typeof selector === "string" && rneedsContext.test(selector) ? jQuery3(selector) : selector || [], false).length;
          }
        });
        var rootjQuery, rquickExpr = /^(?:\s*(<[\w\W]+>)[^>]*|#([\w-]+))$/, init = jQuery3.fn.init = function(selector, context, root) {
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
                context = context instanceof jQuery3 ? context[0] : context;
                jQuery3.merge(this, jQuery3.parseHTML(match[1], context && context.nodeType ? context.ownerDocument || context : document2, true));
                if (rsingleTag.test(match[1]) && jQuery3.isPlainObject(context)) {
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
            return root.ready !== void 0 ? root.ready(selector) : selector(jQuery3);
          }
          return jQuery3.makeArray(selector, this);
        };
        init.prototype = jQuery3.fn;
        rootjQuery = jQuery3(document2);
        var rparentsprev = /^(?:parents|prev(?:Until|All))/, guaranteedUnique = {
          children: true,
          contents: true,
          next: true,
          prev: true
        };
        jQuery3.fn.extend({
          has: function(target) {
            var targets = jQuery3(target, this), l = targets.length;
            return this.filter(function() {
              var i = 0;
              for (; i < l; i++) {
                if (jQuery3.contains(this, targets[i])) {
                  return true;
                }
              }
            });
          },
          closest: function(selectors, context) {
            var cur, i = 0, l = this.length, matched = [], targets = typeof selectors !== "string" && jQuery3(selectors);
            if (!rneedsContext.test(selectors)) {
              for (; i < l; i++) {
                for (cur = this[i]; cur && cur !== context; cur = cur.parentNode) {
                  if (cur.nodeType < 11 && (targets ? targets.index(cur) > -1 : cur.nodeType === 1 && jQuery3.find.matchesSelector(cur, selectors))) {
                    matched.push(cur);
                    break;
                  }
                }
              }
            }
            return this.pushStack(matched.length > 1 ? jQuery3.uniqueSort(matched) : matched);
          },
          index: function(elem) {
            if (!elem) {
              return this[0] && this[0].parentNode ? this.first().prevAll().length : -1;
            }
            if (typeof elem === "string") {
              return indexOf.call(jQuery3(elem), this[0]);
            }
            return indexOf.call(this, elem.jquery ? elem[0] : elem);
          },
          add: function(selector, context) {
            return this.pushStack(jQuery3.uniqueSort(jQuery3.merge(this.get(), jQuery3(selector, context))));
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
        jQuery3.each({
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
            return jQuery3.merge([], elem.childNodes);
          }
        }, function(name, fn) {
          jQuery3.fn[name] = function(until, selector) {
            var matched = jQuery3.map(this, fn, until);
            if (name.slice(-5) !== "Until") {
              selector = until;
            }
            if (selector && typeof selector === "string") {
              matched = jQuery3.filter(selector, matched);
            }
            if (this.length > 1) {
              if (!guaranteedUnique[name]) {
                jQuery3.uniqueSort(matched);
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
          jQuery3.each(options.match(rnothtmlwhite) || [], function(_, flag) {
            object[flag] = true;
          });
          return object;
        }
        jQuery3.Callbacks = function(options) {
          options = typeof options === "string" ? createOptions(options) : jQuery3.extend({}, options);
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
                  jQuery3.each(args, function(_, arg) {
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
              jQuery3.each(arguments, function(_, arg) {
                var index;
                while ((index = jQuery3.inArray(arg, list, index)) > -1) {
                  list.splice(index, 1);
                  if (index <= firingIndex) {
                    firingIndex--;
                  }
                }
              });
              return this;
            },
            has: function(fn) {
              return fn ? jQuery3.inArray(fn, list) > -1 : list.length > 0;
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
        jQuery3.extend({
          Deferred: function(func) {
            var tuples = [
              [
                "notify",
                "progress",
                jQuery3.Callbacks("memory"),
                jQuery3.Callbacks("memory"),
                2
              ],
              [
                "resolve",
                "done",
                jQuery3.Callbacks("once memory"),
                jQuery3.Callbacks("once memory"),
                0,
                "resolved"
              ],
              [
                "reject",
                "fail",
                jQuery3.Callbacks("once memory"),
                jQuery3.Callbacks("once memory"),
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
                return jQuery3.Deferred(function(newDefer) {
                  jQuery3.each(tuples, function(_i, tuple) {
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
                        if (jQuery3.Deferred.exceptionHook) {
                          jQuery3.Deferred.exceptionHook(e, process.stackTrace);
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
                      if (jQuery3.Deferred.getStackHook) {
                        process.stackTrace = jQuery3.Deferred.getStackHook();
                      }
                      window2.setTimeout(process);
                    }
                  };
                }
                return jQuery3.Deferred(function(newDefer) {
                  tuples[0][3].add(resolve(0, newDefer, isFunction(onProgress) ? onProgress : Identity, newDefer.notifyWith));
                  tuples[1][3].add(resolve(0, newDefer, isFunction(onFulfilled) ? onFulfilled : Identity));
                  tuples[2][3].add(resolve(0, newDefer, isFunction(onRejected) ? onRejected : Thrower));
                }).promise();
              },
              promise: function(obj) {
                return obj != null ? jQuery3.extend(obj, promise) : promise;
              }
            }, deferred = {};
            jQuery3.each(tuples, function(i, tuple) {
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
            var remaining = arguments.length, i = remaining, resolveContexts = Array(i), resolveValues = slice.call(arguments), primary = jQuery3.Deferred(), updateFunc = function(i2) {
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
        jQuery3.Deferred.exceptionHook = function(error, stack) {
          if (window2.console && window2.console.warn && error && rerrorNames.test(error.name)) {
            window2.console.warn("jQuery.Deferred exception: " + error.message, error.stack, stack);
          }
        };
        jQuery3.readyException = function(error) {
          window2.setTimeout(function() {
            throw error;
          });
        };
        var readyList = jQuery3.Deferred();
        jQuery3.fn.ready = function(fn) {
          readyList.then(fn).catch(function(error) {
            jQuery3.readyException(error);
          });
          return this;
        };
        jQuery3.extend({
          isReady: false,
          readyWait: 1,
          ready: function(wait) {
            if (wait === true ? --jQuery3.readyWait : jQuery3.isReady) {
              return;
            }
            jQuery3.isReady = true;
            if (wait !== true && --jQuery3.readyWait > 0) {
              return;
            }
            readyList.resolveWith(document2, [jQuery3]);
          }
        });
        jQuery3.ready.then = readyList.then;
        function completed() {
          document2.removeEventListener("DOMContentLoaded", completed);
          window2.removeEventListener("load", completed);
          jQuery3.ready();
        }
        if (document2.readyState === "complete" || document2.readyState !== "loading" && !document2.documentElement.doScroll) {
          window2.setTimeout(jQuery3.ready);
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
                  return bulk.call(jQuery3(elem), value2);
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
          this.expando = jQuery3.expando + Data.uid++;
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
            if (key === void 0 || jQuery3.isEmptyObject(cache)) {
              if (owner.nodeType) {
                owner[this.expando] = void 0;
              } else {
                delete owner[this.expando];
              }
            }
          },
          hasData: function(owner) {
            var cache = owner[this.expando];
            return cache !== void 0 && !jQuery3.isEmptyObject(cache);
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
        jQuery3.extend({
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
        jQuery3.fn.extend({
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
        jQuery3.extend({
          queue: function(elem, type, data) {
            var queue;
            if (elem) {
              type = (type || "fx") + "queue";
              queue = dataPriv.get(elem, type);
              if (data) {
                if (!queue || Array.isArray(data)) {
                  queue = dataPriv.access(elem, type, jQuery3.makeArray(data));
                } else {
                  queue.push(data);
                }
              }
              return queue || [];
            }
          },
          dequeue: function(elem, type) {
            type = type || "fx";
            var queue = jQuery3.queue(elem, type), startLength = queue.length, fn = queue.shift(), hooks = jQuery3._queueHooks(elem, type), next = function() {
              jQuery3.dequeue(elem, type);
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
              empty: jQuery3.Callbacks("once memory").add(function() {
                dataPriv.remove(elem, [type + "queue", key]);
              })
            });
          }
        });
        jQuery3.fn.extend({
          queue: function(type, data) {
            var setter = 2;
            if (typeof type !== "string") {
              data = type;
              type = "fx";
              setter--;
            }
            if (arguments.length < setter) {
              return jQuery3.queue(this[0], type);
            }
            return data === void 0 ? this : this.each(function() {
              var queue = jQuery3.queue(this, type, data);
              jQuery3._queueHooks(this, type);
              if (type === "fx" && queue[0] !== "inprogress") {
                jQuery3.dequeue(this, type);
              }
            });
          },
          dequeue: function(type) {
            return this.each(function() {
              jQuery3.dequeue(this, type);
            });
          },
          clearQueue: function(type) {
            return this.queue(type || "fx", []);
          },
          promise: function(type, obj) {
            var tmp, count = 1, defer = jQuery3.Deferred(), elements = this, i = this.length, resolve = function() {
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
          return jQuery3.contains(elem.ownerDocument, elem);
        }, composed = { composed: true };
        if (documentElement.getRootNode) {
          isAttached = function(elem) {
            return jQuery3.contains(elem.ownerDocument, elem) || elem.getRootNode(composed) === elem.ownerDocument;
          };
        }
        var isHiddenWithinTree = function(elem, el) {
          elem = el || elem;
          return elem.style.display === "none" || elem.style.display === "" && isAttached(elem) && jQuery3.css(elem, "display") === "none";
        };
        function adjustCSS(elem, prop, valueParts, tween) {
          var adjusted, scale, maxIterations = 20, currentValue = tween ? function() {
            return tween.cur();
          } : function() {
            return jQuery3.css(elem, prop, "");
          }, initial = currentValue(), unit = valueParts && valueParts[3] || (jQuery3.cssNumber[prop] ? "" : "px"), initialInUnit = elem.nodeType && (jQuery3.cssNumber[prop] || unit !== "px" && +initial) && rcssNum.exec(jQuery3.css(elem, prop));
          if (initialInUnit && initialInUnit[3] !== unit) {
            initial = initial / 2;
            unit = unit || initialInUnit[3];
            initialInUnit = +initial || 1;
            while (maxIterations--) {
              jQuery3.style(elem, prop, initialInUnit + unit);
              if ((1 - scale) * (1 - (scale = currentValue() / initial || 0.5)) <= 0) {
                maxIterations = 0;
              }
              initialInUnit = initialInUnit / scale;
            }
            initialInUnit = initialInUnit * 2;
            jQuery3.style(elem, prop, initialInUnit + unit);
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
          display = jQuery3.css(temp, "display");
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
        jQuery3.fn.extend({
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
                jQuery3(this).show();
              } else {
                jQuery3(this).hide();
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
            return jQuery3.merge([context], ret);
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
                jQuery3.merge(nodes, elem.nodeType ? [elem] : elem);
              } else if (!rhtml.test(elem)) {
                nodes.push(context.createTextNode(elem));
              } else {
                tmp = tmp || fragment.appendChild(context.createElement("div"));
                tag = (rtagName.exec(elem) || ["", ""])[1].toLowerCase();
                wrap = wrapMap[tag] || wrapMap._default;
                tmp.innerHTML = wrap[1] + jQuery3.htmlPrefilter(elem) + wrap[2];
                j = wrap[0];
                while (j--) {
                  tmp = tmp.lastChild;
                }
                jQuery3.merge(nodes, tmp.childNodes);
                tmp = fragment.firstChild;
                tmp.textContent = "";
              }
            }
          }
          fragment.textContent = "";
          i = 0;
          while (elem = nodes[i++]) {
            if (selection && jQuery3.inArray(elem, selection) > -1) {
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
              jQuery3().off(event);
              return origFn.apply(this, arguments);
            };
            fn.guid = origFn.guid || (origFn.guid = jQuery3.guid++);
          }
          return elem.each(function() {
            jQuery3.event.add(this, types, fn, data, selector);
          });
        }
        jQuery3.event = {
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
              jQuery3.find.matchesSelector(documentElement, selector);
            }
            if (!handler.guid) {
              handler.guid = jQuery3.guid++;
            }
            if (!(events = elemData.events)) {
              events = elemData.events = /* @__PURE__ */ Object.create(null);
            }
            if (!(eventHandle = elemData.handle)) {
              eventHandle = elemData.handle = function(e) {
                return typeof jQuery3 !== "undefined" && jQuery3.event.triggered !== e.type ? jQuery3.event.dispatch.apply(elem, arguments) : void 0;
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
              special = jQuery3.event.special[type] || {};
              type = (selector ? special.delegateType : special.bindType) || type;
              special = jQuery3.event.special[type] || {};
              handleObj = jQuery3.extend({
                type,
                origType,
                data,
                handler,
                guid: handler.guid,
                selector,
                needsContext: selector && jQuery3.expr.match.needsContext.test(selector),
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
              jQuery3.event.global[type] = true;
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
                  jQuery3.event.remove(elem, type + types[t], handler, selector, true);
                }
                continue;
              }
              special = jQuery3.event.special[type] || {};
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
                  jQuery3.removeEvent(elem, type, elemData.handle);
                }
                delete events[type];
              }
            }
            if (jQuery3.isEmptyObject(events)) {
              dataPriv.remove(elem, "handle events");
            }
          },
          dispatch: function(nativeEvent) {
            var i, j, ret, matched, handleObj, handlerQueue, args = new Array(arguments.length), event = jQuery3.event.fix(nativeEvent), handlers = (dataPriv.get(this, "events") || /* @__PURE__ */ Object.create(null))[event.type] || [], special = jQuery3.event.special[event.type] || {};
            args[0] = event;
            for (i = 1; i < arguments.length; i++) {
              args[i] = arguments[i];
            }
            event.delegateTarget = this;
            if (special.preDispatch && special.preDispatch.call(this, event) === false) {
              return;
            }
            handlerQueue = jQuery3.event.handlers.call(this, event, handlers);
            i = 0;
            while ((matched = handlerQueue[i++]) && !event.isPropagationStopped()) {
              event.currentTarget = matched.elem;
              j = 0;
              while ((handleObj = matched.handlers[j++]) && !event.isImmediatePropagationStopped()) {
                if (!event.rnamespace || handleObj.namespace === false || event.rnamespace.test(handleObj.namespace)) {
                  event.handleObj = handleObj;
                  event.data = handleObj.data;
                  ret = ((jQuery3.event.special[handleObj.origType] || {}).handle || handleObj.handler).apply(matched.elem, args);
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
                      matchedSelectors[sel] = handleObj.needsContext ? jQuery3(sel, this).index(cur) > -1 : jQuery3.find(sel, this, null, [cur]).length;
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
            Object.defineProperty(jQuery3.Event.prototype, name, {
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
            return originalEvent[jQuery3.expando] ? originalEvent : new jQuery3.Event(originalEvent);
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
              jQuery3.event.add(el, type, returnTrue);
            }
            return;
          }
          dataPriv.set(el, type, false);
          jQuery3.event.add(el, type, {
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
                } else if ((jQuery3.event.special[type] || {}).delegateType) {
                  event.stopPropagation();
                }
              } else if (saved.length) {
                dataPriv.set(this, type, {
                  value: jQuery3.event.trigger(jQuery3.extend(saved[0], jQuery3.Event.prototype), saved.slice(1), this)
                });
                event.stopImmediatePropagation();
              }
            }
          });
        }
        jQuery3.removeEvent = function(elem, type, handle) {
          if (elem.removeEventListener) {
            elem.removeEventListener(type, handle);
          }
        };
        jQuery3.Event = function(src, props) {
          if (!(this instanceof jQuery3.Event)) {
            return new jQuery3.Event(src, props);
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
            jQuery3.extend(this, props);
          }
          this.timeStamp = src && src.timeStamp || Date.now();
          this[jQuery3.expando] = true;
        };
        jQuery3.Event.prototype = {
          constructor: jQuery3.Event,
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
        jQuery3.each({
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
        }, jQuery3.event.addProp);
        jQuery3.each({ focus: "focusin", blur: "focusout" }, function(type, delegateType) {
          jQuery3.event.special[type] = {
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
        jQuery3.each({
          mouseenter: "mouseover",
          mouseleave: "mouseout",
          pointerenter: "pointerover",
          pointerleave: "pointerout"
        }, function(orig, fix) {
          jQuery3.event.special[orig] = {
            delegateType: fix,
            bindType: fix,
            handle: function(event) {
              var ret, target = this, related = event.relatedTarget, handleObj = event.handleObj;
              if (!related || related !== target && !jQuery3.contains(target, related)) {
                event.type = handleObj.origType;
                ret = handleObj.handler.apply(this, arguments);
                event.type = fix;
              }
              return ret;
            }
          };
        });
        jQuery3.fn.extend({
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
              jQuery3(types.delegateTarget).off(handleObj.namespace ? handleObj.origType + "." + handleObj.namespace : handleObj.origType, handleObj.selector, handleObj.handler);
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
              jQuery3.event.remove(this, types, fn, selector);
            });
          }
        });
        var rnoInnerhtml = /<script|<style|<link/i, rchecked = /checked\s*(?:[^=]|=\s*.checked.)/i, rcleanScript = /^\s*<!(?:\[CDATA\[|--)|(?:\]\]|--)>\s*$/g;
        function manipulationTarget(elem, content) {
          if (nodeName(elem, "table") && nodeName(content.nodeType !== 11 ? content : content.firstChild, "tr")) {
            return jQuery3(elem).children("tbody")[0] || elem;
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
                  jQuery3.event.add(dest, type, events[type][i]);
                }
              }
            }
          }
          if (dataUser.hasData(src)) {
            udataOld = dataUser.access(src);
            udataCur = jQuery3.extend({}, udataOld);
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
              scripts = jQuery3.map(getAll(fragment, "script"), disableScript);
              hasScripts = scripts.length;
              for (; i < l; i++) {
                node = fragment;
                if (i !== iNoClone) {
                  node = jQuery3.clone(node, true, true);
                  if (hasScripts) {
                    jQuery3.merge(scripts, getAll(node, "script"));
                  }
                }
                callback.call(collection[i], node, i);
              }
              if (hasScripts) {
                doc = scripts[scripts.length - 1].ownerDocument;
                jQuery3.map(scripts, restoreScript);
                for (i = 0; i < hasScripts; i++) {
                  node = scripts[i];
                  if (rscriptType.test(node.type || "") && !dataPriv.access(node, "globalEval") && jQuery3.contains(doc, node)) {
                    if (node.src && (node.type || "").toLowerCase() !== "module") {
                      if (jQuery3._evalUrl && !node.noModule) {
                        jQuery3._evalUrl(node.src, {
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
          var node, nodes = selector ? jQuery3.filter(selector, elem) : elem, i = 0;
          for (; (node = nodes[i]) != null; i++) {
            if (!keepData && node.nodeType === 1) {
              jQuery3.cleanData(getAll(node));
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
        jQuery3.extend({
          htmlPrefilter: function(html) {
            return html;
          },
          clone: function(elem, dataAndEvents, deepDataAndEvents) {
            var i, l, srcElements, destElements, clone = elem.cloneNode(true), inPage = isAttached(elem);
            if (!support.noCloneChecked && (elem.nodeType === 1 || elem.nodeType === 11) && !jQuery3.isXMLDoc(elem)) {
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
            var data, elem, type, special = jQuery3.event.special, i = 0;
            for (; (elem = elems[i]) !== void 0; i++) {
              if (acceptData(elem)) {
                if (data = elem[dataPriv.expando]) {
                  if (data.events) {
                    for (type in data.events) {
                      if (special[type]) {
                        jQuery3.event.remove(elem, type);
                      } else {
                        jQuery3.removeEvent(elem, type, data.handle);
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
        jQuery3.fn.extend({
          detach: function(selector) {
            return remove(this, selector, true);
          },
          remove: function(selector) {
            return remove(this, selector);
          },
          text: function(value) {
            return access(this, function(value2) {
              return value2 === void 0 ? jQuery3.text(this) : this.empty().each(function() {
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
                jQuery3.cleanData(getAll(elem, false));
                elem.textContent = "";
              }
            }
            return this;
          },
          clone: function(dataAndEvents, deepDataAndEvents) {
            dataAndEvents = dataAndEvents == null ? false : dataAndEvents;
            deepDataAndEvents = deepDataAndEvents == null ? dataAndEvents : deepDataAndEvents;
            return this.map(function() {
              return jQuery3.clone(this, dataAndEvents, deepDataAndEvents);
            });
          },
          html: function(value) {
            return access(this, function(value2) {
              var elem = this[0] || {}, i = 0, l = this.length;
              if (value2 === void 0 && elem.nodeType === 1) {
                return elem.innerHTML;
              }
              if (typeof value2 === "string" && !rnoInnerhtml.test(value2) && !wrapMap[(rtagName.exec(value2) || ["", ""])[1].toLowerCase()]) {
                value2 = jQuery3.htmlPrefilter(value2);
                try {
                  for (; i < l; i++) {
                    elem = this[i] || {};
                    if (elem.nodeType === 1) {
                      jQuery3.cleanData(getAll(elem, false));
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
              if (jQuery3.inArray(this, ignored) < 0) {
                jQuery3.cleanData(getAll(this));
                if (parent) {
                  parent.replaceChild(elem, this);
                }
              }
            }, ignored);
          }
        });
        jQuery3.each({
          appendTo: "append",
          prependTo: "prepend",
          insertBefore: "before",
          insertAfter: "after",
          replaceAll: "replaceWith"
        }, function(name, original) {
          jQuery3.fn[name] = function(selector) {
            var elems, ret = [], insert = jQuery3(selector), last = insert.length - 1, i = 0;
            for (; i <= last; i++) {
              elems = i === last ? this : this.clone(true);
              jQuery3(insert[i])[original](elems);
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
          jQuery3.extend(support, {
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
              ret = jQuery3.style(elem, name);
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
          var final = jQuery3.cssProps[name] || vendorProps[name];
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
              delta += jQuery3.css(elem, box + cssExpand[i], true, styles);
            }
            if (!isBorderBox) {
              delta += jQuery3.css(elem, "padding" + cssExpand[i], true, styles);
              if (box !== "padding") {
                delta += jQuery3.css(elem, "border" + cssExpand[i] + "Width", true, styles);
              } else {
                extra += jQuery3.css(elem, "border" + cssExpand[i] + "Width", true, styles);
              }
            } else {
              if (box === "content") {
                delta -= jQuery3.css(elem, "padding" + cssExpand[i], true, styles);
              }
              if (box !== "margin") {
                delta -= jQuery3.css(elem, "border" + cssExpand[i] + "Width", true, styles);
              }
            }
          }
          if (!isBorderBox && computedVal >= 0) {
            delta += Math.max(0, Math.ceil(elem["offset" + dimension[0].toUpperCase() + dimension.slice(1)] - computedVal - delta - extra - 0.5)) || 0;
          }
          return delta;
        }
        function getWidthOrHeight(elem, dimension, extra) {
          var styles = getStyles(elem), boxSizingNeeded = !support.boxSizingReliable() || extra, isBorderBox = boxSizingNeeded && jQuery3.css(elem, "boxSizing", false, styles) === "border-box", valueIsBorderBox = isBorderBox, val = curCSS(elem, dimension, styles), offsetProp = "offset" + dimension[0].toUpperCase() + dimension.slice(1);
          if (rnumnonpx.test(val)) {
            if (!extra) {
              return val;
            }
            val = "auto";
          }
          if ((!support.boxSizingReliable() && isBorderBox || !support.reliableTrDimensions() && nodeName(elem, "tr") || val === "auto" || !parseFloat(val) && jQuery3.css(elem, "display", false, styles) === "inline") && elem.getClientRects().length) {
            isBorderBox = jQuery3.css(elem, "boxSizing", false, styles) === "border-box";
            valueIsBorderBox = offsetProp in elem;
            if (valueIsBorderBox) {
              val = elem[offsetProp];
            }
          }
          val = parseFloat(val) || 0;
          return val + boxModelAdjustment(elem, dimension, extra || (isBorderBox ? "border" : "content"), valueIsBorderBox, styles, val) + "px";
        }
        jQuery3.extend({
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
            hooks = jQuery3.cssHooks[name] || jQuery3.cssHooks[origName];
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
                value += ret && ret[3] || (jQuery3.cssNumber[origName] ? "" : "px");
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
            hooks = jQuery3.cssHooks[name] || jQuery3.cssHooks[origName];
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
        jQuery3.each(["height", "width"], function(_i, dimension) {
          jQuery3.cssHooks[dimension] = {
            get: function(elem, computed, extra) {
              if (computed) {
                return rdisplayswap.test(jQuery3.css(elem, "display")) && (!elem.getClientRects().length || !elem.getBoundingClientRect().width) ? swap(elem, cssShow, function() {
                  return getWidthOrHeight(elem, dimension, extra);
                }) : getWidthOrHeight(elem, dimension, extra);
              }
            },
            set: function(elem, value, extra) {
              var matches, styles = getStyles(elem), scrollboxSizeBuggy = !support.scrollboxSize() && styles.position === "absolute", boxSizingNeeded = scrollboxSizeBuggy || extra, isBorderBox = boxSizingNeeded && jQuery3.css(elem, "boxSizing", false, styles) === "border-box", subtract = extra ? boxModelAdjustment(elem, dimension, extra, isBorderBox, styles) : 0;
              if (isBorderBox && scrollboxSizeBuggy) {
                subtract -= Math.ceil(elem["offset" + dimension[0].toUpperCase() + dimension.slice(1)] - parseFloat(styles[dimension]) - boxModelAdjustment(elem, dimension, "border", false, styles) - 0.5);
              }
              if (subtract && (matches = rcssNum.exec(value)) && (matches[3] || "px") !== "px") {
                elem.style[dimension] = value;
                value = jQuery3.css(elem, dimension);
              }
              return setPositiveNumber(elem, value, subtract);
            }
          };
        });
        jQuery3.cssHooks.marginLeft = addGetHookIf(support.reliableMarginLeft, function(elem, computed) {
          if (computed) {
            return (parseFloat(curCSS(elem, "marginLeft")) || elem.getBoundingClientRect().left - swap(elem, { marginLeft: 0 }, function() {
              return elem.getBoundingClientRect().left;
            })) + "px";
          }
        });
        jQuery3.each({
          margin: "",
          padding: "",
          border: "Width"
        }, function(prefix, suffix) {
          jQuery3.cssHooks[prefix + suffix] = {
            expand: function(value) {
              var i = 0, expanded = {}, parts = typeof value === "string" ? value.split(" ") : [value];
              for (; i < 4; i++) {
                expanded[prefix + cssExpand[i] + suffix] = parts[i] || parts[i - 2] || parts[0];
              }
              return expanded;
            }
          };
          if (prefix !== "margin") {
            jQuery3.cssHooks[prefix + suffix].set = setPositiveNumber;
          }
        });
        jQuery3.fn.extend({
          css: function(name, value) {
            return access(this, function(elem, name2, value2) {
              var styles, len, map = {}, i = 0;
              if (Array.isArray(name2)) {
                styles = getStyles(elem);
                len = name2.length;
                for (; i < len; i++) {
                  map[name2[i]] = jQuery3.css(elem, name2[i], false, styles);
                }
                return map;
              }
              return value2 !== void 0 ? jQuery3.style(elem, name2, value2) : jQuery3.css(elem, name2);
            }, name, value, arguments.length > 1);
          }
        });
        function Tween(elem, options, prop, end, easing) {
          return new Tween.prototype.init(elem, options, prop, end, easing);
        }
        jQuery3.Tween = Tween;
        Tween.prototype = {
          constructor: Tween,
          init: function(elem, options, prop, end, easing, unit) {
            this.elem = elem;
            this.prop = prop;
            this.easing = easing || jQuery3.easing._default;
            this.options = options;
            this.start = this.now = this.cur();
            this.end = end;
            this.unit = unit || (jQuery3.cssNumber[prop] ? "" : "px");
          },
          cur: function() {
            var hooks = Tween.propHooks[this.prop];
            return hooks && hooks.get ? hooks.get(this) : Tween.propHooks._default.get(this);
          },
          run: function(percent) {
            var eased, hooks = Tween.propHooks[this.prop];
            if (this.options.duration) {
              this.pos = eased = jQuery3.easing[this.easing](percent, this.options.duration * percent, 0, 1, this.options.duration);
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
              result = jQuery3.css(tween.elem, tween.prop, "");
              return !result || result === "auto" ? 0 : result;
            },
            set: function(tween) {
              if (jQuery3.fx.step[tween.prop]) {
                jQuery3.fx.step[tween.prop](tween);
              } else if (tween.elem.nodeType === 1 && (jQuery3.cssHooks[tween.prop] || tween.elem.style[finalPropName(tween.prop)] != null)) {
                jQuery3.style(tween.elem, tween.prop, tween.now + tween.unit);
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
        jQuery3.easing = {
          linear: function(p) {
            return p;
          },
          swing: function(p) {
            return 0.5 - Math.cos(p * Math.PI) / 2;
          },
          _default: "swing"
        };
        jQuery3.fx = Tween.prototype.init;
        jQuery3.fx.step = {};
        var fxNow, inProgress, rfxtypes = /^(?:toggle|show|hide)$/, rrun = /queueHooks$/;
        function schedule() {
          if (inProgress) {
            if (document2.hidden === false && window2.requestAnimationFrame) {
              window2.requestAnimationFrame(schedule);
            } else {
              window2.setTimeout(schedule, jQuery3.fx.interval);
            }
            jQuery3.fx.tick();
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
            hooks = jQuery3._queueHooks(elem, "fx");
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
                if (!jQuery3.queue(elem, "fx").length) {
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
              orig[prop] = dataShow && dataShow[prop] || jQuery3.style(elem, prop);
            }
          }
          propTween = !jQuery3.isEmptyObject(props);
          if (!propTween && jQuery3.isEmptyObject(orig)) {
            return;
          }
          if (isBox && elem.nodeType === 1) {
            opts.overflow = [style.overflow, style.overflowX, style.overflowY];
            restoreDisplay = dataShow && dataShow.display;
            if (restoreDisplay == null) {
              restoreDisplay = dataPriv.get(elem, "display");
            }
            display = jQuery3.css(elem, "display");
            if (display === "none") {
              if (restoreDisplay) {
                display = restoreDisplay;
              } else {
                showHide([elem], true);
                restoreDisplay = elem.style.display || restoreDisplay;
                display = jQuery3.css(elem, "display");
                showHide([elem]);
              }
            }
            if (display === "inline" || display === "inline-block" && restoreDisplay != null) {
              if (jQuery3.css(elem, "float") === "none") {
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
                  jQuery3.style(elem, prop, orig[prop]);
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
            hooks = jQuery3.cssHooks[name];
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
          var result, stopped, index = 0, length = Animation.prefilters.length, deferred = jQuery3.Deferred().always(function() {
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
            props: jQuery3.extend({}, properties),
            opts: jQuery3.extend(true, {
              specialEasing: {},
              easing: jQuery3.easing._default
            }, options),
            originalProperties: properties,
            originalOptions: options,
            startTime: fxNow || createFxNow(),
            duration: options.duration,
            tweens: [],
            createTween: function(prop, end) {
              var tween = jQuery3.Tween(elem, animation.opts, prop, end, animation.opts.specialEasing[prop] || animation.opts.easing);
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
                jQuery3._queueHooks(animation.elem, animation.opts.queue).stop = result.stop.bind(result);
              }
              return result;
            }
          }
          jQuery3.map(props, createTween, animation);
          if (isFunction(animation.opts.start)) {
            animation.opts.start.call(elem, animation);
          }
          animation.progress(animation.opts.progress).done(animation.opts.done, animation.opts.complete).fail(animation.opts.fail).always(animation.opts.always);
          jQuery3.fx.timer(jQuery3.extend(tick, {
            elem,
            anim: animation,
            queue: animation.opts.queue
          }));
          return animation;
        }
        jQuery3.Animation = jQuery3.extend(Animation, {
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
        jQuery3.speed = function(speed, easing, fn) {
          var opt = speed && typeof speed === "object" ? jQuery3.extend({}, speed) : {
            complete: fn || !fn && easing || isFunction(speed) && speed,
            duration: speed,
            easing: fn && easing || easing && !isFunction(easing) && easing
          };
          if (jQuery3.fx.off) {
            opt.duration = 0;
          } else {
            if (typeof opt.duration !== "number") {
              if (opt.duration in jQuery3.fx.speeds) {
                opt.duration = jQuery3.fx.speeds[opt.duration];
              } else {
                opt.duration = jQuery3.fx.speeds._default;
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
              jQuery3.dequeue(this, opt.queue);
            }
          };
          return opt;
        };
        jQuery3.fn.extend({
          fadeTo: function(speed, to, easing, callback) {
            return this.filter(isHiddenWithinTree).css("opacity", 0).show().end().animate({ opacity: to }, speed, easing, callback);
          },
          animate: function(prop, speed, easing, callback) {
            var empty = jQuery3.isEmptyObject(prop), optall = jQuery3.speed(speed, easing, callback), doAnimation = function() {
              var anim = Animation(this, jQuery3.extend({}, prop), optall);
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
              var dequeue = true, index = type != null && type + "queueHooks", timers = jQuery3.timers, data = dataPriv.get(this);
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
                jQuery3.dequeue(this, type);
              }
            });
          },
          finish: function(type) {
            if (type !== false) {
              type = type || "fx";
            }
            return this.each(function() {
              var index, data = dataPriv.get(this), queue = data[type + "queue"], hooks = data[type + "queueHooks"], timers = jQuery3.timers, length = queue ? queue.length : 0;
              data.finish = true;
              jQuery3.queue(this, type, []);
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
        jQuery3.each(["toggle", "show", "hide"], function(_i, name) {
          var cssFn = jQuery3.fn[name];
          jQuery3.fn[name] = function(speed, easing, callback) {
            return speed == null || typeof speed === "boolean" ? cssFn.apply(this, arguments) : this.animate(genFx(name, true), speed, easing, callback);
          };
        });
        jQuery3.each({
          slideDown: genFx("show"),
          slideUp: genFx("hide"),
          slideToggle: genFx("toggle"),
          fadeIn: { opacity: "show" },
          fadeOut: { opacity: "hide" },
          fadeToggle: { opacity: "toggle" }
        }, function(name, props) {
          jQuery3.fn[name] = function(speed, easing, callback) {
            return this.animate(props, speed, easing, callback);
          };
        });
        jQuery3.timers = [];
        jQuery3.fx.tick = function() {
          var timer, i = 0, timers = jQuery3.timers;
          fxNow = Date.now();
          for (; i < timers.length; i++) {
            timer = timers[i];
            if (!timer() && timers[i] === timer) {
              timers.splice(i--, 1);
            }
          }
          if (!timers.length) {
            jQuery3.fx.stop();
          }
          fxNow = void 0;
        };
        jQuery3.fx.timer = function(timer) {
          jQuery3.timers.push(timer);
          jQuery3.fx.start();
        };
        jQuery3.fx.interval = 13;
        jQuery3.fx.start = function() {
          if (inProgress) {
            return;
          }
          inProgress = true;
          schedule();
        };
        jQuery3.fx.stop = function() {
          inProgress = null;
        };
        jQuery3.fx.speeds = {
          slow: 600,
          fast: 200,
          _default: 400
        };
        jQuery3.fn.delay = function(time, type) {
          time = jQuery3.fx ? jQuery3.fx.speeds[time] || time : time;
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
        var boolHook, attrHandle = jQuery3.expr.attrHandle;
        jQuery3.fn.extend({
          attr: function(name, value) {
            return access(this, jQuery3.attr, name, value, arguments.length > 1);
          },
          removeAttr: function(name) {
            return this.each(function() {
              jQuery3.removeAttr(this, name);
            });
          }
        });
        jQuery3.extend({
          attr: function(elem, name, value) {
            var ret, hooks, nType = elem.nodeType;
            if (nType === 3 || nType === 8 || nType === 2) {
              return;
            }
            if (typeof elem.getAttribute === "undefined") {
              return jQuery3.prop(elem, name, value);
            }
            if (nType !== 1 || !jQuery3.isXMLDoc(elem)) {
              hooks = jQuery3.attrHooks[name.toLowerCase()] || (jQuery3.expr.match.bool.test(name) ? boolHook : void 0);
            }
            if (value !== void 0) {
              if (value === null) {
                jQuery3.removeAttr(elem, name);
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
            ret = jQuery3.find.attr(elem, name);
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
              jQuery3.removeAttr(elem, name);
            } else {
              elem.setAttribute(name, name);
            }
            return name;
          }
        };
        jQuery3.each(jQuery3.expr.match.bool.source.match(/\w+/g), function(_i, name) {
          var getter = attrHandle[name] || jQuery3.find.attr;
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
        jQuery3.fn.extend({
          prop: function(name, value) {
            return access(this, jQuery3.prop, name, value, arguments.length > 1);
          },
          removeProp: function(name) {
            return this.each(function() {
              delete this[jQuery3.propFix[name] || name];
            });
          }
        });
        jQuery3.extend({
          prop: function(elem, name, value) {
            var ret, hooks, nType = elem.nodeType;
            if (nType === 3 || nType === 8 || nType === 2) {
              return;
            }
            if (nType !== 1 || !jQuery3.isXMLDoc(elem)) {
              name = jQuery3.propFix[name] || name;
              hooks = jQuery3.propHooks[name];
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
                var tabindex = jQuery3.find.attr(elem, "tabindex");
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
          jQuery3.propHooks.selected = {
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
        jQuery3.each([
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
          jQuery3.propFix[this.toLowerCase()] = this;
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
        jQuery3.fn.extend({
          addClass: function(value) {
            var classes, elem, cur, curValue, clazz, j, finalValue, i = 0;
            if (isFunction(value)) {
              return this.each(function(j2) {
                jQuery3(this).addClass(value.call(this, j2, getClass(this)));
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
                jQuery3(this).removeClass(value.call(this, j2, getClass(this)));
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
                jQuery3(this).toggleClass(value.call(this, i, getClass(this), stateVal), stateVal);
              });
            }
            return this.each(function() {
              var className, i, self2, classNames;
              if (isValidValue) {
                i = 0;
                self2 = jQuery3(this);
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
        jQuery3.fn.extend({
          val: function(value) {
            var hooks, ret, valueIsFunction, elem = this[0];
            if (!arguments.length) {
              if (elem) {
                hooks = jQuery3.valHooks[elem.type] || jQuery3.valHooks[elem.nodeName.toLowerCase()];
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
                val = value.call(this, i, jQuery3(this).val());
              } else {
                val = value;
              }
              if (val == null) {
                val = "";
              } else if (typeof val === "number") {
                val += "";
              } else if (Array.isArray(val)) {
                val = jQuery3.map(val, function(value2) {
                  return value2 == null ? "" : value2 + "";
                });
              }
              hooks = jQuery3.valHooks[this.type] || jQuery3.valHooks[this.nodeName.toLowerCase()];
              if (!hooks || !("set" in hooks) || hooks.set(this, val, "value") === void 0) {
                this.value = val;
              }
            });
          }
        });
        jQuery3.extend({
          valHooks: {
            option: {
              get: function(elem) {
                var val = jQuery3.find.attr(elem, "value");
                return val != null ? val : stripAndCollapse(jQuery3.text(elem));
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
                    value = jQuery3(option).val();
                    if (one) {
                      return value;
                    }
                    values.push(value);
                  }
                }
                return values;
              },
              set: function(elem, value) {
                var optionSet, option, options = elem.options, values = jQuery3.makeArray(value), i = options.length;
                while (i--) {
                  option = options[i];
                  if (option.selected = jQuery3.inArray(jQuery3.valHooks.option.get(option), values) > -1) {
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
        jQuery3.each(["radio", "checkbox"], function() {
          jQuery3.valHooks[this] = {
            set: function(elem, value) {
              if (Array.isArray(value)) {
                return elem.checked = jQuery3.inArray(jQuery3(elem).val(), value) > -1;
              }
            }
          };
          if (!support.checkOn) {
            jQuery3.valHooks[this].get = function(elem) {
              return elem.getAttribute("value") === null ? "on" : elem.value;
            };
          }
        });
        support.focusin = "onfocusin" in window2;
        var rfocusMorph = /^(?:focusinfocus|focusoutblur)$/, stopPropagationCallback = function(e) {
          e.stopPropagation();
        };
        jQuery3.extend(jQuery3.event, {
          trigger: function(event, data, elem, onlyHandlers) {
            var i, cur, tmp, bubbleType, ontype, handle, special, lastElement, eventPath = [elem || document2], type = hasOwn.call(event, "type") ? event.type : event, namespaces = hasOwn.call(event, "namespace") ? event.namespace.split(".") : [];
            cur = lastElement = tmp = elem = elem || document2;
            if (elem.nodeType === 3 || elem.nodeType === 8) {
              return;
            }
            if (rfocusMorph.test(type + jQuery3.event.triggered)) {
              return;
            }
            if (type.indexOf(".") > -1) {
              namespaces = type.split(".");
              type = namespaces.shift();
              namespaces.sort();
            }
            ontype = type.indexOf(":") < 0 && "on" + type;
            event = event[jQuery3.expando] ? event : new jQuery3.Event(type, typeof event === "object" && event);
            event.isTrigger = onlyHandlers ? 2 : 3;
            event.namespace = namespaces.join(".");
            event.rnamespace = event.namespace ? new RegExp("(^|\\.)" + namespaces.join("\\.(?:.*\\.|)") + "(\\.|$)") : null;
            event.result = void 0;
            if (!event.target) {
              event.target = elem;
            }
            data = data == null ? [event] : jQuery3.makeArray(data, [event]);
            special = jQuery3.event.special[type] || {};
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
                  jQuery3.event.triggered = type;
                  if (event.isPropagationStopped()) {
                    lastElement.addEventListener(type, stopPropagationCallback);
                  }
                  elem[type]();
                  if (event.isPropagationStopped()) {
                    lastElement.removeEventListener(type, stopPropagationCallback);
                  }
                  jQuery3.event.triggered = void 0;
                  if (tmp) {
                    elem[ontype] = tmp;
                  }
                }
              }
            }
            return event.result;
          },
          simulate: function(type, elem, event) {
            var e = jQuery3.extend(new jQuery3.Event(), event, {
              type,
              isSimulated: true
            });
            jQuery3.event.trigger(e, null, elem);
          }
        });
        jQuery3.fn.extend({
          trigger: function(type, data) {
            return this.each(function() {
              jQuery3.event.trigger(type, data, this);
            });
          },
          triggerHandler: function(type, data) {
            var elem = this[0];
            if (elem) {
              return jQuery3.event.trigger(type, data, elem, true);
            }
          }
        });
        if (!support.focusin) {
          jQuery3.each({ focus: "focusin", blur: "focusout" }, function(orig, fix) {
            var handler = function(event) {
              jQuery3.event.simulate(fix, event.target, jQuery3.event.fix(event));
            };
            jQuery3.event.special[fix] = {
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
        jQuery3.parseXML = function(data) {
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
            jQuery3.error("Invalid XML: " + (parserErrorElem ? jQuery3.map(parserErrorElem.childNodes, function(el) {
              return el.textContent;
            }).join("\n") : data));
          }
          return xml;
        };
        var rbracket = /\[\]$/, rCRLF = /\r?\n/g, rsubmitterTypes = /^(?:submit|button|image|reset|file)$/i, rsubmittable = /^(?:input|select|textarea|keygen)/i;
        function buildParams(prefix, obj, traditional, add) {
          var name;
          if (Array.isArray(obj)) {
            jQuery3.each(obj, function(i, v) {
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
        jQuery3.param = function(a, traditional) {
          var prefix, s = [], add = function(key, valueOrFunction) {
            var value = isFunction(valueOrFunction) ? valueOrFunction() : valueOrFunction;
            s[s.length] = encodeURIComponent(key) + "=" + encodeURIComponent(value == null ? "" : value);
          };
          if (a == null) {
            return "";
          }
          if (Array.isArray(a) || a.jquery && !jQuery3.isPlainObject(a)) {
            jQuery3.each(a, function() {
              add(this.name, this.value);
            });
          } else {
            for (prefix in a) {
              buildParams(prefix, a[prefix], traditional, add);
            }
          }
          return s.join("&");
        };
        jQuery3.fn.extend({
          serialize: function() {
            return jQuery3.param(this.serializeArray());
          },
          serializeArray: function() {
            return this.map(function() {
              var elements = jQuery3.prop(this, "elements");
              return elements ? jQuery3.makeArray(elements) : this;
            }).filter(function() {
              var type = this.type;
              return this.name && !jQuery3(this).is(":disabled") && rsubmittable.test(this.nodeName) && !rsubmitterTypes.test(type) && (this.checked || !rcheckableType.test(type));
            }).map(function(_i, elem) {
              var val = jQuery3(this).val();
              if (val == null) {
                return null;
              }
              if (Array.isArray(val)) {
                return jQuery3.map(val, function(val2) {
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
            jQuery3.each(structure[dataType] || [], function(_, prefilterOrFactory) {
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
          var key, deep, flatOptions = jQuery3.ajaxSettings.flatOptions || {};
          for (key in src) {
            if (src[key] !== void 0) {
              (flatOptions[key] ? target : deep || (deep = {}))[key] = src[key];
            }
          }
          if (deep) {
            jQuery3.extend(true, target, deep);
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
          var conv2, current2, conv, tmp, prev, converters = {}, dataTypes = s.dataTypes.slice();
          if (dataTypes[1]) {
            for (conv in s.converters) {
              converters[conv.toLowerCase()] = s.converters[conv];
            }
          }
          current2 = dataTypes.shift();
          while (current2) {
            if (s.responseFields[current2]) {
              jqXHR[s.responseFields[current2]] = response;
            }
            if (!prev && isSuccess && s.dataFilter) {
              response = s.dataFilter(response, s.dataType);
            }
            prev = current2;
            current2 = dataTypes.shift();
            if (current2) {
              if (current2 === "*") {
                current2 = prev;
              } else if (prev !== "*" && prev !== current2) {
                conv = converters[prev + " " + current2] || converters["* " + current2];
                if (!conv) {
                  for (conv2 in converters) {
                    tmp = conv2.split(" ");
                    if (tmp[1] === current2) {
                      conv = converters[prev + " " + tmp[0]] || converters["* " + tmp[0]];
                      if (conv) {
                        if (conv === true) {
                          conv = converters[conv2];
                        } else if (converters[conv2] !== true) {
                          current2 = tmp[0];
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
                        error: conv ? e : "No conversion from " + prev + " to " + current2
                      };
                    }
                  }
                }
              }
            }
          }
          return { state: "success", data: response };
        }
        jQuery3.extend({
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
              "text xml": jQuery3.parseXML
            },
            flatOptions: {
              url: true,
              context: true
            }
          },
          ajaxSetup: function(target, settings) {
            return settings ? ajaxExtend(ajaxExtend(target, jQuery3.ajaxSettings), settings) : ajaxExtend(jQuery3.ajaxSettings, target);
          },
          ajaxPrefilter: addToPrefiltersOrTransports(prefilters),
          ajaxTransport: addToPrefiltersOrTransports(transports),
          ajax: function(url, options) {
            if (typeof url === "object") {
              options = url;
              url = void 0;
            }
            options = options || {};
            var transport, cacheURL, responseHeadersString, responseHeaders, timeoutTimer, urlAnchor, completed2, fireGlobals, i, uncached, s = jQuery3.ajaxSetup({}, options), callbackContext = s.context || s, globalEventContext = s.context && (callbackContext.nodeType || callbackContext.jquery) ? jQuery3(callbackContext) : jQuery3.event, deferred = jQuery3.Deferred(), completeDeferred = jQuery3.Callbacks("once memory"), statusCode = s.statusCode || {}, requestHeaders = {}, requestHeadersNames = {}, strAbort = "canceled", jqXHR = {
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
              s.data = jQuery3.param(s.data, s.traditional);
            }
            inspectPrefiltersOrTransports(prefilters, s, options, jqXHR);
            if (completed2) {
              return jqXHR;
            }
            fireGlobals = jQuery3.event && s.global;
            if (fireGlobals && jQuery3.active++ === 0) {
              jQuery3.event.trigger("ajaxStart");
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
              if (jQuery3.lastModified[cacheURL]) {
                jqXHR.setRequestHeader("If-Modified-Since", jQuery3.lastModified[cacheURL]);
              }
              if (jQuery3.etag[cacheURL]) {
                jqXHR.setRequestHeader("If-None-Match", jQuery3.etag[cacheURL]);
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
              if (!isSuccess && jQuery3.inArray("script", s.dataTypes) > -1 && jQuery3.inArray("json", s.dataTypes) < 0) {
                s.converters["text script"] = function() {
                };
              }
              response = ajaxConvert(s, response, jqXHR, isSuccess);
              if (isSuccess) {
                if (s.ifModified) {
                  modified = jqXHR.getResponseHeader("Last-Modified");
                  if (modified) {
                    jQuery3.lastModified[cacheURL] = modified;
                  }
                  modified = jqXHR.getResponseHeader("etag");
                  if (modified) {
                    jQuery3.etag[cacheURL] = modified;
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
                if (!--jQuery3.active) {
                  jQuery3.event.trigger("ajaxStop");
                }
              }
            }
            return jqXHR;
          },
          getJSON: function(url, data, callback) {
            return jQuery3.get(url, data, callback, "json");
          },
          getScript: function(url, callback) {
            return jQuery3.get(url, void 0, callback, "script");
          }
        });
        jQuery3.each(["get", "post"], function(_i, method) {
          jQuery3[method] = function(url, data, callback, type) {
            if (isFunction(data)) {
              type = type || callback;
              callback = data;
              data = void 0;
            }
            return jQuery3.ajax(jQuery3.extend({
              url,
              type: method,
              dataType: type,
              data,
              success: callback
            }, jQuery3.isPlainObject(url) && url));
          };
        });
        jQuery3.ajaxPrefilter(function(s) {
          var i;
          for (i in s.headers) {
            if (i.toLowerCase() === "content-type") {
              s.contentType = s.headers[i] || "";
            }
          }
        });
        jQuery3._evalUrl = function(url, options, doc) {
          return jQuery3.ajax({
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
              jQuery3.globalEval(response, options, doc);
            }
          });
        };
        jQuery3.fn.extend({
          wrapAll: function(html) {
            var wrap;
            if (this[0]) {
              if (isFunction(html)) {
                html = html.call(this[0]);
              }
              wrap = jQuery3(html, this[0].ownerDocument).eq(0).clone(true);
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
                jQuery3(this).wrapInner(html.call(this, i));
              });
            }
            return this.each(function() {
              var self2 = jQuery3(this), contents = self2.contents();
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
              jQuery3(this).wrapAll(htmlIsFunction ? html.call(this, i) : html);
            });
          },
          unwrap: function(selector) {
            this.parent(selector).not("body").each(function() {
              jQuery3(this).replaceWith(this.childNodes);
            });
            return this;
          }
        });
        jQuery3.expr.pseudos.hidden = function(elem) {
          return !jQuery3.expr.pseudos.visible(elem);
        };
        jQuery3.expr.pseudos.visible = function(elem) {
          return !!(elem.offsetWidth || elem.offsetHeight || elem.getClientRects().length);
        };
        jQuery3.ajaxSettings.xhr = function() {
          try {
            return new window2.XMLHttpRequest();
          } catch (e) {
          }
        };
        var xhrSuccessStatus = {
          0: 200,
          1223: 204
        }, xhrSupported = jQuery3.ajaxSettings.xhr();
        support.cors = !!xhrSupported && "withCredentials" in xhrSupported;
        support.ajax = xhrSupported = !!xhrSupported;
        jQuery3.ajaxTransport(function(options) {
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
        jQuery3.ajaxPrefilter(function(s) {
          if (s.crossDomain) {
            s.contents.script = false;
          }
        });
        jQuery3.ajaxSetup({
          accepts: {
            script: "text/javascript, application/javascript, application/ecmascript, application/x-ecmascript"
          },
          contents: {
            script: /\b(?:java|ecma)script\b/
          },
          converters: {
            "text script": function(text) {
              jQuery3.globalEval(text);
              return text;
            }
          }
        });
        jQuery3.ajaxPrefilter("script", function(s) {
          if (s.cache === void 0) {
            s.cache = false;
          }
          if (s.crossDomain) {
            s.type = "GET";
          }
        });
        jQuery3.ajaxTransport("script", function(s) {
          if (s.crossDomain || s.scriptAttrs) {
            var script, callback;
            return {
              send: function(_, complete) {
                script = jQuery3("<script>").attr(s.scriptAttrs || {}).prop({ charset: s.scriptCharset, src: s.url }).on("load error", callback = function(evt) {
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
        jQuery3.ajaxSetup({
          jsonp: "callback",
          jsonpCallback: function() {
            var callback = oldCallbacks.pop() || jQuery3.expando + "_" + nonce.guid++;
            this[callback] = true;
            return callback;
          }
        });
        jQuery3.ajaxPrefilter("json jsonp", function(s, originalSettings, jqXHR) {
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
                jQuery3.error(callbackName + " was not called");
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
                jQuery3(window2).removeProp(callbackName);
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
        jQuery3.parseHTML = function(data, context, keepScripts) {
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
            jQuery3(scripts).remove();
          }
          return jQuery3.merge([], parsed.childNodes);
        };
        jQuery3.fn.load = function(url, params, callback) {
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
            jQuery3.ajax({
              url,
              type: type || "GET",
              dataType: "html",
              data: params
            }).done(function(responseText) {
              response = arguments;
              self2.html(selector ? jQuery3("<div>").append(jQuery3.parseHTML(responseText)).find(selector) : responseText);
            }).always(callback && function(jqXHR, status) {
              self2.each(function() {
                callback.apply(this, response || [jqXHR.responseText, status, jqXHR]);
              });
            });
          }
          return this;
        };
        jQuery3.expr.pseudos.animated = function(elem) {
          return jQuery3.grep(jQuery3.timers, function(fn) {
            return elem === fn.elem;
          }).length;
        };
        jQuery3.offset = {
          setOffset: function(elem, options, i) {
            var curPosition, curLeft, curCSSTop, curTop, curOffset, curCSSLeft, calculatePosition, position = jQuery3.css(elem, "position"), curElem = jQuery3(elem), props = {};
            if (position === "static") {
              elem.style.position = "relative";
            }
            curOffset = curElem.offset();
            curCSSTop = jQuery3.css(elem, "top");
            curCSSLeft = jQuery3.css(elem, "left");
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
              options = options.call(elem, i, jQuery3.extend({}, curOffset));
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
        jQuery3.fn.extend({
          offset: function(options) {
            if (arguments.length) {
              return options === void 0 ? this : this.each(function(i) {
                jQuery3.offset.setOffset(this, options, i);
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
            if (jQuery3.css(elem, "position") === "fixed") {
              offset = elem.getBoundingClientRect();
            } else {
              offset = this.offset();
              doc = elem.ownerDocument;
              offsetParent = elem.offsetParent || doc.documentElement;
              while (offsetParent && (offsetParent === doc.body || offsetParent === doc.documentElement) && jQuery3.css(offsetParent, "position") === "static") {
                offsetParent = offsetParent.parentNode;
              }
              if (offsetParent && offsetParent !== elem && offsetParent.nodeType === 1) {
                parentOffset = jQuery3(offsetParent).offset();
                parentOffset.top += jQuery3.css(offsetParent, "borderTopWidth", true);
                parentOffset.left += jQuery3.css(offsetParent, "borderLeftWidth", true);
              }
            }
            return {
              top: offset.top - parentOffset.top - jQuery3.css(elem, "marginTop", true),
              left: offset.left - parentOffset.left - jQuery3.css(elem, "marginLeft", true)
            };
          },
          offsetParent: function() {
            return this.map(function() {
              var offsetParent = this.offsetParent;
              while (offsetParent && jQuery3.css(offsetParent, "position") === "static") {
                offsetParent = offsetParent.offsetParent;
              }
              return offsetParent || documentElement;
            });
          }
        });
        jQuery3.each({ scrollLeft: "pageXOffset", scrollTop: "pageYOffset" }, function(method, prop) {
          var top = prop === "pageYOffset";
          jQuery3.fn[method] = function(val) {
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
        jQuery3.each(["top", "left"], function(_i, prop) {
          jQuery3.cssHooks[prop] = addGetHookIf(support.pixelPosition, function(elem, computed) {
            if (computed) {
              computed = curCSS(elem, prop);
              return rnumnonpx.test(computed) ? jQuery3(elem).position()[prop] + "px" : computed;
            }
          });
        });
        jQuery3.each({ Height: "height", Width: "width" }, function(name, type) {
          jQuery3.each({
            padding: "inner" + name,
            content: type,
            "": "outer" + name
          }, function(defaultExtra, funcName) {
            jQuery3.fn[funcName] = function(margin, value) {
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
                return value2 === void 0 ? jQuery3.css(elem, type2, extra) : jQuery3.style(elem, type2, value2, extra);
              }, type, chainable ? margin : void 0, chainable);
            };
          });
        });
        jQuery3.each([
          "ajaxStart",
          "ajaxStop",
          "ajaxComplete",
          "ajaxError",
          "ajaxSuccess",
          "ajaxSend"
        ], function(_i, type) {
          jQuery3.fn[type] = function(fn) {
            return this.on(type, fn);
          };
        });
        jQuery3.fn.extend({
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
        jQuery3.each("blur focus focusin focusout resize scroll click dblclick mousedown mouseup mousemove mouseover mouseout mouseenter mouseleave change select submit keydown keypress keyup contextmenu".split(" "), function(_i, name) {
          jQuery3.fn[name] = function(data, fn) {
            return arguments.length > 0 ? this.on(name, null, data, fn) : this.trigger(name);
          };
        });
        var rtrim = /^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g;
        jQuery3.proxy = function(fn, context) {
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
          proxy.guid = fn.guid = fn.guid || jQuery3.guid++;
          return proxy;
        };
        jQuery3.holdReady = function(hold) {
          if (hold) {
            jQuery3.readyWait++;
          } else {
            jQuery3.ready(true);
          }
        };
        jQuery3.isArray = Array.isArray;
        jQuery3.parseJSON = JSON.parse;
        jQuery3.nodeName = nodeName;
        jQuery3.isFunction = isFunction;
        jQuery3.isWindow = isWindow;
        jQuery3.camelCase = camelCase;
        jQuery3.type = toType;
        jQuery3.now = Date.now;
        jQuery3.isNumeric = function(obj) {
          var type = jQuery3.type(obj);
          return (type === "number" || type === "string") && !isNaN(obj - parseFloat(obj));
        };
        jQuery3.trim = function(text) {
          return text == null ? "" : (text + "").replace(rtrim, "");
        };
        if (typeof define === "function" && define.amd) {
          define("jquery", [], function() {
            return jQuery3;
          });
        }
        var _jQuery = window2.jQuery, _$ = window2.$;
        jQuery3.noConflict = function(deep) {
          if (window2.$ === jQuery3) {
            window2.$ = _$;
          }
          if (deep && window2.jQuery === jQuery3) {
            window2.jQuery = _jQuery;
          }
          return jQuery3;
        };
        if (typeof noGlobal === "undefined") {
          window2.jQuery = window2.$ = jQuery3;
        }
        return jQuery3;
      });
    }
  });

  // node_modules/jquery-ujs/src/rails.js
  var require_rails = __commonJS({
    "node_modules/jquery-ujs/src/rails.js"(exports, module) {
      (function() {
        "use strict";
        var jqueryUjsInit = function($2, undefined2) {
          if ($2.rails !== undefined2) {
            $2.error("jquery-ujs has already been loaded!");
          }
          var rails;
          var $document = $2(document);
          $2.rails = rails = {
            linkClickSelector: "a[data-confirm], a[data-method], a[data-remote]:not([disabled]), a[data-disable-with], a[data-disable]",
            buttonClickSelector: "button[data-remote]:not([form]):not(form button), button[data-confirm]:not([form]):not(form button)",
            inputChangeSelector: "select[data-remote], input[data-remote], textarea[data-remote]",
            formSubmitSelector: "form:not([data-turbo=true])",
            formInputClickSelector: "form:not([data-turbo=true]) input[type=submit], form:not([data-turbo=true]) input[type=image], form:not([data-turbo=true]) button[type=submit], form:not([data-turbo=true]) button:not([type]), input[type=submit][form], input[type=image][form], button[type=submit][form], button[form]:not([type])",
            disableSelector: "input[data-disable-with]:enabled, button[data-disable-with]:enabled, textarea[data-disable-with]:enabled, input[data-disable]:enabled, button[data-disable]:enabled, textarea[data-disable]:enabled",
            enableSelector: "input[data-disable-with]:disabled, button[data-disable-with]:disabled, textarea[data-disable-with]:disabled, input[data-disable]:disabled, button[data-disable]:disabled, textarea[data-disable]:disabled",
            requiredInputSelector: "input[name][required]:not([disabled]), textarea[name][required]:not([disabled])",
            fileInputSelector: "input[name][type=file]:not([disabled])",
            linkDisableSelector: "a[data-disable-with], a[data-disable]",
            buttonDisableSelector: "button[data-remote][data-disable-with], button[data-remote][data-disable]",
            csrfToken: function() {
              return $2("meta[name=csrf-token]").attr("content");
            },
            csrfParam: function() {
              return $2("meta[name=csrf-param]").attr("content");
            },
            CSRFProtection: function(xhr) {
              var token = rails.csrfToken();
              if (token)
                xhr.setRequestHeader("X-CSRF-Token", token);
            },
            refreshCSRFTokens: function() {
              $2('form input[name="' + rails.csrfParam() + '"]').val(rails.csrfToken());
            },
            fire: function(obj, name, data) {
              var event = $2.Event(name);
              obj.trigger(event, data);
              return event.result !== false;
            },
            confirm: function(message) {
              return confirm(message);
            },
            ajax: function(options) {
              return $2.ajax(options);
            },
            href: function(element) {
              return element[0].href;
            },
            isRemote: function(element) {
              return element.data("remote") !== undefined2 && element.data("remote") !== false;
            },
            handleRemote: function(element) {
              var method, url, data, withCredentials, dataType, options;
              if (rails.fire(element, "ajax:before")) {
                withCredentials = element.data("with-credentials") || null;
                dataType = element.data("type") || $2.ajaxSettings && $2.ajaxSettings.dataType;
                if (element.is("form")) {
                  method = element.data("ujs:submit-button-formmethod") || element.attr("method");
                  url = element.data("ujs:submit-button-formaction") || element.attr("action");
                  data = $2(element[0]).serializeArray();
                  var button = element.data("ujs:submit-button");
                  if (button) {
                    data.push(button);
                    element.data("ujs:submit-button", null);
                  }
                  element.data("ujs:submit-button-formmethod", null);
                  element.data("ujs:submit-button-formaction", null);
                } else if (element.is(rails.inputChangeSelector)) {
                  method = element.data("method");
                  url = element.data("url");
                  data = element.serialize();
                  if (element.data("params"))
                    data = data + "&" + element.data("params");
                } else if (element.is(rails.buttonClickSelector)) {
                  method = element.data("method") || "get";
                  url = element.data("url");
                  data = element.serialize();
                  if (element.data("params"))
                    data = data + "&" + element.data("params");
                } else {
                  method = element.data("method");
                  url = rails.href(element);
                  data = element.data("params") || null;
                }
                options = {
                  type: method || "GET",
                  data,
                  dataType,
                  beforeSend: function(xhr, settings) {
                    if (settings.dataType === undefined2) {
                      xhr.setRequestHeader("accept", "*/*;q=0.5, " + settings.accepts.script);
                    }
                    if (rails.fire(element, "ajax:beforeSend", [xhr, settings])) {
                      element.trigger("ajax:send", xhr);
                    } else {
                      return false;
                    }
                  },
                  success: function(data2, status, xhr) {
                    element.trigger("ajax:success", [data2, status, xhr]);
                  },
                  complete: function(xhr, status) {
                    element.trigger("ajax:complete", [xhr, status]);
                  },
                  error: function(xhr, status, error) {
                    element.trigger("ajax:error", [xhr, status, error]);
                  },
                  crossDomain: rails.isCrossDomain(url)
                };
                if (withCredentials) {
                  options.xhrFields = {
                    withCredentials
                  };
                }
                if (url) {
                  options.url = url;
                }
                return rails.ajax(options);
              } else {
                return false;
              }
            },
            isCrossDomain: function(url) {
              var originAnchor = document.createElement("a");
              originAnchor.href = location.href;
              var urlAnchor = document.createElement("a");
              try {
                urlAnchor.href = url;
                urlAnchor.href = urlAnchor.href;
                return !((!urlAnchor.protocol || urlAnchor.protocol === ":") && !urlAnchor.host || originAnchor.protocol + "//" + originAnchor.host === urlAnchor.protocol + "//" + urlAnchor.host);
              } catch (e) {
                return true;
              }
            },
            handleMethod: function(link) {
              var href = rails.href(link), method = link.data("method"), target = link.attr("target"), csrfToken = rails.csrfToken(), csrfParam = rails.csrfParam(), form = $2('<form method="post" action="' + href + '"></form>'), metadataInput = '<input name="_method" value="' + method + '" type="hidden" />';
              if (csrfParam !== undefined2 && csrfToken !== undefined2 && !rails.isCrossDomain(href)) {
                metadataInput += '<input name="' + csrfParam + '" value="' + csrfToken + '" type="hidden" />';
              }
              if (target) {
                form.attr("target", target);
              }
              form.hide().append(metadataInput).appendTo("body");
              form.submit();
            },
            formElements: function(form, selector) {
              return form.is("form") ? $2(form[0].elements).filter(selector) : form.find(selector);
            },
            disableFormElements: function(form) {
              rails.formElements(form, rails.disableSelector).each(function() {
                rails.disableFormElement($2(this));
              });
            },
            disableFormElement: function(element) {
              var method, replacement;
              method = element.is("button") ? "html" : "val";
              replacement = element.data("disable-with");
              if (replacement !== undefined2) {
                element.data("ujs:enable-with", element[method]());
                element[method](replacement);
              }
              element.prop("disabled", true);
              element.data("ujs:disabled", true);
            },
            enableFormElements: function(form) {
              rails.formElements(form, rails.enableSelector).each(function() {
                rails.enableFormElement($2(this));
              });
            },
            enableFormElement: function(element) {
              var method = element.is("button") ? "html" : "val";
              if (element.data("ujs:enable-with") !== undefined2) {
                element[method](element.data("ujs:enable-with"));
                element.removeData("ujs:enable-with");
              }
              element.prop("disabled", false);
              element.removeData("ujs:disabled");
            },
            allowAction: function(element) {
              var message = element.data("confirm"), answer = false, callback;
              if (!message) {
                return true;
              }
              if (rails.fire(element, "confirm")) {
                try {
                  answer = rails.confirm(message);
                } catch (e) {
                  (console.error || console.log).call(console, e.stack || e);
                }
                callback = rails.fire(element, "confirm:complete", [answer]);
              }
              return answer && callback;
            },
            blankInputs: function(form, specifiedSelector, nonBlank) {
              var foundInputs = $2(), input, valueToCheck, radiosForNameWithNoneSelected, radioName, selector = specifiedSelector || "input,textarea", requiredInputs = form.find(selector), checkedRadioButtonNames = {};
              requiredInputs.each(function() {
                input = $2(this);
                if (input.is("input[type=radio]")) {
                  radioName = input.attr("name");
                  if (!checkedRadioButtonNames[radioName]) {
                    if (form.find('input[type=radio]:checked[name="' + radioName + '"]').length === 0) {
                      radiosForNameWithNoneSelected = form.find('input[type=radio][name="' + radioName + '"]');
                      foundInputs = foundInputs.add(radiosForNameWithNoneSelected);
                    }
                    checkedRadioButtonNames[radioName] = radioName;
                  }
                } else {
                  valueToCheck = input.is("input[type=checkbox],input[type=radio]") ? input.is(":checked") : !!input.val();
                  if (valueToCheck === nonBlank) {
                    foundInputs = foundInputs.add(input);
                  }
                }
              });
              return foundInputs.length ? foundInputs : false;
            },
            nonBlankInputs: function(form, specifiedSelector) {
              return rails.blankInputs(form, specifiedSelector, true);
            },
            stopEverything: function(e) {
              $2(e.target).trigger("ujs:everythingStopped");
              e.stopImmediatePropagation();
              return false;
            },
            disableElement: function(element) {
              var replacement = element.data("disable-with");
              if (replacement !== undefined2) {
                element.data("ujs:enable-with", element.html());
                element.html(replacement);
              }
              element.on("click.railsDisable", function(e) {
                return rails.stopEverything(e);
              });
              element.data("ujs:disabled", true);
            },
            enableElement: function(element) {
              if (element.data("ujs:enable-with") !== undefined2) {
                element.html(element.data("ujs:enable-with"));
                element.removeData("ujs:enable-with");
              }
              element.off("click.railsDisable");
              element.removeData("ujs:disabled");
            }
          };
          if (rails.fire($document, "rails:attachBindings")) {
            $2.ajaxPrefilter(function(options, originalOptions, xhr) {
              if (!options.crossDomain) {
                rails.CSRFProtection(xhr);
              }
            });
            $2(window).on("pageshow.rails", function() {
              $2($2.rails.enableSelector).each(function() {
                var element = $2(this);
                if (element.data("ujs:disabled")) {
                  $2.rails.enableFormElement(element);
                }
              });
              $2($2.rails.linkDisableSelector).each(function() {
                var element = $2(this);
                if (element.data("ujs:disabled")) {
                  $2.rails.enableElement(element);
                }
              });
            });
            $document.on("ajax:complete", rails.linkDisableSelector, function() {
              rails.enableElement($2(this));
            });
            $document.on("ajax:complete", rails.buttonDisableSelector, function() {
              rails.enableFormElement($2(this));
            });
            $document.on("click.rails", rails.linkClickSelector, function(e) {
              var link = $2(this), method = link.data("method"), data = link.data("params"), metaClick = e.metaKey || e.ctrlKey;
              if (!rails.allowAction(link))
                return rails.stopEverything(e);
              if (!metaClick && link.is(rails.linkDisableSelector))
                rails.disableElement(link);
              if (rails.isRemote(link)) {
                if (metaClick && (!method || method === "GET") && !data) {
                  return true;
                }
                var handleRemote = rails.handleRemote(link);
                if (handleRemote === false) {
                  rails.enableElement(link);
                } else {
                  handleRemote.fail(function() {
                    rails.enableElement(link);
                  });
                }
                return false;
              } else if (method) {
                rails.handleMethod(link);
                return false;
              }
            });
            $document.on("click.rails", rails.buttonClickSelector, function(e) {
              var button = $2(this);
              if (!rails.allowAction(button) || !rails.isRemote(button))
                return rails.stopEverything(e);
              if (button.is(rails.buttonDisableSelector))
                rails.disableFormElement(button);
              var handleRemote = rails.handleRemote(button);
              if (handleRemote === false) {
                rails.enableFormElement(button);
              } else {
                handleRemote.fail(function() {
                  rails.enableFormElement(button);
                });
              }
              return false;
            });
            $document.on("change.rails", rails.inputChangeSelector, function(e) {
              var link = $2(this);
              if (!rails.allowAction(link) || !rails.isRemote(link))
                return rails.stopEverything(e);
              rails.handleRemote(link);
              return false;
            });
            $document.on("submit.rails", rails.formSubmitSelector, function(e) {
              var form = $2(this), remote = rails.isRemote(form), blankRequiredInputs, nonBlankFileInputs;
              if (!rails.allowAction(form))
                return rails.stopEverything(e);
              if (form.attr("novalidate") === undefined2) {
                if (form.data("ujs:formnovalidate-button") === undefined2) {
                  blankRequiredInputs = rails.blankInputs(form, rails.requiredInputSelector, false);
                  if (blankRequiredInputs && rails.fire(form, "ajax:aborted:required", [blankRequiredInputs])) {
                    return rails.stopEverything(e);
                  }
                } else {
                  form.data("ujs:formnovalidate-button", undefined2);
                }
              }
              if (remote) {
                nonBlankFileInputs = rails.nonBlankInputs(form, rails.fileInputSelector);
                if (nonBlankFileInputs) {
                  setTimeout(function() {
                    rails.disableFormElements(form);
                  }, 13);
                  var aborted = rails.fire(form, "ajax:aborted:file", [nonBlankFileInputs]);
                  if (!aborted) {
                    setTimeout(function() {
                      rails.enableFormElements(form);
                    }, 13);
                  }
                  return aborted;
                }
                rails.handleRemote(form);
                return false;
              } else {
                setTimeout(function() {
                  rails.disableFormElements(form);
                }, 13);
              }
            });
            $document.on("click.rails", rails.formInputClickSelector, function(event) {
              var button = $2(this);
              if (!rails.allowAction(button))
                return rails.stopEverything(event);
              var name = button.attr("name"), data = name ? { name, value: button.val() } : null;
              var form = button.closest("form");
              if (form.length === 0) {
                form = $2("#" + button.attr("form"));
              }
              form.data("ujs:submit-button", data);
              form.data("ujs:formnovalidate-button", button.attr("formnovalidate"));
              form.data("ujs:submit-button-formaction", button.attr("formaction"));
              form.data("ujs:submit-button-formmethod", button.attr("formmethod"));
            });
            $document.on("ajax:send.rails", rails.formSubmitSelector, function(event) {
              if (this === event.target)
                rails.disableFormElements($2(this));
            });
            $document.on("ajax:complete.rails", rails.formSubmitSelector, function(event) {
              if (this === event.target)
                rails.enableFormElements($2(this));
            });
            $2(function() {
              rails.refreshCSRFTokens();
            });
          }
        };
        if (window.jQuery) {
          jqueryUjsInit(jQuery);
        } else if (typeof exports === "object" && typeof module === "object") {
          module.exports = jqueryUjsInit;
        }
      })();
    }
  });

  // node_modules/@rails/ujs/lib/assets/compiled/rails-ujs.js
  var require_rails_ujs = __commonJS({
    "node_modules/@rails/ujs/lib/assets/compiled/rails-ujs.js"(exports, module) {
      (function() {
        var context = this;
        (function() {
          (function() {
            this.Rails = {
              linkClickSelector: "a[data-confirm], a[data-method], a[data-remote]:not([disabled]), a[data-disable-with], a[data-disable]",
              buttonClickSelector: {
                selector: "button[data-remote]:not([form]), button[data-confirm]:not([form])",
                exclude: "form button"
              },
              inputChangeSelector: "select[data-remote], input[data-remote], textarea[data-remote]",
              formSubmitSelector: "form:not([data-turbo=true])",
              formInputClickSelector: "form:not([data-turbo=true]) input[type=submit], form:not([data-turbo=true]) input[type=image], form:not([data-turbo=true]) button[type=submit], form:not([data-turbo=true]) button:not([type]), input[type=submit][form], input[type=image][form], button[type=submit][form], button[form]:not([type])",
              formDisableSelector: "input[data-disable-with]:enabled, button[data-disable-with]:enabled, textarea[data-disable-with]:enabled, input[data-disable]:enabled, button[data-disable]:enabled, textarea[data-disable]:enabled",
              formEnableSelector: "input[data-disable-with]:disabled, button[data-disable-with]:disabled, textarea[data-disable-with]:disabled, input[data-disable]:disabled, button[data-disable]:disabled, textarea[data-disable]:disabled",
              fileInputSelector: "input[name][type=file]:not([disabled])",
              linkDisableSelector: "a[data-disable-with], a[data-disable]",
              buttonDisableSelector: "button[data-remote][data-disable-with], button[data-remote][data-disable]"
            };
          }).call(this);
        }).call(context);
        var Rails2 = context.Rails;
        (function() {
          (function() {
            var nonce;
            nonce = null;
            Rails2.loadCSPNonce = function() {
              var ref;
              return nonce = (ref = document.querySelector("meta[name=csp-nonce]")) != null ? ref.content : void 0;
            };
            Rails2.cspNonce = function() {
              return nonce != null ? nonce : Rails2.loadCSPNonce();
            };
          }).call(this);
          (function() {
            var expando, m;
            m = Element.prototype.matches || Element.prototype.matchesSelector || Element.prototype.mozMatchesSelector || Element.prototype.msMatchesSelector || Element.prototype.oMatchesSelector || Element.prototype.webkitMatchesSelector;
            Rails2.matches = function(element, selector) {
              if (selector.exclude != null) {
                return m.call(element, selector.selector) && !m.call(element, selector.exclude);
              } else {
                return m.call(element, selector);
              }
            };
            expando = "_ujsData";
            Rails2.getData = function(element, key) {
              var ref;
              return (ref = element[expando]) != null ? ref[key] : void 0;
            };
            Rails2.setData = function(element, key, value) {
              if (element[expando] == null) {
                element[expando] = {};
              }
              return element[expando][key] = value;
            };
            Rails2.$ = function(selector) {
              return Array.prototype.slice.call(document.querySelectorAll(selector));
            };
          }).call(this);
          (function() {
            var $2, csrfParam, csrfToken;
            $2 = Rails2.$;
            csrfToken = Rails2.csrfToken = function() {
              var meta;
              meta = document.querySelector("meta[name=csrf-token]");
              return meta && meta.content;
            };
            csrfParam = Rails2.csrfParam = function() {
              var meta;
              meta = document.querySelector("meta[name=csrf-param]");
              return meta && meta.content;
            };
            Rails2.CSRFProtection = function(xhr) {
              var token;
              token = csrfToken();
              if (token != null) {
                return xhr.setRequestHeader("X-CSRF-Token", token);
              }
            };
            Rails2.refreshCSRFTokens = function() {
              var param, token;
              token = csrfToken();
              param = csrfParam();
              if (token != null && param != null) {
                return $2('form input[name="' + param + '"]').forEach(function(input) {
                  return input.value = token;
                });
              }
            };
          }).call(this);
          (function() {
            var CustomEvent, fire, matches, preventDefault;
            matches = Rails2.matches;
            CustomEvent = window.CustomEvent;
            if (typeof CustomEvent !== "function") {
              CustomEvent = function(event, params) {
                var evt;
                evt = document.createEvent("CustomEvent");
                evt.initCustomEvent(event, params.bubbles, params.cancelable, params.detail);
                return evt;
              };
              CustomEvent.prototype = window.Event.prototype;
              preventDefault = CustomEvent.prototype.preventDefault;
              CustomEvent.prototype.preventDefault = function() {
                var result;
                result = preventDefault.call(this);
                if (this.cancelable && !this.defaultPrevented) {
                  Object.defineProperty(this, "defaultPrevented", {
                    get: function() {
                      return true;
                    }
                  });
                }
                return result;
              };
            }
            fire = Rails2.fire = function(obj, name, data) {
              var event;
              event = new CustomEvent(name, {
                bubbles: true,
                cancelable: true,
                detail: data
              });
              obj.dispatchEvent(event);
              return !event.defaultPrevented;
            };
            Rails2.stopEverything = function(e) {
              fire(e.target, "ujs:everythingStopped");
              e.preventDefault();
              e.stopPropagation();
              return e.stopImmediatePropagation();
            };
            Rails2.delegate = function(element, selector, eventType, handler) {
              return element.addEventListener(eventType, function(e) {
                var target;
                target = e.target;
                while (!(!(target instanceof Element) || matches(target, selector))) {
                  target = target.parentNode;
                }
                if (target instanceof Element && handler.call(target, e) === false) {
                  e.preventDefault();
                  return e.stopPropagation();
                }
              });
            };
          }).call(this);
          (function() {
            var AcceptHeaders, CSRFProtection, createXHR, cspNonce, fire, prepareOptions, processResponse;
            cspNonce = Rails2.cspNonce, CSRFProtection = Rails2.CSRFProtection, fire = Rails2.fire;
            AcceptHeaders = {
              "*": "*/*",
              text: "text/plain",
              html: "text/html",
              xml: "application/xml, text/xml",
              json: "application/json, text/javascript",
              script: "text/javascript, application/javascript, application/ecmascript, application/x-ecmascript"
            };
            Rails2.ajax = function(options) {
              var xhr;
              options = prepareOptions(options);
              xhr = createXHR(options, function() {
                var ref, response;
                response = processResponse((ref = xhr.response) != null ? ref : xhr.responseText, xhr.getResponseHeader("Content-Type"));
                if (Math.floor(xhr.status / 100) === 2) {
                  if (typeof options.success === "function") {
                    options.success(response, xhr.statusText, xhr);
                  }
                } else {
                  if (typeof options.error === "function") {
                    options.error(response, xhr.statusText, xhr);
                  }
                }
                return typeof options.complete === "function" ? options.complete(xhr, xhr.statusText) : void 0;
              });
              if (options.beforeSend != null && !options.beforeSend(xhr, options)) {
                return false;
              }
              if (xhr.readyState === XMLHttpRequest.OPENED) {
                return xhr.send(options.data);
              }
            };
            prepareOptions = function(options) {
              options.url = options.url || location.href;
              options.type = options.type.toUpperCase();
              if (options.type === "GET" && options.data) {
                if (options.url.indexOf("?") < 0) {
                  options.url += "?" + options.data;
                } else {
                  options.url += "&" + options.data;
                }
              }
              if (AcceptHeaders[options.dataType] == null) {
                options.dataType = "*";
              }
              options.accept = AcceptHeaders[options.dataType];
              if (options.dataType !== "*") {
                options.accept += ", */*; q=0.01";
              }
              return options;
            };
            createXHR = function(options, done) {
              var xhr;
              xhr = new XMLHttpRequest();
              xhr.open(options.type, options.url, true);
              xhr.setRequestHeader("Accept", options.accept);
              if (typeof options.data === "string") {
                xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8");
              }
              if (!options.crossDomain) {
                xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
                CSRFProtection(xhr);
              }
              xhr.withCredentials = !!options.withCredentials;
              xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                  return done(xhr);
                }
              };
              return xhr;
            };
            processResponse = function(response, type) {
              var parser, script;
              if (typeof response === "string" && typeof type === "string") {
                if (type.match(/\bjson\b/)) {
                  try {
                    response = JSON.parse(response);
                  } catch (error) {
                  }
                } else if (type.match(/\b(?:java|ecma)script\b/)) {
                  script = document.createElement("script");
                  script.setAttribute("nonce", cspNonce());
                  script.text = response;
                  document.head.appendChild(script).parentNode.removeChild(script);
                } else if (type.match(/\b(xml|html|svg)\b/)) {
                  parser = new DOMParser();
                  type = type.replace(/;.+/, "");
                  try {
                    response = parser.parseFromString(response, type);
                  } catch (error) {
                  }
                }
              }
              return response;
            };
            Rails2.href = function(element) {
              return element.href;
            };
            Rails2.isCrossDomain = function(url) {
              var e, originAnchor, urlAnchor;
              originAnchor = document.createElement("a");
              originAnchor.href = location.href;
              urlAnchor = document.createElement("a");
              try {
                urlAnchor.href = url;
                return !((!urlAnchor.protocol || urlAnchor.protocol === ":") && !urlAnchor.host || originAnchor.protocol + "//" + originAnchor.host === urlAnchor.protocol + "//" + urlAnchor.host);
              } catch (error) {
                e = error;
                return true;
              }
            };
          }).call(this);
          (function() {
            var matches, toArray;
            matches = Rails2.matches;
            toArray = function(e) {
              return Array.prototype.slice.call(e);
            };
            Rails2.serializeElement = function(element, additionalParam) {
              var inputs, params;
              inputs = [element];
              if (matches(element, "form")) {
                inputs = toArray(element.elements);
              }
              params = [];
              inputs.forEach(function(input) {
                if (!input.name || input.disabled) {
                  return;
                }
                if (matches(input, "fieldset[disabled] *")) {
                  return;
                }
                if (matches(input, "select")) {
                  return toArray(input.options).forEach(function(option) {
                    if (option.selected) {
                      return params.push({
                        name: input.name,
                        value: option.value
                      });
                    }
                  });
                } else if (input.checked || ["radio", "checkbox", "submit"].indexOf(input.type) === -1) {
                  return params.push({
                    name: input.name,
                    value: input.value
                  });
                }
              });
              if (additionalParam) {
                params.push(additionalParam);
              }
              return params.map(function(param) {
                if (param.name != null) {
                  return encodeURIComponent(param.name) + "=" + encodeURIComponent(param.value);
                } else {
                  return param;
                }
              }).join("&");
            };
            Rails2.formElements = function(form, selector) {
              if (matches(form, "form")) {
                return toArray(form.elements).filter(function(el) {
                  return matches(el, selector);
                });
              } else {
                return toArray(form.querySelectorAll(selector));
              }
            };
          }).call(this);
          (function() {
            var allowAction, fire, stopEverything;
            fire = Rails2.fire, stopEverything = Rails2.stopEverything;
            Rails2.handleConfirm = function(e) {
              if (!allowAction(this)) {
                return stopEverything(e);
              }
            };
            Rails2.confirm = function(message, element) {
              return confirm(message);
            };
            allowAction = function(element) {
              var answer, callback, message;
              message = element.getAttribute("data-confirm");
              if (!message) {
                return true;
              }
              answer = false;
              if (fire(element, "confirm")) {
                try {
                  answer = Rails2.confirm(message, element);
                } catch (error) {
                }
                callback = fire(element, "confirm:complete", [answer]);
              }
              return answer && callback;
            };
          }).call(this);
          (function() {
            var disableFormElement, disableFormElements, disableLinkElement, enableFormElement, enableFormElements, enableLinkElement, formElements, getData, isXhrRedirect, matches, setData, stopEverything;
            matches = Rails2.matches, getData = Rails2.getData, setData = Rails2.setData, stopEverything = Rails2.stopEverything, formElements = Rails2.formElements;
            Rails2.handleDisabledElement = function(e) {
              var element;
              element = this;
              if (element.disabled) {
                return stopEverything(e);
              }
            };
            Rails2.enableElement = function(e) {
              var element;
              if (e instanceof Event) {
                if (isXhrRedirect(e)) {
                  return;
                }
                element = e.target;
              } else {
                element = e;
              }
              if (matches(element, Rails2.linkDisableSelector)) {
                return enableLinkElement(element);
              } else if (matches(element, Rails2.buttonDisableSelector) || matches(element, Rails2.formEnableSelector)) {
                return enableFormElement(element);
              } else if (matches(element, Rails2.formSubmitSelector)) {
                return enableFormElements(element);
              }
            };
            Rails2.disableElement = function(e) {
              var element;
              element = e instanceof Event ? e.target : e;
              if (matches(element, Rails2.linkDisableSelector)) {
                return disableLinkElement(element);
              } else if (matches(element, Rails2.buttonDisableSelector) || matches(element, Rails2.formDisableSelector)) {
                return disableFormElement(element);
              } else if (matches(element, Rails2.formSubmitSelector)) {
                return disableFormElements(element);
              }
            };
            disableLinkElement = function(element) {
              var replacement;
              if (getData(element, "ujs:disabled")) {
                return;
              }
              replacement = element.getAttribute("data-disable-with");
              if (replacement != null) {
                setData(element, "ujs:enable-with", element.innerHTML);
                element.innerHTML = replacement;
              }
              element.addEventListener("click", stopEverything);
              return setData(element, "ujs:disabled", true);
            };
            enableLinkElement = function(element) {
              var originalText;
              originalText = getData(element, "ujs:enable-with");
              if (originalText != null) {
                element.innerHTML = originalText;
                setData(element, "ujs:enable-with", null);
              }
              element.removeEventListener("click", stopEverything);
              return setData(element, "ujs:disabled", null);
            };
            disableFormElements = function(form) {
              return formElements(form, Rails2.formDisableSelector).forEach(disableFormElement);
            };
            disableFormElement = function(element) {
              var replacement;
              if (getData(element, "ujs:disabled")) {
                return;
              }
              replacement = element.getAttribute("data-disable-with");
              if (replacement != null) {
                if (matches(element, "button")) {
                  setData(element, "ujs:enable-with", element.innerHTML);
                  element.innerHTML = replacement;
                } else {
                  setData(element, "ujs:enable-with", element.value);
                  element.value = replacement;
                }
              }
              element.disabled = true;
              return setData(element, "ujs:disabled", true);
            };
            enableFormElements = function(form) {
              return formElements(form, Rails2.formEnableSelector).forEach(enableFormElement);
            };
            enableFormElement = function(element) {
              var originalText;
              originalText = getData(element, "ujs:enable-with");
              if (originalText != null) {
                if (matches(element, "button")) {
                  element.innerHTML = originalText;
                } else {
                  element.value = originalText;
                }
                setData(element, "ujs:enable-with", null);
              }
              element.disabled = false;
              return setData(element, "ujs:disabled", null);
            };
            isXhrRedirect = function(event) {
              var ref, xhr;
              xhr = (ref = event.detail) != null ? ref[0] : void 0;
              return (xhr != null ? xhr.getResponseHeader("X-Xhr-Redirect") : void 0) != null;
            };
          }).call(this);
          (function() {
            var stopEverything;
            stopEverything = Rails2.stopEverything;
            Rails2.handleMethod = function(e) {
              var csrfParam, csrfToken, form, formContent, href, link, method;
              link = this;
              method = link.getAttribute("data-method");
              if (!method) {
                return;
              }
              href = Rails2.href(link);
              csrfToken = Rails2.csrfToken();
              csrfParam = Rails2.csrfParam();
              form = document.createElement("form");
              formContent = "<input name='_method' value='" + method + "' type='hidden' />";
              if (csrfParam != null && csrfToken != null && !Rails2.isCrossDomain(href)) {
                formContent += "<input name='" + csrfParam + "' value='" + csrfToken + "' type='hidden' />";
              }
              formContent += '<input type="submit" />';
              form.method = "post";
              form.action = href;
              form.target = link.target;
              form.innerHTML = formContent;
              form.style.display = "none";
              document.body.appendChild(form);
              form.querySelector('[type="submit"]').click();
              return stopEverything(e);
            };
          }).call(this);
          (function() {
            var ajax, fire, getData, isCrossDomain, isRemote, matches, serializeElement, setData, stopEverything, slice = [].slice;
            matches = Rails2.matches, getData = Rails2.getData, setData = Rails2.setData, fire = Rails2.fire, stopEverything = Rails2.stopEverything, ajax = Rails2.ajax, isCrossDomain = Rails2.isCrossDomain, serializeElement = Rails2.serializeElement;
            isRemote = function(element) {
              var value;
              value = element.getAttribute("data-remote");
              return value != null && value !== "false";
            };
            Rails2.handleRemote = function(e) {
              var button, data, dataType, element, method, url, withCredentials;
              element = this;
              if (!isRemote(element)) {
                return true;
              }
              if (!fire(element, "ajax:before")) {
                fire(element, "ajax:stopped");
                return false;
              }
              withCredentials = element.getAttribute("data-with-credentials");
              dataType = element.getAttribute("data-type") || "script";
              if (matches(element, Rails2.formSubmitSelector)) {
                button = getData(element, "ujs:submit-button");
                method = getData(element, "ujs:submit-button-formmethod") || element.method;
                url = getData(element, "ujs:submit-button-formaction") || element.getAttribute("action") || location.href;
                if (method.toUpperCase() === "GET") {
                  url = url.replace(/\?.*$/, "");
                }
                if (element.enctype === "multipart/form-data") {
                  data = new FormData(element);
                  if (button != null) {
                    data.append(button.name, button.value);
                  }
                } else {
                  data = serializeElement(element, button);
                }
                setData(element, "ujs:submit-button", null);
                setData(element, "ujs:submit-button-formmethod", null);
                setData(element, "ujs:submit-button-formaction", null);
              } else if (matches(element, Rails2.buttonClickSelector) || matches(element, Rails2.inputChangeSelector)) {
                method = element.getAttribute("data-method");
                url = element.getAttribute("data-url");
                data = serializeElement(element, element.getAttribute("data-params"));
              } else {
                method = element.getAttribute("data-method");
                url = Rails2.href(element);
                data = element.getAttribute("data-params");
              }
              ajax({
                type: method || "GET",
                url,
                data,
                dataType,
                beforeSend: function(xhr, options) {
                  if (fire(element, "ajax:beforeSend", [xhr, options])) {
                    return fire(element, "ajax:send", [xhr]);
                  } else {
                    fire(element, "ajax:stopped");
                    return false;
                  }
                },
                success: function() {
                  var args;
                  args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
                  return fire(element, "ajax:success", args);
                },
                error: function() {
                  var args;
                  args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
                  return fire(element, "ajax:error", args);
                },
                complete: function() {
                  var args;
                  args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
                  return fire(element, "ajax:complete", args);
                },
                crossDomain: isCrossDomain(url),
                withCredentials: withCredentials != null && withCredentials !== "false"
              });
              return stopEverything(e);
            };
            Rails2.formSubmitButtonClick = function(e) {
              var button, form;
              button = this;
              form = button.form;
              if (!form) {
                return;
              }
              if (button.name) {
                setData(form, "ujs:submit-button", {
                  name: button.name,
                  value: button.value
                });
              }
              setData(form, "ujs:formnovalidate-button", button.formNoValidate);
              setData(form, "ujs:submit-button-formaction", button.getAttribute("formaction"));
              return setData(form, "ujs:submit-button-formmethod", button.getAttribute("formmethod"));
            };
            Rails2.preventInsignificantClick = function(e) {
              var data, insignificantMetaClick, link, metaClick, method, nonPrimaryMouseClick;
              link = this;
              method = (link.getAttribute("data-method") || "GET").toUpperCase();
              data = link.getAttribute("data-params");
              metaClick = e.metaKey || e.ctrlKey;
              insignificantMetaClick = metaClick && method === "GET" && !data;
              nonPrimaryMouseClick = e.button != null && e.button !== 0;
              if (nonPrimaryMouseClick || insignificantMetaClick) {
                return e.stopImmediatePropagation();
              }
            };
          }).call(this);
          (function() {
            var $2, CSRFProtection, delegate, disableElement, enableElement, fire, formSubmitButtonClick, getData, handleConfirm, handleDisabledElement, handleMethod, handleRemote, loadCSPNonce, preventInsignificantClick, refreshCSRFTokens;
            fire = Rails2.fire, delegate = Rails2.delegate, getData = Rails2.getData, $2 = Rails2.$, refreshCSRFTokens = Rails2.refreshCSRFTokens, CSRFProtection = Rails2.CSRFProtection, loadCSPNonce = Rails2.loadCSPNonce, enableElement = Rails2.enableElement, disableElement = Rails2.disableElement, handleDisabledElement = Rails2.handleDisabledElement, handleConfirm = Rails2.handleConfirm, preventInsignificantClick = Rails2.preventInsignificantClick, handleRemote = Rails2.handleRemote, formSubmitButtonClick = Rails2.formSubmitButtonClick, handleMethod = Rails2.handleMethod;
            if (typeof jQuery !== "undefined" && jQuery !== null && jQuery.ajax != null) {
              if (jQuery.rails) {
                throw new Error("If you load both jquery_ujs and rails-ujs, use rails-ujs only.");
              }
              jQuery.rails = Rails2;
              jQuery.ajaxPrefilter(function(options, originalOptions, xhr) {
                if (!options.crossDomain) {
                  return CSRFProtection(xhr);
                }
              });
            }
            Rails2.start = function() {
              if (window._rails_loaded) {
                throw new Error("rails-ujs has already been loaded!");
              }
              window.addEventListener("pageshow", function() {
                $2(Rails2.formEnableSelector).forEach(function(el) {
                  if (getData(el, "ujs:disabled")) {
                    return enableElement(el);
                  }
                });
                return $2(Rails2.linkDisableSelector).forEach(function(el) {
                  if (getData(el, "ujs:disabled")) {
                    return enableElement(el);
                  }
                });
              });
              delegate(document, Rails2.linkDisableSelector, "ajax:complete", enableElement);
              delegate(document, Rails2.linkDisableSelector, "ajax:stopped", enableElement);
              delegate(document, Rails2.buttonDisableSelector, "ajax:complete", enableElement);
              delegate(document, Rails2.buttonDisableSelector, "ajax:stopped", enableElement);
              delegate(document, Rails2.linkClickSelector, "click", preventInsignificantClick);
              delegate(document, Rails2.linkClickSelector, "click", handleDisabledElement);
              delegate(document, Rails2.linkClickSelector, "click", handleConfirm);
              delegate(document, Rails2.linkClickSelector, "click", disableElement);
              delegate(document, Rails2.linkClickSelector, "click", handleRemote);
              delegate(document, Rails2.linkClickSelector, "click", handleMethod);
              delegate(document, Rails2.buttonClickSelector, "click", preventInsignificantClick);
              delegate(document, Rails2.buttonClickSelector, "click", handleDisabledElement);
              delegate(document, Rails2.buttonClickSelector, "click", handleConfirm);
              delegate(document, Rails2.buttonClickSelector, "click", disableElement);
              delegate(document, Rails2.buttonClickSelector, "click", handleRemote);
              delegate(document, Rails2.inputChangeSelector, "change", handleDisabledElement);
              delegate(document, Rails2.inputChangeSelector, "change", handleConfirm);
              delegate(document, Rails2.inputChangeSelector, "change", handleRemote);
              delegate(document, Rails2.formSubmitSelector, "submit", handleDisabledElement);
              delegate(document, Rails2.formSubmitSelector, "submit", handleConfirm);
              delegate(document, Rails2.formSubmitSelector, "submit", handleRemote);
              delegate(document, Rails2.formSubmitSelector, "submit", function(e) {
                return setTimeout(function() {
                  return disableElement(e);
                }, 13);
              });
              delegate(document, Rails2.formSubmitSelector, "ajax:send", disableElement);
              delegate(document, Rails2.formSubmitSelector, "ajax:complete", enableElement);
              delegate(document, Rails2.formInputClickSelector, "click", preventInsignificantClick);
              delegate(document, Rails2.formInputClickSelector, "click", handleDisabledElement);
              delegate(document, Rails2.formInputClickSelector, "click", handleConfirm);
              delegate(document, Rails2.formInputClickSelector, "click", formSubmitButtonClick);
              document.addEventListener("DOMContentLoaded", refreshCSRFTokens);
              document.addEventListener("DOMContentLoaded", loadCSPNonce);
              return window._rails_loaded = true;
            };
            if (window.Rails === Rails2 && fire(document, "rails:attachBindings")) {
              Rails2.start();
            }
          }).call(this);
        }).call(this);
        if (typeof module === "object" && module.exports) {
          module.exports = Rails2;
        } else if (typeof define === "function" && define.amd) {
          define(Rails2);
        }
      }).call(exports);
    }
  });

  // node_modules/popper.js/dist/umd/popper.js
  var require_popper = __commonJS({
    "node_modules/popper.js/dist/umd/popper.js"(exports, module) {
      (function(global2, factory) {
        typeof exports === "object" && typeof module !== "undefined" ? module.exports = factory() : typeof define === "function" && define.amd ? define(factory) : global2.Popper = factory();
      })(exports, function() {
        "use strict";
        var isBrowser = typeof window !== "undefined" && typeof document !== "undefined";
        var longerTimeoutBrowsers = ["Edge", "Trident", "Firefox"];
        var timeoutDuration = 0;
        for (var i = 0; i < longerTimeoutBrowsers.length; i += 1) {
          if (isBrowser && navigator.userAgent.indexOf(longerTimeoutBrowsers[i]) >= 0) {
            timeoutDuration = 1;
            break;
          }
        }
        function microtaskDebounce(fn) {
          var called = false;
          return function() {
            if (called) {
              return;
            }
            called = true;
            window.Promise.resolve().then(function() {
              called = false;
              fn();
            });
          };
        }
        function taskDebounce(fn) {
          var scheduled = false;
          return function() {
            if (!scheduled) {
              scheduled = true;
              setTimeout(function() {
                scheduled = false;
                fn();
              }, timeoutDuration);
            }
          };
        }
        var supportsMicroTasks = isBrowser && window.Promise;
        var debounce = supportsMicroTasks ? microtaskDebounce : taskDebounce;
        function isFunction(functionToCheck) {
          var getType = {};
          return functionToCheck && getType.toString.call(functionToCheck) === "[object Function]";
        }
        function getStyleComputedProperty(element, property) {
          if (element.nodeType !== 1) {
            return [];
          }
          var css = getComputedStyle(element, null);
          return property ? css[property] : css;
        }
        function getParentNode(element) {
          if (element.nodeName === "HTML") {
            return element;
          }
          return element.parentNode || element.host;
        }
        function getScrollParent(element) {
          if (!element) {
            return document.body;
          }
          switch (element.nodeName) {
            case "HTML":
            case "BODY":
              return element.ownerDocument.body;
            case "#document":
              return element.body;
          }
          var _getStyleComputedProp = getStyleComputedProperty(element), overflow = _getStyleComputedProp.overflow, overflowX = _getStyleComputedProp.overflowX, overflowY = _getStyleComputedProp.overflowY;
          if (/(auto|scroll|overlay)/.test(overflow + overflowY + overflowX)) {
            return element;
          }
          return getScrollParent(getParentNode(element));
        }
        var isIE11 = isBrowser && !!(window.MSInputMethodContext && document.documentMode);
        var isIE10 = isBrowser && /MSIE 10/.test(navigator.userAgent);
        function isIE(version) {
          if (version === 11) {
            return isIE11;
          }
          if (version === 10) {
            return isIE10;
          }
          return isIE11 || isIE10;
        }
        function getOffsetParent(element) {
          if (!element) {
            return document.documentElement;
          }
          var noOffsetParent = isIE(10) ? document.body : null;
          var offsetParent = element.offsetParent;
          while (offsetParent === noOffsetParent && element.nextElementSibling) {
            offsetParent = (element = element.nextElementSibling).offsetParent;
          }
          var nodeName = offsetParent && offsetParent.nodeName;
          if (!nodeName || nodeName === "BODY" || nodeName === "HTML") {
            return element ? element.ownerDocument.documentElement : document.documentElement;
          }
          if (["TD", "TABLE"].indexOf(offsetParent.nodeName) !== -1 && getStyleComputedProperty(offsetParent, "position") === "static") {
            return getOffsetParent(offsetParent);
          }
          return offsetParent;
        }
        function isOffsetContainer(element) {
          var nodeName = element.nodeName;
          if (nodeName === "BODY") {
            return false;
          }
          return nodeName === "HTML" || getOffsetParent(element.firstElementChild) === element;
        }
        function getRoot(node) {
          if (node.parentNode !== null) {
            return getRoot(node.parentNode);
          }
          return node;
        }
        function findCommonOffsetParent(element1, element2) {
          if (!element1 || !element1.nodeType || !element2 || !element2.nodeType) {
            return document.documentElement;
          }
          var order = element1.compareDocumentPosition(element2) & Node.DOCUMENT_POSITION_FOLLOWING;
          var start = order ? element1 : element2;
          var end = order ? element2 : element1;
          var range = document.createRange();
          range.setStart(start, 0);
          range.setEnd(end, 0);
          var commonAncestorContainer = range.commonAncestorContainer;
          if (element1 !== commonAncestorContainer && element2 !== commonAncestorContainer || start.contains(end)) {
            if (isOffsetContainer(commonAncestorContainer)) {
              return commonAncestorContainer;
            }
            return getOffsetParent(commonAncestorContainer);
          }
          var element1root = getRoot(element1);
          if (element1root.host) {
            return findCommonOffsetParent(element1root.host, element2);
          } else {
            return findCommonOffsetParent(element1, getRoot(element2).host);
          }
        }
        function getScroll(element) {
          var side = arguments.length > 1 && arguments[1] !== void 0 ? arguments[1] : "top";
          var upperSide = side === "top" ? "scrollTop" : "scrollLeft";
          var nodeName = element.nodeName;
          if (nodeName === "BODY" || nodeName === "HTML") {
            var html = element.ownerDocument.documentElement;
            var scrollingElement = element.ownerDocument.scrollingElement || html;
            return scrollingElement[upperSide];
          }
          return element[upperSide];
        }
        function includeScroll(rect, element) {
          var subtract = arguments.length > 2 && arguments[2] !== void 0 ? arguments[2] : false;
          var scrollTop = getScroll(element, "top");
          var scrollLeft = getScroll(element, "left");
          var modifier = subtract ? -1 : 1;
          rect.top += scrollTop * modifier;
          rect.bottom += scrollTop * modifier;
          rect.left += scrollLeft * modifier;
          rect.right += scrollLeft * modifier;
          return rect;
        }
        function getBordersSize(styles, axis) {
          var sideA = axis === "x" ? "Left" : "Top";
          var sideB = sideA === "Left" ? "Right" : "Bottom";
          return parseFloat(styles["border" + sideA + "Width"], 10) + parseFloat(styles["border" + sideB + "Width"], 10);
        }
        function getSize(axis, body, html, computedStyle) {
          return Math.max(body["offset" + axis], body["scroll" + axis], html["client" + axis], html["offset" + axis], html["scroll" + axis], isIE(10) ? html["offset" + axis] + computedStyle["margin" + (axis === "Height" ? "Top" : "Left")] + computedStyle["margin" + (axis === "Height" ? "Bottom" : "Right")] : 0);
        }
        function getWindowSizes() {
          var body = document.body;
          var html = document.documentElement;
          var computedStyle = isIE(10) && getComputedStyle(html);
          return {
            height: getSize("Height", body, html, computedStyle),
            width: getSize("Width", body, html, computedStyle)
          };
        }
        var classCallCheck = function(instance, Constructor) {
          if (!(instance instanceof Constructor)) {
            throw new TypeError("Cannot call a class as a function");
          }
        };
        var createClass = function() {
          function defineProperties(target, props) {
            for (var i2 = 0; i2 < props.length; i2++) {
              var descriptor = props[i2];
              descriptor.enumerable = descriptor.enumerable || false;
              descriptor.configurable = true;
              if ("value" in descriptor)
                descriptor.writable = true;
              Object.defineProperty(target, descriptor.key, descriptor);
            }
          }
          return function(Constructor, protoProps, staticProps) {
            if (protoProps)
              defineProperties(Constructor.prototype, protoProps);
            if (staticProps)
              defineProperties(Constructor, staticProps);
            return Constructor;
          };
        }();
        var defineProperty = function(obj, key, value) {
          if (key in obj) {
            Object.defineProperty(obj, key, {
              value,
              enumerable: true,
              configurable: true,
              writable: true
            });
          } else {
            obj[key] = value;
          }
          return obj;
        };
        var _extends = Object.assign || function(target) {
          for (var i2 = 1; i2 < arguments.length; i2++) {
            var source = arguments[i2];
            for (var key in source) {
              if (Object.prototype.hasOwnProperty.call(source, key)) {
                target[key] = source[key];
              }
            }
          }
          return target;
        };
        function getClientRect(offsets) {
          return _extends({}, offsets, {
            right: offsets.left + offsets.width,
            bottom: offsets.top + offsets.height
          });
        }
        function getBoundingClientRect(element) {
          var rect = {};
          try {
            if (isIE(10)) {
              rect = element.getBoundingClientRect();
              var scrollTop = getScroll(element, "top");
              var scrollLeft = getScroll(element, "left");
              rect.top += scrollTop;
              rect.left += scrollLeft;
              rect.bottom += scrollTop;
              rect.right += scrollLeft;
            } else {
              rect = element.getBoundingClientRect();
            }
          } catch (e) {
          }
          var result = {
            left: rect.left,
            top: rect.top,
            width: rect.right - rect.left,
            height: rect.bottom - rect.top
          };
          var sizes = element.nodeName === "HTML" ? getWindowSizes() : {};
          var width = sizes.width || element.clientWidth || result.right - result.left;
          var height = sizes.height || element.clientHeight || result.bottom - result.top;
          var horizScrollbar = element.offsetWidth - width;
          var vertScrollbar = element.offsetHeight - height;
          if (horizScrollbar || vertScrollbar) {
            var styles = getStyleComputedProperty(element);
            horizScrollbar -= getBordersSize(styles, "x");
            vertScrollbar -= getBordersSize(styles, "y");
            result.width -= horizScrollbar;
            result.height -= vertScrollbar;
          }
          return getClientRect(result);
        }
        function getOffsetRectRelativeToArbitraryNode(children, parent) {
          var fixedPosition = arguments.length > 2 && arguments[2] !== void 0 ? arguments[2] : false;
          var isIE102 = isIE(10);
          var isHTML = parent.nodeName === "HTML";
          var childrenRect = getBoundingClientRect(children);
          var parentRect = getBoundingClientRect(parent);
          var scrollParent = getScrollParent(children);
          var styles = getStyleComputedProperty(parent);
          var borderTopWidth = parseFloat(styles.borderTopWidth, 10);
          var borderLeftWidth = parseFloat(styles.borderLeftWidth, 10);
          if (fixedPosition && parent.nodeName === "HTML") {
            parentRect.top = Math.max(parentRect.top, 0);
            parentRect.left = Math.max(parentRect.left, 0);
          }
          var offsets = getClientRect({
            top: childrenRect.top - parentRect.top - borderTopWidth,
            left: childrenRect.left - parentRect.left - borderLeftWidth,
            width: childrenRect.width,
            height: childrenRect.height
          });
          offsets.marginTop = 0;
          offsets.marginLeft = 0;
          if (!isIE102 && isHTML) {
            var marginTop = parseFloat(styles.marginTop, 10);
            var marginLeft = parseFloat(styles.marginLeft, 10);
            offsets.top -= borderTopWidth - marginTop;
            offsets.bottom -= borderTopWidth - marginTop;
            offsets.left -= borderLeftWidth - marginLeft;
            offsets.right -= borderLeftWidth - marginLeft;
            offsets.marginTop = marginTop;
            offsets.marginLeft = marginLeft;
          }
          if (isIE102 && !fixedPosition ? parent.contains(scrollParent) : parent === scrollParent && scrollParent.nodeName !== "BODY") {
            offsets = includeScroll(offsets, parent);
          }
          return offsets;
        }
        function getViewportOffsetRectRelativeToArtbitraryNode(element) {
          var excludeScroll = arguments.length > 1 && arguments[1] !== void 0 ? arguments[1] : false;
          var html = element.ownerDocument.documentElement;
          var relativeOffset = getOffsetRectRelativeToArbitraryNode(element, html);
          var width = Math.max(html.clientWidth, window.innerWidth || 0);
          var height = Math.max(html.clientHeight, window.innerHeight || 0);
          var scrollTop = !excludeScroll ? getScroll(html) : 0;
          var scrollLeft = !excludeScroll ? getScroll(html, "left") : 0;
          var offset2 = {
            top: scrollTop - relativeOffset.top + relativeOffset.marginTop,
            left: scrollLeft - relativeOffset.left + relativeOffset.marginLeft,
            width,
            height
          };
          return getClientRect(offset2);
        }
        function isFixed(element) {
          var nodeName = element.nodeName;
          if (nodeName === "BODY" || nodeName === "HTML") {
            return false;
          }
          if (getStyleComputedProperty(element, "position") === "fixed") {
            return true;
          }
          return isFixed(getParentNode(element));
        }
        function getFixedPositionOffsetParent(element) {
          if (!element || !element.parentElement || isIE()) {
            return document.documentElement;
          }
          var el = element.parentElement;
          while (el && getStyleComputedProperty(el, "transform") === "none") {
            el = el.parentElement;
          }
          return el || document.documentElement;
        }
        function getBoundaries(popper, reference, padding, boundariesElement) {
          var fixedPosition = arguments.length > 4 && arguments[4] !== void 0 ? arguments[4] : false;
          var boundaries = { top: 0, left: 0 };
          var offsetParent = fixedPosition ? getFixedPositionOffsetParent(popper) : findCommonOffsetParent(popper, reference);
          if (boundariesElement === "viewport") {
            boundaries = getViewportOffsetRectRelativeToArtbitraryNode(offsetParent, fixedPosition);
          } else {
            var boundariesNode = void 0;
            if (boundariesElement === "scrollParent") {
              boundariesNode = getScrollParent(getParentNode(reference));
              if (boundariesNode.nodeName === "BODY") {
                boundariesNode = popper.ownerDocument.documentElement;
              }
            } else if (boundariesElement === "window") {
              boundariesNode = popper.ownerDocument.documentElement;
            } else {
              boundariesNode = boundariesElement;
            }
            var offsets = getOffsetRectRelativeToArbitraryNode(boundariesNode, offsetParent, fixedPosition);
            if (boundariesNode.nodeName === "HTML" && !isFixed(offsetParent)) {
              var _getWindowSizes = getWindowSizes(), height = _getWindowSizes.height, width = _getWindowSizes.width;
              boundaries.top += offsets.top - offsets.marginTop;
              boundaries.bottom = height + offsets.top;
              boundaries.left += offsets.left - offsets.marginLeft;
              boundaries.right = width + offsets.left;
            } else {
              boundaries = offsets;
            }
          }
          boundaries.left += padding;
          boundaries.top += padding;
          boundaries.right -= padding;
          boundaries.bottom -= padding;
          return boundaries;
        }
        function getArea(_ref) {
          var width = _ref.width, height = _ref.height;
          return width * height;
        }
        function computeAutoPlacement(placement, refRect, popper, reference, boundariesElement) {
          var padding = arguments.length > 5 && arguments[5] !== void 0 ? arguments[5] : 0;
          if (placement.indexOf("auto") === -1) {
            return placement;
          }
          var boundaries = getBoundaries(popper, reference, padding, boundariesElement);
          var rects = {
            top: {
              width: boundaries.width,
              height: refRect.top - boundaries.top
            },
            right: {
              width: boundaries.right - refRect.right,
              height: boundaries.height
            },
            bottom: {
              width: boundaries.width,
              height: boundaries.bottom - refRect.bottom
            },
            left: {
              width: refRect.left - boundaries.left,
              height: boundaries.height
            }
          };
          var sortedAreas = Object.keys(rects).map(function(key) {
            return _extends({
              key
            }, rects[key], {
              area: getArea(rects[key])
            });
          }).sort(function(a, b) {
            return b.area - a.area;
          });
          var filteredAreas = sortedAreas.filter(function(_ref2) {
            var width = _ref2.width, height = _ref2.height;
            return width >= popper.clientWidth && height >= popper.clientHeight;
          });
          var computedPlacement = filteredAreas.length > 0 ? filteredAreas[0].key : sortedAreas[0].key;
          var variation = placement.split("-")[1];
          return computedPlacement + (variation ? "-" + variation : "");
        }
        function getReferenceOffsets(state, popper, reference) {
          var fixedPosition = arguments.length > 3 && arguments[3] !== void 0 ? arguments[3] : null;
          var commonOffsetParent = fixedPosition ? getFixedPositionOffsetParent(popper) : findCommonOffsetParent(popper, reference);
          return getOffsetRectRelativeToArbitraryNode(reference, commonOffsetParent, fixedPosition);
        }
        function getOuterSizes(element) {
          var styles = getComputedStyle(element);
          var x = parseFloat(styles.marginTop) + parseFloat(styles.marginBottom);
          var y = parseFloat(styles.marginLeft) + parseFloat(styles.marginRight);
          var result = {
            width: element.offsetWidth + y,
            height: element.offsetHeight + x
          };
          return result;
        }
        function getOppositePlacement(placement) {
          var hash = { left: "right", right: "left", bottom: "top", top: "bottom" };
          return placement.replace(/left|right|bottom|top/g, function(matched) {
            return hash[matched];
          });
        }
        function getPopperOffsets(popper, referenceOffsets, placement) {
          placement = placement.split("-")[0];
          var popperRect = getOuterSizes(popper);
          var popperOffsets = {
            width: popperRect.width,
            height: popperRect.height
          };
          var isHoriz = ["right", "left"].indexOf(placement) !== -1;
          var mainSide = isHoriz ? "top" : "left";
          var secondarySide = isHoriz ? "left" : "top";
          var measurement = isHoriz ? "height" : "width";
          var secondaryMeasurement = !isHoriz ? "height" : "width";
          popperOffsets[mainSide] = referenceOffsets[mainSide] + referenceOffsets[measurement] / 2 - popperRect[measurement] / 2;
          if (placement === secondarySide) {
            popperOffsets[secondarySide] = referenceOffsets[secondarySide] - popperRect[secondaryMeasurement];
          } else {
            popperOffsets[secondarySide] = referenceOffsets[getOppositePlacement(secondarySide)];
          }
          return popperOffsets;
        }
        function find(arr, check) {
          if (Array.prototype.find) {
            return arr.find(check);
          }
          return arr.filter(check)[0];
        }
        function findIndex(arr, prop, value) {
          if (Array.prototype.findIndex) {
            return arr.findIndex(function(cur) {
              return cur[prop] === value;
            });
          }
          var match = find(arr, function(obj) {
            return obj[prop] === value;
          });
          return arr.indexOf(match);
        }
        function runModifiers(modifiers2, data, ends) {
          var modifiersToRun = ends === void 0 ? modifiers2 : modifiers2.slice(0, findIndex(modifiers2, "name", ends));
          modifiersToRun.forEach(function(modifier) {
            if (modifier["function"]) {
              console.warn("`modifier.function` is deprecated, use `modifier.fn`!");
            }
            var fn = modifier["function"] || modifier.fn;
            if (modifier.enabled && isFunction(fn)) {
              data.offsets.popper = getClientRect(data.offsets.popper);
              data.offsets.reference = getClientRect(data.offsets.reference);
              data = fn(data, modifier);
            }
          });
          return data;
        }
        function update() {
          if (this.state.isDestroyed) {
            return;
          }
          var data = {
            instance: this,
            styles: {},
            arrowStyles: {},
            attributes: {},
            flipped: false,
            offsets: {}
          };
          data.offsets.reference = getReferenceOffsets(this.state, this.popper, this.reference, this.options.positionFixed);
          data.placement = computeAutoPlacement(this.options.placement, data.offsets.reference, this.popper, this.reference, this.options.modifiers.flip.boundariesElement, this.options.modifiers.flip.padding);
          data.originalPlacement = data.placement;
          data.positionFixed = this.options.positionFixed;
          data.offsets.popper = getPopperOffsets(this.popper, data.offsets.reference, data.placement);
          data.offsets.popper.position = this.options.positionFixed ? "fixed" : "absolute";
          data = runModifiers(this.modifiers, data);
          if (!this.state.isCreated) {
            this.state.isCreated = true;
            this.options.onCreate(data);
          } else {
            this.options.onUpdate(data);
          }
        }
        function isModifierEnabled(modifiers2, modifierName) {
          return modifiers2.some(function(_ref) {
            var name = _ref.name, enabled = _ref.enabled;
            return enabled && name === modifierName;
          });
        }
        function getSupportedPropertyName(property) {
          var prefixes = [false, "ms", "Webkit", "Moz", "O"];
          var upperProp = property.charAt(0).toUpperCase() + property.slice(1);
          for (var i2 = 0; i2 < prefixes.length; i2++) {
            var prefix = prefixes[i2];
            var toCheck = prefix ? "" + prefix + upperProp : property;
            if (typeof document.body.style[toCheck] !== "undefined") {
              return toCheck;
            }
          }
          return null;
        }
        function destroy() {
          this.state.isDestroyed = true;
          if (isModifierEnabled(this.modifiers, "applyStyle")) {
            this.popper.removeAttribute("x-placement");
            this.popper.style.position = "";
            this.popper.style.top = "";
            this.popper.style.left = "";
            this.popper.style.right = "";
            this.popper.style.bottom = "";
            this.popper.style.willChange = "";
            this.popper.style[getSupportedPropertyName("transform")] = "";
          }
          this.disableEventListeners();
          if (this.options.removeOnDestroy) {
            this.popper.parentNode.removeChild(this.popper);
          }
          return this;
        }
        function getWindow(element) {
          var ownerDocument = element.ownerDocument;
          return ownerDocument ? ownerDocument.defaultView : window;
        }
        function attachToScrollParents(scrollParent, event, callback, scrollParents) {
          var isBody = scrollParent.nodeName === "BODY";
          var target = isBody ? scrollParent.ownerDocument.defaultView : scrollParent;
          target.addEventListener(event, callback, { passive: true });
          if (!isBody) {
            attachToScrollParents(getScrollParent(target.parentNode), event, callback, scrollParents);
          }
          scrollParents.push(target);
        }
        function setupEventListeners(reference, options, state, updateBound) {
          state.updateBound = updateBound;
          getWindow(reference).addEventListener("resize", state.updateBound, { passive: true });
          var scrollElement = getScrollParent(reference);
          attachToScrollParents(scrollElement, "scroll", state.updateBound, state.scrollParents);
          state.scrollElement = scrollElement;
          state.eventsEnabled = true;
          return state;
        }
        function enableEventListeners() {
          if (!this.state.eventsEnabled) {
            this.state = setupEventListeners(this.reference, this.options, this.state, this.scheduleUpdate);
          }
        }
        function removeEventListeners(reference, state) {
          getWindow(reference).removeEventListener("resize", state.updateBound);
          state.scrollParents.forEach(function(target) {
            target.removeEventListener("scroll", state.updateBound);
          });
          state.updateBound = null;
          state.scrollParents = [];
          state.scrollElement = null;
          state.eventsEnabled = false;
          return state;
        }
        function disableEventListeners() {
          if (this.state.eventsEnabled) {
            cancelAnimationFrame(this.scheduleUpdate);
            this.state = removeEventListeners(this.reference, this.state);
          }
        }
        function isNumeric(n) {
          return n !== "" && !isNaN(parseFloat(n)) && isFinite(n);
        }
        function setStyles(element, styles) {
          Object.keys(styles).forEach(function(prop) {
            var unit = "";
            if (["width", "height", "top", "right", "bottom", "left"].indexOf(prop) !== -1 && isNumeric(styles[prop])) {
              unit = "px";
            }
            element.style[prop] = styles[prop] + unit;
          });
        }
        function setAttributes(element, attributes) {
          Object.keys(attributes).forEach(function(prop) {
            var value = attributes[prop];
            if (value !== false) {
              element.setAttribute(prop, attributes[prop]);
            } else {
              element.removeAttribute(prop);
            }
          });
        }
        function applyStyle(data) {
          setStyles(data.instance.popper, data.styles);
          setAttributes(data.instance.popper, data.attributes);
          if (data.arrowElement && Object.keys(data.arrowStyles).length) {
            setStyles(data.arrowElement, data.arrowStyles);
          }
          return data;
        }
        function applyStyleOnLoad(reference, popper, options, modifierOptions, state) {
          var referenceOffsets = getReferenceOffsets(state, popper, reference, options.positionFixed);
          var placement = computeAutoPlacement(options.placement, referenceOffsets, popper, reference, options.modifiers.flip.boundariesElement, options.modifiers.flip.padding);
          popper.setAttribute("x-placement", placement);
          setStyles(popper, { position: options.positionFixed ? "fixed" : "absolute" });
          return options;
        }
        function computeStyle(data, options) {
          var x = options.x, y = options.y;
          var popper = data.offsets.popper;
          var legacyGpuAccelerationOption = find(data.instance.modifiers, function(modifier) {
            return modifier.name === "applyStyle";
          }).gpuAcceleration;
          if (legacyGpuAccelerationOption !== void 0) {
            console.warn("WARNING: `gpuAcceleration` option moved to `computeStyle` modifier and will not be supported in future versions of Popper.js!");
          }
          var gpuAcceleration = legacyGpuAccelerationOption !== void 0 ? legacyGpuAccelerationOption : options.gpuAcceleration;
          var offsetParent = getOffsetParent(data.instance.popper);
          var offsetParentRect = getBoundingClientRect(offsetParent);
          var styles = {
            position: popper.position
          };
          var offsets = {
            left: Math.floor(popper.left),
            top: Math.round(popper.top),
            bottom: Math.round(popper.bottom),
            right: Math.floor(popper.right)
          };
          var sideA = x === "bottom" ? "top" : "bottom";
          var sideB = y === "right" ? "left" : "right";
          var prefixedProperty = getSupportedPropertyName("transform");
          var left = void 0, top = void 0;
          if (sideA === "bottom") {
            top = -offsetParentRect.height + offsets.bottom;
          } else {
            top = offsets.top;
          }
          if (sideB === "right") {
            left = -offsetParentRect.width + offsets.right;
          } else {
            left = offsets.left;
          }
          if (gpuAcceleration && prefixedProperty) {
            styles[prefixedProperty] = "translate3d(" + left + "px, " + top + "px, 0)";
            styles[sideA] = 0;
            styles[sideB] = 0;
            styles.willChange = "transform";
          } else {
            var invertTop = sideA === "bottom" ? -1 : 1;
            var invertLeft = sideB === "right" ? -1 : 1;
            styles[sideA] = top * invertTop;
            styles[sideB] = left * invertLeft;
            styles.willChange = sideA + ", " + sideB;
          }
          var attributes = {
            "x-placement": data.placement
          };
          data.attributes = _extends({}, attributes, data.attributes);
          data.styles = _extends({}, styles, data.styles);
          data.arrowStyles = _extends({}, data.offsets.arrow, data.arrowStyles);
          return data;
        }
        function isModifierRequired(modifiers2, requestingName, requestedName) {
          var requesting = find(modifiers2, function(_ref) {
            var name = _ref.name;
            return name === requestingName;
          });
          var isRequired = !!requesting && modifiers2.some(function(modifier) {
            return modifier.name === requestedName && modifier.enabled && modifier.order < requesting.order;
          });
          if (!isRequired) {
            var _requesting = "`" + requestingName + "`";
            var requested = "`" + requestedName + "`";
            console.warn(requested + " modifier is required by " + _requesting + " modifier in order to work, be sure to include it before " + _requesting + "!");
          }
          return isRequired;
        }
        function arrow(data, options) {
          var _data$offsets$arrow;
          if (!isModifierRequired(data.instance.modifiers, "arrow", "keepTogether")) {
            return data;
          }
          var arrowElement = options.element;
          if (typeof arrowElement === "string") {
            arrowElement = data.instance.popper.querySelector(arrowElement);
            if (!arrowElement) {
              return data;
            }
          } else {
            if (!data.instance.popper.contains(arrowElement)) {
              console.warn("WARNING: `arrow.element` must be child of its popper element!");
              return data;
            }
          }
          var placement = data.placement.split("-")[0];
          var _data$offsets = data.offsets, popper = _data$offsets.popper, reference = _data$offsets.reference;
          var isVertical = ["left", "right"].indexOf(placement) !== -1;
          var len = isVertical ? "height" : "width";
          var sideCapitalized = isVertical ? "Top" : "Left";
          var side = sideCapitalized.toLowerCase();
          var altSide = isVertical ? "left" : "top";
          var opSide = isVertical ? "bottom" : "right";
          var arrowElementSize = getOuterSizes(arrowElement)[len];
          if (reference[opSide] - arrowElementSize < popper[side]) {
            data.offsets.popper[side] -= popper[side] - (reference[opSide] - arrowElementSize);
          }
          if (reference[side] + arrowElementSize > popper[opSide]) {
            data.offsets.popper[side] += reference[side] + arrowElementSize - popper[opSide];
          }
          data.offsets.popper = getClientRect(data.offsets.popper);
          var center = reference[side] + reference[len] / 2 - arrowElementSize / 2;
          var css = getStyleComputedProperty(data.instance.popper);
          var popperMarginSide = parseFloat(css["margin" + sideCapitalized], 10);
          var popperBorderSide = parseFloat(css["border" + sideCapitalized + "Width"], 10);
          var sideValue = center - data.offsets.popper[side] - popperMarginSide - popperBorderSide;
          sideValue = Math.max(Math.min(popper[len] - arrowElementSize, sideValue), 0);
          data.arrowElement = arrowElement;
          data.offsets.arrow = (_data$offsets$arrow = {}, defineProperty(_data$offsets$arrow, side, Math.round(sideValue)), defineProperty(_data$offsets$arrow, altSide, ""), _data$offsets$arrow);
          return data;
        }
        function getOppositeVariation(variation) {
          if (variation === "end") {
            return "start";
          } else if (variation === "start") {
            return "end";
          }
          return variation;
        }
        var placements = ["auto-start", "auto", "auto-end", "top-start", "top", "top-end", "right-start", "right", "right-end", "bottom-end", "bottom", "bottom-start", "left-end", "left", "left-start"];
        var validPlacements = placements.slice(3);
        function clockwise(placement) {
          var counter = arguments.length > 1 && arguments[1] !== void 0 ? arguments[1] : false;
          var index = validPlacements.indexOf(placement);
          var arr = validPlacements.slice(index + 1).concat(validPlacements.slice(0, index));
          return counter ? arr.reverse() : arr;
        }
        var BEHAVIORS = {
          FLIP: "flip",
          CLOCKWISE: "clockwise",
          COUNTERCLOCKWISE: "counterclockwise"
        };
        function flip(data, options) {
          if (isModifierEnabled(data.instance.modifiers, "inner")) {
            return data;
          }
          if (data.flipped && data.placement === data.originalPlacement) {
            return data;
          }
          var boundaries = getBoundaries(data.instance.popper, data.instance.reference, options.padding, options.boundariesElement, data.positionFixed);
          var placement = data.placement.split("-")[0];
          var placementOpposite = getOppositePlacement(placement);
          var variation = data.placement.split("-")[1] || "";
          var flipOrder = [];
          switch (options.behavior) {
            case BEHAVIORS.FLIP:
              flipOrder = [placement, placementOpposite];
              break;
            case BEHAVIORS.CLOCKWISE:
              flipOrder = clockwise(placement);
              break;
            case BEHAVIORS.COUNTERCLOCKWISE:
              flipOrder = clockwise(placement, true);
              break;
            default:
              flipOrder = options.behavior;
          }
          flipOrder.forEach(function(step, index) {
            if (placement !== step || flipOrder.length === index + 1) {
              return data;
            }
            placement = data.placement.split("-")[0];
            placementOpposite = getOppositePlacement(placement);
            var popperOffsets = data.offsets.popper;
            var refOffsets = data.offsets.reference;
            var floor = Math.floor;
            var overlapsRef = placement === "left" && floor(popperOffsets.right) > floor(refOffsets.left) || placement === "right" && floor(popperOffsets.left) < floor(refOffsets.right) || placement === "top" && floor(popperOffsets.bottom) > floor(refOffsets.top) || placement === "bottom" && floor(popperOffsets.top) < floor(refOffsets.bottom);
            var overflowsLeft = floor(popperOffsets.left) < floor(boundaries.left);
            var overflowsRight = floor(popperOffsets.right) > floor(boundaries.right);
            var overflowsTop = floor(popperOffsets.top) < floor(boundaries.top);
            var overflowsBottom = floor(popperOffsets.bottom) > floor(boundaries.bottom);
            var overflowsBoundaries = placement === "left" && overflowsLeft || placement === "right" && overflowsRight || placement === "top" && overflowsTop || placement === "bottom" && overflowsBottom;
            var isVertical = ["top", "bottom"].indexOf(placement) !== -1;
            var flippedVariation = !!options.flipVariations && (isVertical && variation === "start" && overflowsLeft || isVertical && variation === "end" && overflowsRight || !isVertical && variation === "start" && overflowsTop || !isVertical && variation === "end" && overflowsBottom);
            if (overlapsRef || overflowsBoundaries || flippedVariation) {
              data.flipped = true;
              if (overlapsRef || overflowsBoundaries) {
                placement = flipOrder[index + 1];
              }
              if (flippedVariation) {
                variation = getOppositeVariation(variation);
              }
              data.placement = placement + (variation ? "-" + variation : "");
              data.offsets.popper = _extends({}, data.offsets.popper, getPopperOffsets(data.instance.popper, data.offsets.reference, data.placement));
              data = runModifiers(data.instance.modifiers, data, "flip");
            }
          });
          return data;
        }
        function keepTogether(data) {
          var _data$offsets = data.offsets, popper = _data$offsets.popper, reference = _data$offsets.reference;
          var placement = data.placement.split("-")[0];
          var floor = Math.floor;
          var isVertical = ["top", "bottom"].indexOf(placement) !== -1;
          var side = isVertical ? "right" : "bottom";
          var opSide = isVertical ? "left" : "top";
          var measurement = isVertical ? "width" : "height";
          if (popper[side] < floor(reference[opSide])) {
            data.offsets.popper[opSide] = floor(reference[opSide]) - popper[measurement];
          }
          if (popper[opSide] > floor(reference[side])) {
            data.offsets.popper[opSide] = floor(reference[side]);
          }
          return data;
        }
        function toValue(str, measurement, popperOffsets, referenceOffsets) {
          var split = str.match(/((?:\-|\+)?\d*\.?\d*)(.*)/);
          var value = +split[1];
          var unit = split[2];
          if (!value) {
            return str;
          }
          if (unit.indexOf("%") === 0) {
            var element = void 0;
            switch (unit) {
              case "%p":
                element = popperOffsets;
                break;
              case "%":
              case "%r":
              default:
                element = referenceOffsets;
            }
            var rect = getClientRect(element);
            return rect[measurement] / 100 * value;
          } else if (unit === "vh" || unit === "vw") {
            var size = void 0;
            if (unit === "vh") {
              size = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
            } else {
              size = Math.max(document.documentElement.clientWidth, window.innerWidth || 0);
            }
            return size / 100 * value;
          } else {
            return value;
          }
        }
        function parseOffset(offset2, popperOffsets, referenceOffsets, basePlacement) {
          var offsets = [0, 0];
          var useHeight = ["right", "left"].indexOf(basePlacement) !== -1;
          var fragments = offset2.split(/(\+|\-)/).map(function(frag) {
            return frag.trim();
          });
          var divider = fragments.indexOf(find(fragments, function(frag) {
            return frag.search(/,|\s/) !== -1;
          }));
          if (fragments[divider] && fragments[divider].indexOf(",") === -1) {
            console.warn("Offsets separated by white space(s) are deprecated, use a comma (,) instead.");
          }
          var splitRegex = /\s*,\s*|\s+/;
          var ops = divider !== -1 ? [fragments.slice(0, divider).concat([fragments[divider].split(splitRegex)[0]]), [fragments[divider].split(splitRegex)[1]].concat(fragments.slice(divider + 1))] : [fragments];
          ops = ops.map(function(op, index) {
            var measurement = (index === 1 ? !useHeight : useHeight) ? "height" : "width";
            var mergeWithPrevious = false;
            return op.reduce(function(a, b) {
              if (a[a.length - 1] === "" && ["+", "-"].indexOf(b) !== -1) {
                a[a.length - 1] = b;
                mergeWithPrevious = true;
                return a;
              } else if (mergeWithPrevious) {
                a[a.length - 1] += b;
                mergeWithPrevious = false;
                return a;
              } else {
                return a.concat(b);
              }
            }, []).map(function(str) {
              return toValue(str, measurement, popperOffsets, referenceOffsets);
            });
          });
          ops.forEach(function(op, index) {
            op.forEach(function(frag, index2) {
              if (isNumeric(frag)) {
                offsets[index] += frag * (op[index2 - 1] === "-" ? -1 : 1);
              }
            });
          });
          return offsets;
        }
        function offset(data, _ref) {
          var offset2 = _ref.offset;
          var placement = data.placement, _data$offsets = data.offsets, popper = _data$offsets.popper, reference = _data$offsets.reference;
          var basePlacement = placement.split("-")[0];
          var offsets = void 0;
          if (isNumeric(+offset2)) {
            offsets = [+offset2, 0];
          } else {
            offsets = parseOffset(offset2, popper, reference, basePlacement);
          }
          if (basePlacement === "left") {
            popper.top += offsets[0];
            popper.left -= offsets[1];
          } else if (basePlacement === "right") {
            popper.top += offsets[0];
            popper.left += offsets[1];
          } else if (basePlacement === "top") {
            popper.left += offsets[0];
            popper.top -= offsets[1];
          } else if (basePlacement === "bottom") {
            popper.left += offsets[0];
            popper.top += offsets[1];
          }
          data.popper = popper;
          return data;
        }
        function preventOverflow(data, options) {
          var boundariesElement = options.boundariesElement || getOffsetParent(data.instance.popper);
          if (data.instance.reference === boundariesElement) {
            boundariesElement = getOffsetParent(boundariesElement);
          }
          var transformProp = getSupportedPropertyName("transform");
          var popperStyles = data.instance.popper.style;
          var top = popperStyles.top, left = popperStyles.left, transform = popperStyles[transformProp];
          popperStyles.top = "";
          popperStyles.left = "";
          popperStyles[transformProp] = "";
          var boundaries = getBoundaries(data.instance.popper, data.instance.reference, options.padding, boundariesElement, data.positionFixed);
          popperStyles.top = top;
          popperStyles.left = left;
          popperStyles[transformProp] = transform;
          options.boundaries = boundaries;
          var order = options.priority;
          var popper = data.offsets.popper;
          var check = {
            primary: function primary(placement) {
              var value = popper[placement];
              if (popper[placement] < boundaries[placement] && !options.escapeWithReference) {
                value = Math.max(popper[placement], boundaries[placement]);
              }
              return defineProperty({}, placement, value);
            },
            secondary: function secondary(placement) {
              var mainSide = placement === "right" ? "left" : "top";
              var value = popper[mainSide];
              if (popper[placement] > boundaries[placement] && !options.escapeWithReference) {
                value = Math.min(popper[mainSide], boundaries[placement] - (placement === "right" ? popper.width : popper.height));
              }
              return defineProperty({}, mainSide, value);
            }
          };
          order.forEach(function(placement) {
            var side = ["left", "top"].indexOf(placement) !== -1 ? "primary" : "secondary";
            popper = _extends({}, popper, check[side](placement));
          });
          data.offsets.popper = popper;
          return data;
        }
        function shift(data) {
          var placement = data.placement;
          var basePlacement = placement.split("-")[0];
          var shiftvariation = placement.split("-")[1];
          if (shiftvariation) {
            var _data$offsets = data.offsets, reference = _data$offsets.reference, popper = _data$offsets.popper;
            var isVertical = ["bottom", "top"].indexOf(basePlacement) !== -1;
            var side = isVertical ? "left" : "top";
            var measurement = isVertical ? "width" : "height";
            var shiftOffsets = {
              start: defineProperty({}, side, reference[side]),
              end: defineProperty({}, side, reference[side] + reference[measurement] - popper[measurement])
            };
            data.offsets.popper = _extends({}, popper, shiftOffsets[shiftvariation]);
          }
          return data;
        }
        function hide(data) {
          if (!isModifierRequired(data.instance.modifiers, "hide", "preventOverflow")) {
            return data;
          }
          var refRect = data.offsets.reference;
          var bound = find(data.instance.modifiers, function(modifier) {
            return modifier.name === "preventOverflow";
          }).boundaries;
          if (refRect.bottom < bound.top || refRect.left > bound.right || refRect.top > bound.bottom || refRect.right < bound.left) {
            if (data.hide === true) {
              return data;
            }
            data.hide = true;
            data.attributes["x-out-of-boundaries"] = "";
          } else {
            if (data.hide === false) {
              return data;
            }
            data.hide = false;
            data.attributes["x-out-of-boundaries"] = false;
          }
          return data;
        }
        function inner(data) {
          var placement = data.placement;
          var basePlacement = placement.split("-")[0];
          var _data$offsets = data.offsets, popper = _data$offsets.popper, reference = _data$offsets.reference;
          var isHoriz = ["left", "right"].indexOf(basePlacement) !== -1;
          var subtractLength = ["top", "left"].indexOf(basePlacement) === -1;
          popper[isHoriz ? "left" : "top"] = reference[basePlacement] - (subtractLength ? popper[isHoriz ? "width" : "height"] : 0);
          data.placement = getOppositePlacement(placement);
          data.offsets.popper = getClientRect(popper);
          return data;
        }
        var modifiers = {
          shift: {
            order: 100,
            enabled: true,
            fn: shift
          },
          offset: {
            order: 200,
            enabled: true,
            fn: offset,
            offset: 0
          },
          preventOverflow: {
            order: 300,
            enabled: true,
            fn: preventOverflow,
            priority: ["left", "right", "top", "bottom"],
            padding: 5,
            boundariesElement: "scrollParent"
          },
          keepTogether: {
            order: 400,
            enabled: true,
            fn: keepTogether
          },
          arrow: {
            order: 500,
            enabled: true,
            fn: arrow,
            element: "[x-arrow]"
          },
          flip: {
            order: 600,
            enabled: true,
            fn: flip,
            behavior: "flip",
            padding: 5,
            boundariesElement: "viewport"
          },
          inner: {
            order: 700,
            enabled: false,
            fn: inner
          },
          hide: {
            order: 800,
            enabled: true,
            fn: hide
          },
          computeStyle: {
            order: 850,
            enabled: true,
            fn: computeStyle,
            gpuAcceleration: true,
            x: "bottom",
            y: "right"
          },
          applyStyle: {
            order: 900,
            enabled: true,
            fn: applyStyle,
            onLoad: applyStyleOnLoad,
            gpuAcceleration: void 0
          }
        };
        var Defaults = {
          placement: "bottom",
          positionFixed: false,
          eventsEnabled: true,
          removeOnDestroy: false,
          onCreate: function onCreate() {
          },
          onUpdate: function onUpdate() {
          },
          modifiers
        };
        var Popper = function() {
          function Popper2(reference, popper) {
            var _this = this;
            var options = arguments.length > 2 && arguments[2] !== void 0 ? arguments[2] : {};
            classCallCheck(this, Popper2);
            this.scheduleUpdate = function() {
              return requestAnimationFrame(_this.update);
            };
            this.update = debounce(this.update.bind(this));
            this.options = _extends({}, Popper2.Defaults, options);
            this.state = {
              isDestroyed: false,
              isCreated: false,
              scrollParents: []
            };
            this.reference = reference && reference.jquery ? reference[0] : reference;
            this.popper = popper && popper.jquery ? popper[0] : popper;
            this.options.modifiers = {};
            Object.keys(_extends({}, Popper2.Defaults.modifiers, options.modifiers)).forEach(function(name) {
              _this.options.modifiers[name] = _extends({}, Popper2.Defaults.modifiers[name] || {}, options.modifiers ? options.modifiers[name] : {});
            });
            this.modifiers = Object.keys(this.options.modifiers).map(function(name) {
              return _extends({
                name
              }, _this.options.modifiers[name]);
            }).sort(function(a, b) {
              return a.order - b.order;
            });
            this.modifiers.forEach(function(modifierOptions) {
              if (modifierOptions.enabled && isFunction(modifierOptions.onLoad)) {
                modifierOptions.onLoad(_this.reference, _this.popper, _this.options, modifierOptions, _this.state);
              }
            });
            this.update();
            var eventsEnabled = this.options.eventsEnabled;
            if (eventsEnabled) {
              this.enableEventListeners();
            }
            this.state.eventsEnabled = eventsEnabled;
          }
          createClass(Popper2, [{
            key: "update",
            value: function update$$1() {
              return update.call(this);
            }
          }, {
            key: "destroy",
            value: function destroy$$1() {
              return destroy.call(this);
            }
          }, {
            key: "enableEventListeners",
            value: function enableEventListeners$$1() {
              return enableEventListeners.call(this);
            }
          }, {
            key: "disableEventListeners",
            value: function disableEventListeners$$1() {
              return disableEventListeners.call(this);
            }
          }]);
          return Popper2;
        }();
        Popper.Utils = (typeof window !== "undefined" ? window : global).PopperUtils;
        Popper.placements = placements;
        Popper.Defaults = Defaults;
        return Popper;
      });
    }
  });

  // node_modules/bootstrap/dist/js/bootstrap.js
  var require_bootstrap = __commonJS({
    "node_modules/bootstrap/dist/js/bootstrap.js"(exports, module) {
      (function(global2, factory) {
        typeof exports === "object" && typeof module !== "undefined" ? factory(exports, require_jquery(), require_popper()) : typeof define === "function" && define.amd ? define(["exports", "jquery", "popper.js"], factory) : (global2 = typeof globalThis !== "undefined" ? globalThis : global2 || self, factory(global2.bootstrap = {}, global2.jQuery, global2.Popper));
      })(exports, function(exports2, $2, Popper) {
        "use strict";
        function _interopDefaultLegacy(e) {
          return e && typeof e === "object" && "default" in e ? e : { "default": e };
        }
        var $__default = /* @__PURE__ */ _interopDefaultLegacy($2);
        var Popper__default = /* @__PURE__ */ _interopDefaultLegacy(Popper);
        function _defineProperties(target, props) {
          for (var i = 0; i < props.length; i++) {
            var descriptor = props[i];
            descriptor.enumerable = descriptor.enumerable || false;
            descriptor.configurable = true;
            if ("value" in descriptor)
              descriptor.writable = true;
            Object.defineProperty(target, descriptor.key, descriptor);
          }
        }
        function _createClass(Constructor, protoProps, staticProps) {
          if (protoProps)
            _defineProperties(Constructor.prototype, protoProps);
          if (staticProps)
            _defineProperties(Constructor, staticProps);
          return Constructor;
        }
        function _extends() {
          _extends = Object.assign || function(target) {
            for (var i = 1; i < arguments.length; i++) {
              var source = arguments[i];
              for (var key in source) {
                if (Object.prototype.hasOwnProperty.call(source, key)) {
                  target[key] = source[key];
                }
              }
            }
            return target;
          };
          return _extends.apply(this, arguments);
        }
        function _inheritsLoose(subClass, superClass) {
          subClass.prototype = Object.create(superClass.prototype);
          subClass.prototype.constructor = subClass;
          _setPrototypeOf(subClass, superClass);
        }
        function _setPrototypeOf(o, p) {
          _setPrototypeOf = Object.setPrototypeOf || function _setPrototypeOf2(o2, p2) {
            o2.__proto__ = p2;
            return o2;
          };
          return _setPrototypeOf(o, p);
        }
        var TRANSITION_END = "transitionend";
        var MAX_UID = 1e6;
        var MILLISECONDS_MULTIPLIER = 1e3;
        function toType(obj) {
          if (obj === null || typeof obj === "undefined") {
            return "" + obj;
          }
          return {}.toString.call(obj).match(/\s([a-z]+)/i)[1].toLowerCase();
        }
        function getSpecialTransitionEndEvent() {
          return {
            bindType: TRANSITION_END,
            delegateType: TRANSITION_END,
            handle: function handle(event) {
              if ($__default["default"](event.target).is(this)) {
                return event.handleObj.handler.apply(this, arguments);
              }
              return void 0;
            }
          };
        }
        function transitionEndEmulator(duration) {
          var _this = this;
          var called = false;
          $__default["default"](this).one(Util.TRANSITION_END, function() {
            called = true;
          });
          setTimeout(function() {
            if (!called) {
              Util.triggerTransitionEnd(_this);
            }
          }, duration);
          return this;
        }
        function setTransitionEndSupport() {
          $__default["default"].fn.emulateTransitionEnd = transitionEndEmulator;
          $__default["default"].event.special[Util.TRANSITION_END] = getSpecialTransitionEndEvent();
        }
        var Util = {
          TRANSITION_END: "bsTransitionEnd",
          getUID: function getUID(prefix) {
            do {
              prefix += ~~(Math.random() * MAX_UID);
            } while (document.getElementById(prefix));
            return prefix;
          },
          getSelectorFromElement: function getSelectorFromElement(element) {
            var selector = element.getAttribute("data-target");
            if (!selector || selector === "#") {
              var hrefAttr = element.getAttribute("href");
              selector = hrefAttr && hrefAttr !== "#" ? hrefAttr.trim() : "";
            }
            try {
              return document.querySelector(selector) ? selector : null;
            } catch (_) {
              return null;
            }
          },
          getTransitionDurationFromElement: function getTransitionDurationFromElement(element) {
            if (!element) {
              return 0;
            }
            var transitionDuration = $__default["default"](element).css("transition-duration");
            var transitionDelay = $__default["default"](element).css("transition-delay");
            var floatTransitionDuration = parseFloat(transitionDuration);
            var floatTransitionDelay = parseFloat(transitionDelay);
            if (!floatTransitionDuration && !floatTransitionDelay) {
              return 0;
            }
            transitionDuration = transitionDuration.split(",")[0];
            transitionDelay = transitionDelay.split(",")[0];
            return (parseFloat(transitionDuration) + parseFloat(transitionDelay)) * MILLISECONDS_MULTIPLIER;
          },
          reflow: function reflow(element) {
            return element.offsetHeight;
          },
          triggerTransitionEnd: function triggerTransitionEnd(element) {
            $__default["default"](element).trigger(TRANSITION_END);
          },
          supportsTransitionEnd: function supportsTransitionEnd() {
            return Boolean(TRANSITION_END);
          },
          isElement: function isElement(obj) {
            return (obj[0] || obj).nodeType;
          },
          typeCheckConfig: function typeCheckConfig(componentName, config, configTypes) {
            for (var property in configTypes) {
              if (Object.prototype.hasOwnProperty.call(configTypes, property)) {
                var expectedTypes = configTypes[property];
                var value = config[property];
                var valueType = value && Util.isElement(value) ? "element" : toType(value);
                if (!new RegExp(expectedTypes).test(valueType)) {
                  throw new Error(componentName.toUpperCase() + ": " + ('Option "' + property + '" provided type "' + valueType + '" ') + ('but expected type "' + expectedTypes + '".'));
                }
              }
            }
          },
          findShadowRoot: function findShadowRoot(element) {
            if (!document.documentElement.attachShadow) {
              return null;
            }
            if (typeof element.getRootNode === "function") {
              var root = element.getRootNode();
              return root instanceof ShadowRoot ? root : null;
            }
            if (element instanceof ShadowRoot) {
              return element;
            }
            if (!element.parentNode) {
              return null;
            }
            return Util.findShadowRoot(element.parentNode);
          },
          jQueryDetection: function jQueryDetection() {
            if (typeof $__default["default"] === "undefined") {
              throw new TypeError("Bootstrap's JavaScript requires jQuery. jQuery must be included before Bootstrap's JavaScript.");
            }
            var version = $__default["default"].fn.jquery.split(" ")[0].split(".");
            var minMajor = 1;
            var ltMajor = 2;
            var minMinor = 9;
            var minPatch = 1;
            var maxMajor = 4;
            if (version[0] < ltMajor && version[1] < minMinor || version[0] === minMajor && version[1] === minMinor && version[2] < minPatch || version[0] >= maxMajor) {
              throw new Error("Bootstrap's JavaScript requires at least jQuery v1.9.1 but less than v4.0.0");
            }
          }
        };
        Util.jQueryDetection();
        setTransitionEndSupport();
        var NAME$a = "alert";
        var VERSION$a = "4.6.1";
        var DATA_KEY$a = "bs.alert";
        var EVENT_KEY$a = "." + DATA_KEY$a;
        var DATA_API_KEY$7 = ".data-api";
        var JQUERY_NO_CONFLICT$a = $__default["default"].fn[NAME$a];
        var CLASS_NAME_ALERT = "alert";
        var CLASS_NAME_FADE$5 = "fade";
        var CLASS_NAME_SHOW$7 = "show";
        var EVENT_CLOSE = "close" + EVENT_KEY$a;
        var EVENT_CLOSED = "closed" + EVENT_KEY$a;
        var EVENT_CLICK_DATA_API$6 = "click" + EVENT_KEY$a + DATA_API_KEY$7;
        var SELECTOR_DISMISS = '[data-dismiss="alert"]';
        var Alert = /* @__PURE__ */ function() {
          function Alert2(element) {
            this._element = element;
          }
          var _proto = Alert2.prototype;
          _proto.close = function close(element) {
            var rootElement = this._element;
            if (element) {
              rootElement = this._getRootElement(element);
            }
            var customEvent = this._triggerCloseEvent(rootElement);
            if (customEvent.isDefaultPrevented()) {
              return;
            }
            this._removeElement(rootElement);
          };
          _proto.dispose = function dispose() {
            $__default["default"].removeData(this._element, DATA_KEY$a);
            this._element = null;
          };
          _proto._getRootElement = function _getRootElement(element) {
            var selector = Util.getSelectorFromElement(element);
            var parent = false;
            if (selector) {
              parent = document.querySelector(selector);
            }
            if (!parent) {
              parent = $__default["default"](element).closest("." + CLASS_NAME_ALERT)[0];
            }
            return parent;
          };
          _proto._triggerCloseEvent = function _triggerCloseEvent(element) {
            var closeEvent = $__default["default"].Event(EVENT_CLOSE);
            $__default["default"](element).trigger(closeEvent);
            return closeEvent;
          };
          _proto._removeElement = function _removeElement(element) {
            var _this = this;
            $__default["default"](element).removeClass(CLASS_NAME_SHOW$7);
            if (!$__default["default"](element).hasClass(CLASS_NAME_FADE$5)) {
              this._destroyElement(element);
              return;
            }
            var transitionDuration = Util.getTransitionDurationFromElement(element);
            $__default["default"](element).one(Util.TRANSITION_END, function(event) {
              return _this._destroyElement(element, event);
            }).emulateTransitionEnd(transitionDuration);
          };
          _proto._destroyElement = function _destroyElement(element) {
            $__default["default"](element).detach().trigger(EVENT_CLOSED).remove();
          };
          Alert2._jQueryInterface = function _jQueryInterface(config) {
            return this.each(function() {
              var $element = $__default["default"](this);
              var data = $element.data(DATA_KEY$a);
              if (!data) {
                data = new Alert2(this);
                $element.data(DATA_KEY$a, data);
              }
              if (config === "close") {
                data[config](this);
              }
            });
          };
          Alert2._handleDismiss = function _handleDismiss(alertInstance) {
            return function(event) {
              if (event) {
                event.preventDefault();
              }
              alertInstance.close(this);
            };
          };
          _createClass(Alert2, null, [{
            key: "VERSION",
            get: function get() {
              return VERSION$a;
            }
          }]);
          return Alert2;
        }();
        $__default["default"](document).on(EVENT_CLICK_DATA_API$6, SELECTOR_DISMISS, Alert._handleDismiss(new Alert()));
        $__default["default"].fn[NAME$a] = Alert._jQueryInterface;
        $__default["default"].fn[NAME$a].Constructor = Alert;
        $__default["default"].fn[NAME$a].noConflict = function() {
          $__default["default"].fn[NAME$a] = JQUERY_NO_CONFLICT$a;
          return Alert._jQueryInterface;
        };
        var NAME$9 = "button";
        var VERSION$9 = "4.6.1";
        var DATA_KEY$9 = "bs.button";
        var EVENT_KEY$9 = "." + DATA_KEY$9;
        var DATA_API_KEY$6 = ".data-api";
        var JQUERY_NO_CONFLICT$9 = $__default["default"].fn[NAME$9];
        var CLASS_NAME_ACTIVE$3 = "active";
        var CLASS_NAME_BUTTON = "btn";
        var CLASS_NAME_FOCUS = "focus";
        var EVENT_CLICK_DATA_API$5 = "click" + EVENT_KEY$9 + DATA_API_KEY$6;
        var EVENT_FOCUS_BLUR_DATA_API = "focus" + EVENT_KEY$9 + DATA_API_KEY$6 + " " + ("blur" + EVENT_KEY$9 + DATA_API_KEY$6);
        var EVENT_LOAD_DATA_API$2 = "load" + EVENT_KEY$9 + DATA_API_KEY$6;
        var SELECTOR_DATA_TOGGLE_CARROT = '[data-toggle^="button"]';
        var SELECTOR_DATA_TOGGLES = '[data-toggle="buttons"]';
        var SELECTOR_DATA_TOGGLE$4 = '[data-toggle="button"]';
        var SELECTOR_DATA_TOGGLES_BUTTONS = '[data-toggle="buttons"] .btn';
        var SELECTOR_INPUT = 'input:not([type="hidden"])';
        var SELECTOR_ACTIVE$2 = ".active";
        var SELECTOR_BUTTON = ".btn";
        var Button = /* @__PURE__ */ function() {
          function Button2(element) {
            this._element = element;
            this.shouldAvoidTriggerChange = false;
          }
          var _proto = Button2.prototype;
          _proto.toggle = function toggle() {
            var triggerChangeEvent = true;
            var addAriaPressed = true;
            var rootElement = $__default["default"](this._element).closest(SELECTOR_DATA_TOGGLES)[0];
            if (rootElement) {
              var input = this._element.querySelector(SELECTOR_INPUT);
              if (input) {
                if (input.type === "radio") {
                  if (input.checked && this._element.classList.contains(CLASS_NAME_ACTIVE$3)) {
                    triggerChangeEvent = false;
                  } else {
                    var activeElement = rootElement.querySelector(SELECTOR_ACTIVE$2);
                    if (activeElement) {
                      $__default["default"](activeElement).removeClass(CLASS_NAME_ACTIVE$3);
                    }
                  }
                }
                if (triggerChangeEvent) {
                  if (input.type === "checkbox" || input.type === "radio") {
                    input.checked = !this._element.classList.contains(CLASS_NAME_ACTIVE$3);
                  }
                  if (!this.shouldAvoidTriggerChange) {
                    $__default["default"](input).trigger("change");
                  }
                }
                input.focus();
                addAriaPressed = false;
              }
            }
            if (!(this._element.hasAttribute("disabled") || this._element.classList.contains("disabled"))) {
              if (addAriaPressed) {
                this._element.setAttribute("aria-pressed", !this._element.classList.contains(CLASS_NAME_ACTIVE$3));
              }
              if (triggerChangeEvent) {
                $__default["default"](this._element).toggleClass(CLASS_NAME_ACTIVE$3);
              }
            }
          };
          _proto.dispose = function dispose() {
            $__default["default"].removeData(this._element, DATA_KEY$9);
            this._element = null;
          };
          Button2._jQueryInterface = function _jQueryInterface(config, avoidTriggerChange) {
            return this.each(function() {
              var $element = $__default["default"](this);
              var data = $element.data(DATA_KEY$9);
              if (!data) {
                data = new Button2(this);
                $element.data(DATA_KEY$9, data);
              }
              data.shouldAvoidTriggerChange = avoidTriggerChange;
              if (config === "toggle") {
                data[config]();
              }
            });
          };
          _createClass(Button2, null, [{
            key: "VERSION",
            get: function get() {
              return VERSION$9;
            }
          }]);
          return Button2;
        }();
        $__default["default"](document).on(EVENT_CLICK_DATA_API$5, SELECTOR_DATA_TOGGLE_CARROT, function(event) {
          var button = event.target;
          var initialButton = button;
          if (!$__default["default"](button).hasClass(CLASS_NAME_BUTTON)) {
            button = $__default["default"](button).closest(SELECTOR_BUTTON)[0];
          }
          if (!button || button.hasAttribute("disabled") || button.classList.contains("disabled")) {
            event.preventDefault();
          } else {
            var inputBtn = button.querySelector(SELECTOR_INPUT);
            if (inputBtn && (inputBtn.hasAttribute("disabled") || inputBtn.classList.contains("disabled"))) {
              event.preventDefault();
              return;
            }
            if (initialButton.tagName === "INPUT" || button.tagName !== "LABEL") {
              Button._jQueryInterface.call($__default["default"](button), "toggle", initialButton.tagName === "INPUT");
            }
          }
        }).on(EVENT_FOCUS_BLUR_DATA_API, SELECTOR_DATA_TOGGLE_CARROT, function(event) {
          var button = $__default["default"](event.target).closest(SELECTOR_BUTTON)[0];
          $__default["default"](button).toggleClass(CLASS_NAME_FOCUS, /^focus(in)?$/.test(event.type));
        });
        $__default["default"](window).on(EVENT_LOAD_DATA_API$2, function() {
          var buttons = [].slice.call(document.querySelectorAll(SELECTOR_DATA_TOGGLES_BUTTONS));
          for (var i = 0, len = buttons.length; i < len; i++) {
            var button = buttons[i];
            var input = button.querySelector(SELECTOR_INPUT);
            if (input.checked || input.hasAttribute("checked")) {
              button.classList.add(CLASS_NAME_ACTIVE$3);
            } else {
              button.classList.remove(CLASS_NAME_ACTIVE$3);
            }
          }
          buttons = [].slice.call(document.querySelectorAll(SELECTOR_DATA_TOGGLE$4));
          for (var _i = 0, _len = buttons.length; _i < _len; _i++) {
            var _button = buttons[_i];
            if (_button.getAttribute("aria-pressed") === "true") {
              _button.classList.add(CLASS_NAME_ACTIVE$3);
            } else {
              _button.classList.remove(CLASS_NAME_ACTIVE$3);
            }
          }
        });
        $__default["default"].fn[NAME$9] = Button._jQueryInterface;
        $__default["default"].fn[NAME$9].Constructor = Button;
        $__default["default"].fn[NAME$9].noConflict = function() {
          $__default["default"].fn[NAME$9] = JQUERY_NO_CONFLICT$9;
          return Button._jQueryInterface;
        };
        var NAME$8 = "carousel";
        var VERSION$8 = "4.6.1";
        var DATA_KEY$8 = "bs.carousel";
        var EVENT_KEY$8 = "." + DATA_KEY$8;
        var DATA_API_KEY$5 = ".data-api";
        var JQUERY_NO_CONFLICT$8 = $__default["default"].fn[NAME$8];
        var ARROW_LEFT_KEYCODE = 37;
        var ARROW_RIGHT_KEYCODE = 39;
        var TOUCHEVENT_COMPAT_WAIT = 500;
        var SWIPE_THRESHOLD = 40;
        var CLASS_NAME_CAROUSEL = "carousel";
        var CLASS_NAME_ACTIVE$2 = "active";
        var CLASS_NAME_SLIDE = "slide";
        var CLASS_NAME_RIGHT = "carousel-item-right";
        var CLASS_NAME_LEFT = "carousel-item-left";
        var CLASS_NAME_NEXT = "carousel-item-next";
        var CLASS_NAME_PREV = "carousel-item-prev";
        var CLASS_NAME_POINTER_EVENT = "pointer-event";
        var DIRECTION_NEXT = "next";
        var DIRECTION_PREV = "prev";
        var DIRECTION_LEFT = "left";
        var DIRECTION_RIGHT = "right";
        var EVENT_SLIDE = "slide" + EVENT_KEY$8;
        var EVENT_SLID = "slid" + EVENT_KEY$8;
        var EVENT_KEYDOWN = "keydown" + EVENT_KEY$8;
        var EVENT_MOUSEENTER = "mouseenter" + EVENT_KEY$8;
        var EVENT_MOUSELEAVE = "mouseleave" + EVENT_KEY$8;
        var EVENT_TOUCHSTART = "touchstart" + EVENT_KEY$8;
        var EVENT_TOUCHMOVE = "touchmove" + EVENT_KEY$8;
        var EVENT_TOUCHEND = "touchend" + EVENT_KEY$8;
        var EVENT_POINTERDOWN = "pointerdown" + EVENT_KEY$8;
        var EVENT_POINTERUP = "pointerup" + EVENT_KEY$8;
        var EVENT_DRAG_START = "dragstart" + EVENT_KEY$8;
        var EVENT_LOAD_DATA_API$1 = "load" + EVENT_KEY$8 + DATA_API_KEY$5;
        var EVENT_CLICK_DATA_API$4 = "click" + EVENT_KEY$8 + DATA_API_KEY$5;
        var SELECTOR_ACTIVE$1 = ".active";
        var SELECTOR_ACTIVE_ITEM = ".active.carousel-item";
        var SELECTOR_ITEM = ".carousel-item";
        var SELECTOR_ITEM_IMG = ".carousel-item img";
        var SELECTOR_NEXT_PREV = ".carousel-item-next, .carousel-item-prev";
        var SELECTOR_INDICATORS = ".carousel-indicators";
        var SELECTOR_DATA_SLIDE = "[data-slide], [data-slide-to]";
        var SELECTOR_DATA_RIDE = '[data-ride="carousel"]';
        var Default$7 = {
          interval: 5e3,
          keyboard: true,
          slide: false,
          pause: "hover",
          wrap: true,
          touch: true
        };
        var DefaultType$7 = {
          interval: "(number|boolean)",
          keyboard: "boolean",
          slide: "(boolean|string)",
          pause: "(string|boolean)",
          wrap: "boolean",
          touch: "boolean"
        };
        var PointerType = {
          TOUCH: "touch",
          PEN: "pen"
        };
        var Carousel = /* @__PURE__ */ function() {
          function Carousel2(element, config) {
            this._items = null;
            this._interval = null;
            this._activeElement = null;
            this._isPaused = false;
            this._isSliding = false;
            this.touchTimeout = null;
            this.touchStartX = 0;
            this.touchDeltaX = 0;
            this._config = this._getConfig(config);
            this._element = element;
            this._indicatorsElement = this._element.querySelector(SELECTOR_INDICATORS);
            this._touchSupported = "ontouchstart" in document.documentElement || navigator.maxTouchPoints > 0;
            this._pointerEvent = Boolean(window.PointerEvent || window.MSPointerEvent);
            this._addEventListeners();
          }
          var _proto = Carousel2.prototype;
          _proto.next = function next() {
            if (!this._isSliding) {
              this._slide(DIRECTION_NEXT);
            }
          };
          _proto.nextWhenVisible = function nextWhenVisible() {
            var $element = $__default["default"](this._element);
            if (!document.hidden && $element.is(":visible") && $element.css("visibility") !== "hidden") {
              this.next();
            }
          };
          _proto.prev = function prev() {
            if (!this._isSliding) {
              this._slide(DIRECTION_PREV);
            }
          };
          _proto.pause = function pause(event) {
            if (!event) {
              this._isPaused = true;
            }
            if (this._element.querySelector(SELECTOR_NEXT_PREV)) {
              Util.triggerTransitionEnd(this._element);
              this.cycle(true);
            }
            clearInterval(this._interval);
            this._interval = null;
          };
          _proto.cycle = function cycle(event) {
            if (!event) {
              this._isPaused = false;
            }
            if (this._interval) {
              clearInterval(this._interval);
              this._interval = null;
            }
            if (this._config.interval && !this._isPaused) {
              this._updateInterval();
              this._interval = setInterval((document.visibilityState ? this.nextWhenVisible : this.next).bind(this), this._config.interval);
            }
          };
          _proto.to = function to(index) {
            var _this = this;
            this._activeElement = this._element.querySelector(SELECTOR_ACTIVE_ITEM);
            var activeIndex = this._getItemIndex(this._activeElement);
            if (index > this._items.length - 1 || index < 0) {
              return;
            }
            if (this._isSliding) {
              $__default["default"](this._element).one(EVENT_SLID, function() {
                return _this.to(index);
              });
              return;
            }
            if (activeIndex === index) {
              this.pause();
              this.cycle();
              return;
            }
            var direction = index > activeIndex ? DIRECTION_NEXT : DIRECTION_PREV;
            this._slide(direction, this._items[index]);
          };
          _proto.dispose = function dispose() {
            $__default["default"](this._element).off(EVENT_KEY$8);
            $__default["default"].removeData(this._element, DATA_KEY$8);
            this._items = null;
            this._config = null;
            this._element = null;
            this._interval = null;
            this._isPaused = null;
            this._isSliding = null;
            this._activeElement = null;
            this._indicatorsElement = null;
          };
          _proto._getConfig = function _getConfig(config) {
            config = _extends({}, Default$7, config);
            Util.typeCheckConfig(NAME$8, config, DefaultType$7);
            return config;
          };
          _proto._handleSwipe = function _handleSwipe() {
            var absDeltax = Math.abs(this.touchDeltaX);
            if (absDeltax <= SWIPE_THRESHOLD) {
              return;
            }
            var direction = absDeltax / this.touchDeltaX;
            this.touchDeltaX = 0;
            if (direction > 0) {
              this.prev();
            }
            if (direction < 0) {
              this.next();
            }
          };
          _proto._addEventListeners = function _addEventListeners() {
            var _this2 = this;
            if (this._config.keyboard) {
              $__default["default"](this._element).on(EVENT_KEYDOWN, function(event) {
                return _this2._keydown(event);
              });
            }
            if (this._config.pause === "hover") {
              $__default["default"](this._element).on(EVENT_MOUSEENTER, function(event) {
                return _this2.pause(event);
              }).on(EVENT_MOUSELEAVE, function(event) {
                return _this2.cycle(event);
              });
            }
            if (this._config.touch) {
              this._addTouchEventListeners();
            }
          };
          _proto._addTouchEventListeners = function _addTouchEventListeners() {
            var _this3 = this;
            if (!this._touchSupported) {
              return;
            }
            var start = function start2(event) {
              if (_this3._pointerEvent && PointerType[event.originalEvent.pointerType.toUpperCase()]) {
                _this3.touchStartX = event.originalEvent.clientX;
              } else if (!_this3._pointerEvent) {
                _this3.touchStartX = event.originalEvent.touches[0].clientX;
              }
            };
            var move = function move2(event) {
              _this3.touchDeltaX = event.originalEvent.touches && event.originalEvent.touches.length > 1 ? 0 : event.originalEvent.touches[0].clientX - _this3.touchStartX;
            };
            var end = function end2(event) {
              if (_this3._pointerEvent && PointerType[event.originalEvent.pointerType.toUpperCase()]) {
                _this3.touchDeltaX = event.originalEvent.clientX - _this3.touchStartX;
              }
              _this3._handleSwipe();
              if (_this3._config.pause === "hover") {
                _this3.pause();
                if (_this3.touchTimeout) {
                  clearTimeout(_this3.touchTimeout);
                }
                _this3.touchTimeout = setTimeout(function(event2) {
                  return _this3.cycle(event2);
                }, TOUCHEVENT_COMPAT_WAIT + _this3._config.interval);
              }
            };
            $__default["default"](this._element.querySelectorAll(SELECTOR_ITEM_IMG)).on(EVENT_DRAG_START, function(e) {
              return e.preventDefault();
            });
            if (this._pointerEvent) {
              $__default["default"](this._element).on(EVENT_POINTERDOWN, function(event) {
                return start(event);
              });
              $__default["default"](this._element).on(EVENT_POINTERUP, function(event) {
                return end(event);
              });
              this._element.classList.add(CLASS_NAME_POINTER_EVENT);
            } else {
              $__default["default"](this._element).on(EVENT_TOUCHSTART, function(event) {
                return start(event);
              });
              $__default["default"](this._element).on(EVENT_TOUCHMOVE, function(event) {
                return move(event);
              });
              $__default["default"](this._element).on(EVENT_TOUCHEND, function(event) {
                return end(event);
              });
            }
          };
          _proto._keydown = function _keydown(event) {
            if (/input|textarea/i.test(event.target.tagName)) {
              return;
            }
            switch (event.which) {
              case ARROW_LEFT_KEYCODE:
                event.preventDefault();
                this.prev();
                break;
              case ARROW_RIGHT_KEYCODE:
                event.preventDefault();
                this.next();
                break;
            }
          };
          _proto._getItemIndex = function _getItemIndex(element) {
            this._items = element && element.parentNode ? [].slice.call(element.parentNode.querySelectorAll(SELECTOR_ITEM)) : [];
            return this._items.indexOf(element);
          };
          _proto._getItemByDirection = function _getItemByDirection(direction, activeElement) {
            var isNextDirection = direction === DIRECTION_NEXT;
            var isPrevDirection = direction === DIRECTION_PREV;
            var activeIndex = this._getItemIndex(activeElement);
            var lastItemIndex = this._items.length - 1;
            var isGoingToWrap = isPrevDirection && activeIndex === 0 || isNextDirection && activeIndex === lastItemIndex;
            if (isGoingToWrap && !this._config.wrap) {
              return activeElement;
            }
            var delta = direction === DIRECTION_PREV ? -1 : 1;
            var itemIndex = (activeIndex + delta) % this._items.length;
            return itemIndex === -1 ? this._items[this._items.length - 1] : this._items[itemIndex];
          };
          _proto._triggerSlideEvent = function _triggerSlideEvent(relatedTarget, eventDirectionName) {
            var targetIndex = this._getItemIndex(relatedTarget);
            var fromIndex = this._getItemIndex(this._element.querySelector(SELECTOR_ACTIVE_ITEM));
            var slideEvent = $__default["default"].Event(EVENT_SLIDE, {
              relatedTarget,
              direction: eventDirectionName,
              from: fromIndex,
              to: targetIndex
            });
            $__default["default"](this._element).trigger(slideEvent);
            return slideEvent;
          };
          _proto._setActiveIndicatorElement = function _setActiveIndicatorElement(element) {
            if (this._indicatorsElement) {
              var indicators = [].slice.call(this._indicatorsElement.querySelectorAll(SELECTOR_ACTIVE$1));
              $__default["default"](indicators).removeClass(CLASS_NAME_ACTIVE$2);
              var nextIndicator = this._indicatorsElement.children[this._getItemIndex(element)];
              if (nextIndicator) {
                $__default["default"](nextIndicator).addClass(CLASS_NAME_ACTIVE$2);
              }
            }
          };
          _proto._updateInterval = function _updateInterval() {
            var element = this._activeElement || this._element.querySelector(SELECTOR_ACTIVE_ITEM);
            if (!element) {
              return;
            }
            var elementInterval = parseInt(element.getAttribute("data-interval"), 10);
            if (elementInterval) {
              this._config.defaultInterval = this._config.defaultInterval || this._config.interval;
              this._config.interval = elementInterval;
            } else {
              this._config.interval = this._config.defaultInterval || this._config.interval;
            }
          };
          _proto._slide = function _slide(direction, element) {
            var _this4 = this;
            var activeElement = this._element.querySelector(SELECTOR_ACTIVE_ITEM);
            var activeElementIndex = this._getItemIndex(activeElement);
            var nextElement = element || activeElement && this._getItemByDirection(direction, activeElement);
            var nextElementIndex = this._getItemIndex(nextElement);
            var isCycling = Boolean(this._interval);
            var directionalClassName;
            var orderClassName;
            var eventDirectionName;
            if (direction === DIRECTION_NEXT) {
              directionalClassName = CLASS_NAME_LEFT;
              orderClassName = CLASS_NAME_NEXT;
              eventDirectionName = DIRECTION_LEFT;
            } else {
              directionalClassName = CLASS_NAME_RIGHT;
              orderClassName = CLASS_NAME_PREV;
              eventDirectionName = DIRECTION_RIGHT;
            }
            if (nextElement && $__default["default"](nextElement).hasClass(CLASS_NAME_ACTIVE$2)) {
              this._isSliding = false;
              return;
            }
            var slideEvent = this._triggerSlideEvent(nextElement, eventDirectionName);
            if (slideEvent.isDefaultPrevented()) {
              return;
            }
            if (!activeElement || !nextElement) {
              return;
            }
            this._isSliding = true;
            if (isCycling) {
              this.pause();
            }
            this._setActiveIndicatorElement(nextElement);
            this._activeElement = nextElement;
            var slidEvent = $__default["default"].Event(EVENT_SLID, {
              relatedTarget: nextElement,
              direction: eventDirectionName,
              from: activeElementIndex,
              to: nextElementIndex
            });
            if ($__default["default"](this._element).hasClass(CLASS_NAME_SLIDE)) {
              $__default["default"](nextElement).addClass(orderClassName);
              Util.reflow(nextElement);
              $__default["default"](activeElement).addClass(directionalClassName);
              $__default["default"](nextElement).addClass(directionalClassName);
              var transitionDuration = Util.getTransitionDurationFromElement(activeElement);
              $__default["default"](activeElement).one(Util.TRANSITION_END, function() {
                $__default["default"](nextElement).removeClass(directionalClassName + " " + orderClassName).addClass(CLASS_NAME_ACTIVE$2);
                $__default["default"](activeElement).removeClass(CLASS_NAME_ACTIVE$2 + " " + orderClassName + " " + directionalClassName);
                _this4._isSliding = false;
                setTimeout(function() {
                  return $__default["default"](_this4._element).trigger(slidEvent);
                }, 0);
              }).emulateTransitionEnd(transitionDuration);
            } else {
              $__default["default"](activeElement).removeClass(CLASS_NAME_ACTIVE$2);
              $__default["default"](nextElement).addClass(CLASS_NAME_ACTIVE$2);
              this._isSliding = false;
              $__default["default"](this._element).trigger(slidEvent);
            }
            if (isCycling) {
              this.cycle();
            }
          };
          Carousel2._jQueryInterface = function _jQueryInterface(config) {
            return this.each(function() {
              var data = $__default["default"](this).data(DATA_KEY$8);
              var _config = _extends({}, Default$7, $__default["default"](this).data());
              if (typeof config === "object") {
                _config = _extends({}, _config, config);
              }
              var action = typeof config === "string" ? config : _config.slide;
              if (!data) {
                data = new Carousel2(this, _config);
                $__default["default"](this).data(DATA_KEY$8, data);
              }
              if (typeof config === "number") {
                data.to(config);
              } else if (typeof action === "string") {
                if (typeof data[action] === "undefined") {
                  throw new TypeError('No method named "' + action + '"');
                }
                data[action]();
              } else if (_config.interval && _config.ride) {
                data.pause();
                data.cycle();
              }
            });
          };
          Carousel2._dataApiClickHandler = function _dataApiClickHandler(event) {
            var selector = Util.getSelectorFromElement(this);
            if (!selector) {
              return;
            }
            var target = $__default["default"](selector)[0];
            if (!target || !$__default["default"](target).hasClass(CLASS_NAME_CAROUSEL)) {
              return;
            }
            var config = _extends({}, $__default["default"](target).data(), $__default["default"](this).data());
            var slideIndex = this.getAttribute("data-slide-to");
            if (slideIndex) {
              config.interval = false;
            }
            Carousel2._jQueryInterface.call($__default["default"](target), config);
            if (slideIndex) {
              $__default["default"](target).data(DATA_KEY$8).to(slideIndex);
            }
            event.preventDefault();
          };
          _createClass(Carousel2, null, [{
            key: "VERSION",
            get: function get() {
              return VERSION$8;
            }
          }, {
            key: "Default",
            get: function get() {
              return Default$7;
            }
          }]);
          return Carousel2;
        }();
        $__default["default"](document).on(EVENT_CLICK_DATA_API$4, SELECTOR_DATA_SLIDE, Carousel._dataApiClickHandler);
        $__default["default"](window).on(EVENT_LOAD_DATA_API$1, function() {
          var carousels = [].slice.call(document.querySelectorAll(SELECTOR_DATA_RIDE));
          for (var i = 0, len = carousels.length; i < len; i++) {
            var $carousel = $__default["default"](carousels[i]);
            Carousel._jQueryInterface.call($carousel, $carousel.data());
          }
        });
        $__default["default"].fn[NAME$8] = Carousel._jQueryInterface;
        $__default["default"].fn[NAME$8].Constructor = Carousel;
        $__default["default"].fn[NAME$8].noConflict = function() {
          $__default["default"].fn[NAME$8] = JQUERY_NO_CONFLICT$8;
          return Carousel._jQueryInterface;
        };
        var NAME$7 = "collapse";
        var VERSION$7 = "4.6.1";
        var DATA_KEY$7 = "bs.collapse";
        var EVENT_KEY$7 = "." + DATA_KEY$7;
        var DATA_API_KEY$4 = ".data-api";
        var JQUERY_NO_CONFLICT$7 = $__default["default"].fn[NAME$7];
        var CLASS_NAME_SHOW$6 = "show";
        var CLASS_NAME_COLLAPSE = "collapse";
        var CLASS_NAME_COLLAPSING = "collapsing";
        var CLASS_NAME_COLLAPSED = "collapsed";
        var DIMENSION_WIDTH = "width";
        var DIMENSION_HEIGHT = "height";
        var EVENT_SHOW$4 = "show" + EVENT_KEY$7;
        var EVENT_SHOWN$4 = "shown" + EVENT_KEY$7;
        var EVENT_HIDE$4 = "hide" + EVENT_KEY$7;
        var EVENT_HIDDEN$4 = "hidden" + EVENT_KEY$7;
        var EVENT_CLICK_DATA_API$3 = "click" + EVENT_KEY$7 + DATA_API_KEY$4;
        var SELECTOR_ACTIVES = ".show, .collapsing";
        var SELECTOR_DATA_TOGGLE$3 = '[data-toggle="collapse"]';
        var Default$6 = {
          toggle: true,
          parent: ""
        };
        var DefaultType$6 = {
          toggle: "boolean",
          parent: "(string|element)"
        };
        var Collapse = /* @__PURE__ */ function() {
          function Collapse2(element, config) {
            this._isTransitioning = false;
            this._element = element;
            this._config = this._getConfig(config);
            this._triggerArray = [].slice.call(document.querySelectorAll('[data-toggle="collapse"][href="#' + element.id + '"],' + ('[data-toggle="collapse"][data-target="#' + element.id + '"]')));
            var toggleList = [].slice.call(document.querySelectorAll(SELECTOR_DATA_TOGGLE$3));
            for (var i = 0, len = toggleList.length; i < len; i++) {
              var elem = toggleList[i];
              var selector = Util.getSelectorFromElement(elem);
              var filterElement = [].slice.call(document.querySelectorAll(selector)).filter(function(foundElem) {
                return foundElem === element;
              });
              if (selector !== null && filterElement.length > 0) {
                this._selector = selector;
                this._triggerArray.push(elem);
              }
            }
            this._parent = this._config.parent ? this._getParent() : null;
            if (!this._config.parent) {
              this._addAriaAndCollapsedClass(this._element, this._triggerArray);
            }
            if (this._config.toggle) {
              this.toggle();
            }
          }
          var _proto = Collapse2.prototype;
          _proto.toggle = function toggle() {
            if ($__default["default"](this._element).hasClass(CLASS_NAME_SHOW$6)) {
              this.hide();
            } else {
              this.show();
            }
          };
          _proto.show = function show() {
            var _this = this;
            if (this._isTransitioning || $__default["default"](this._element).hasClass(CLASS_NAME_SHOW$6)) {
              return;
            }
            var actives;
            var activesData;
            if (this._parent) {
              actives = [].slice.call(this._parent.querySelectorAll(SELECTOR_ACTIVES)).filter(function(elem) {
                if (typeof _this._config.parent === "string") {
                  return elem.getAttribute("data-parent") === _this._config.parent;
                }
                return elem.classList.contains(CLASS_NAME_COLLAPSE);
              });
              if (actives.length === 0) {
                actives = null;
              }
            }
            if (actives) {
              activesData = $__default["default"](actives).not(this._selector).data(DATA_KEY$7);
              if (activesData && activesData._isTransitioning) {
                return;
              }
            }
            var startEvent = $__default["default"].Event(EVENT_SHOW$4);
            $__default["default"](this._element).trigger(startEvent);
            if (startEvent.isDefaultPrevented()) {
              return;
            }
            if (actives) {
              Collapse2._jQueryInterface.call($__default["default"](actives).not(this._selector), "hide");
              if (!activesData) {
                $__default["default"](actives).data(DATA_KEY$7, null);
              }
            }
            var dimension = this._getDimension();
            $__default["default"](this._element).removeClass(CLASS_NAME_COLLAPSE).addClass(CLASS_NAME_COLLAPSING);
            this._element.style[dimension] = 0;
            if (this._triggerArray.length) {
              $__default["default"](this._triggerArray).removeClass(CLASS_NAME_COLLAPSED).attr("aria-expanded", true);
            }
            this.setTransitioning(true);
            var complete = function complete2() {
              $__default["default"](_this._element).removeClass(CLASS_NAME_COLLAPSING).addClass(CLASS_NAME_COLLAPSE + " " + CLASS_NAME_SHOW$6);
              _this._element.style[dimension] = "";
              _this.setTransitioning(false);
              $__default["default"](_this._element).trigger(EVENT_SHOWN$4);
            };
            var capitalizedDimension = dimension[0].toUpperCase() + dimension.slice(1);
            var scrollSize = "scroll" + capitalizedDimension;
            var transitionDuration = Util.getTransitionDurationFromElement(this._element);
            $__default["default"](this._element).one(Util.TRANSITION_END, complete).emulateTransitionEnd(transitionDuration);
            this._element.style[dimension] = this._element[scrollSize] + "px";
          };
          _proto.hide = function hide() {
            var _this2 = this;
            if (this._isTransitioning || !$__default["default"](this._element).hasClass(CLASS_NAME_SHOW$6)) {
              return;
            }
            var startEvent = $__default["default"].Event(EVENT_HIDE$4);
            $__default["default"](this._element).trigger(startEvent);
            if (startEvent.isDefaultPrevented()) {
              return;
            }
            var dimension = this._getDimension();
            this._element.style[dimension] = this._element.getBoundingClientRect()[dimension] + "px";
            Util.reflow(this._element);
            $__default["default"](this._element).addClass(CLASS_NAME_COLLAPSING).removeClass(CLASS_NAME_COLLAPSE + " " + CLASS_NAME_SHOW$6);
            var triggerArrayLength = this._triggerArray.length;
            if (triggerArrayLength > 0) {
              for (var i = 0; i < triggerArrayLength; i++) {
                var trigger = this._triggerArray[i];
                var selector = Util.getSelectorFromElement(trigger);
                if (selector !== null) {
                  var $elem = $__default["default"]([].slice.call(document.querySelectorAll(selector)));
                  if (!$elem.hasClass(CLASS_NAME_SHOW$6)) {
                    $__default["default"](trigger).addClass(CLASS_NAME_COLLAPSED).attr("aria-expanded", false);
                  }
                }
              }
            }
            this.setTransitioning(true);
            var complete = function complete2() {
              _this2.setTransitioning(false);
              $__default["default"](_this2._element).removeClass(CLASS_NAME_COLLAPSING).addClass(CLASS_NAME_COLLAPSE).trigger(EVENT_HIDDEN$4);
            };
            this._element.style[dimension] = "";
            var transitionDuration = Util.getTransitionDurationFromElement(this._element);
            $__default["default"](this._element).one(Util.TRANSITION_END, complete).emulateTransitionEnd(transitionDuration);
          };
          _proto.setTransitioning = function setTransitioning(isTransitioning) {
            this._isTransitioning = isTransitioning;
          };
          _proto.dispose = function dispose() {
            $__default["default"].removeData(this._element, DATA_KEY$7);
            this._config = null;
            this._parent = null;
            this._element = null;
            this._triggerArray = null;
            this._isTransitioning = null;
          };
          _proto._getConfig = function _getConfig(config) {
            config = _extends({}, Default$6, config);
            config.toggle = Boolean(config.toggle);
            Util.typeCheckConfig(NAME$7, config, DefaultType$6);
            return config;
          };
          _proto._getDimension = function _getDimension() {
            var hasWidth = $__default["default"](this._element).hasClass(DIMENSION_WIDTH);
            return hasWidth ? DIMENSION_WIDTH : DIMENSION_HEIGHT;
          };
          _proto._getParent = function _getParent() {
            var _this3 = this;
            var parent;
            if (Util.isElement(this._config.parent)) {
              parent = this._config.parent;
              if (typeof this._config.parent.jquery !== "undefined") {
                parent = this._config.parent[0];
              }
            } else {
              parent = document.querySelector(this._config.parent);
            }
            var selector = '[data-toggle="collapse"][data-parent="' + this._config.parent + '"]';
            var children = [].slice.call(parent.querySelectorAll(selector));
            $__default["default"](children).each(function(i, element) {
              _this3._addAriaAndCollapsedClass(Collapse2._getTargetFromElement(element), [element]);
            });
            return parent;
          };
          _proto._addAriaAndCollapsedClass = function _addAriaAndCollapsedClass(element, triggerArray) {
            var isOpen = $__default["default"](element).hasClass(CLASS_NAME_SHOW$6);
            if (triggerArray.length) {
              $__default["default"](triggerArray).toggleClass(CLASS_NAME_COLLAPSED, !isOpen).attr("aria-expanded", isOpen);
            }
          };
          Collapse2._getTargetFromElement = function _getTargetFromElement(element) {
            var selector = Util.getSelectorFromElement(element);
            return selector ? document.querySelector(selector) : null;
          };
          Collapse2._jQueryInterface = function _jQueryInterface(config) {
            return this.each(function() {
              var $element = $__default["default"](this);
              var data = $element.data(DATA_KEY$7);
              var _config = _extends({}, Default$6, $element.data(), typeof config === "object" && config ? config : {});
              if (!data && _config.toggle && typeof config === "string" && /show|hide/.test(config)) {
                _config.toggle = false;
              }
              if (!data) {
                data = new Collapse2(this, _config);
                $element.data(DATA_KEY$7, data);
              }
              if (typeof config === "string") {
                if (typeof data[config] === "undefined") {
                  throw new TypeError('No method named "' + config + '"');
                }
                data[config]();
              }
            });
          };
          _createClass(Collapse2, null, [{
            key: "VERSION",
            get: function get() {
              return VERSION$7;
            }
          }, {
            key: "Default",
            get: function get() {
              return Default$6;
            }
          }]);
          return Collapse2;
        }();
        $__default["default"](document).on(EVENT_CLICK_DATA_API$3, SELECTOR_DATA_TOGGLE$3, function(event) {
          if (event.currentTarget.tagName === "A") {
            event.preventDefault();
          }
          var $trigger = $__default["default"](this);
          var selector = Util.getSelectorFromElement(this);
          var selectors = [].slice.call(document.querySelectorAll(selector));
          $__default["default"](selectors).each(function() {
            var $target = $__default["default"](this);
            var data = $target.data(DATA_KEY$7);
            var config = data ? "toggle" : $trigger.data();
            Collapse._jQueryInterface.call($target, config);
          });
        });
        $__default["default"].fn[NAME$7] = Collapse._jQueryInterface;
        $__default["default"].fn[NAME$7].Constructor = Collapse;
        $__default["default"].fn[NAME$7].noConflict = function() {
          $__default["default"].fn[NAME$7] = JQUERY_NO_CONFLICT$7;
          return Collapse._jQueryInterface;
        };
        var NAME$6 = "dropdown";
        var VERSION$6 = "4.6.1";
        var DATA_KEY$6 = "bs.dropdown";
        var EVENT_KEY$6 = "." + DATA_KEY$6;
        var DATA_API_KEY$3 = ".data-api";
        var JQUERY_NO_CONFLICT$6 = $__default["default"].fn[NAME$6];
        var ESCAPE_KEYCODE$1 = 27;
        var SPACE_KEYCODE = 32;
        var TAB_KEYCODE = 9;
        var ARROW_UP_KEYCODE = 38;
        var ARROW_DOWN_KEYCODE = 40;
        var RIGHT_MOUSE_BUTTON_WHICH = 3;
        var REGEXP_KEYDOWN = new RegExp(ARROW_UP_KEYCODE + "|" + ARROW_DOWN_KEYCODE + "|" + ESCAPE_KEYCODE$1);
        var CLASS_NAME_DISABLED$1 = "disabled";
        var CLASS_NAME_SHOW$5 = "show";
        var CLASS_NAME_DROPUP = "dropup";
        var CLASS_NAME_DROPRIGHT = "dropright";
        var CLASS_NAME_DROPLEFT = "dropleft";
        var CLASS_NAME_MENURIGHT = "dropdown-menu-right";
        var CLASS_NAME_POSITION_STATIC = "position-static";
        var EVENT_HIDE$3 = "hide" + EVENT_KEY$6;
        var EVENT_HIDDEN$3 = "hidden" + EVENT_KEY$6;
        var EVENT_SHOW$3 = "show" + EVENT_KEY$6;
        var EVENT_SHOWN$3 = "shown" + EVENT_KEY$6;
        var EVENT_CLICK = "click" + EVENT_KEY$6;
        var EVENT_CLICK_DATA_API$2 = "click" + EVENT_KEY$6 + DATA_API_KEY$3;
        var EVENT_KEYDOWN_DATA_API = "keydown" + EVENT_KEY$6 + DATA_API_KEY$3;
        var EVENT_KEYUP_DATA_API = "keyup" + EVENT_KEY$6 + DATA_API_KEY$3;
        var SELECTOR_DATA_TOGGLE$2 = '[data-toggle="dropdown"]';
        var SELECTOR_FORM_CHILD = ".dropdown form";
        var SELECTOR_MENU = ".dropdown-menu";
        var SELECTOR_NAVBAR_NAV = ".navbar-nav";
        var SELECTOR_VISIBLE_ITEMS = ".dropdown-menu .dropdown-item:not(.disabled):not(:disabled)";
        var PLACEMENT_TOP = "top-start";
        var PLACEMENT_TOPEND = "top-end";
        var PLACEMENT_BOTTOM = "bottom-start";
        var PLACEMENT_BOTTOMEND = "bottom-end";
        var PLACEMENT_RIGHT = "right-start";
        var PLACEMENT_LEFT = "left-start";
        var Default$5 = {
          offset: 0,
          flip: true,
          boundary: "scrollParent",
          reference: "toggle",
          display: "dynamic",
          popperConfig: null
        };
        var DefaultType$5 = {
          offset: "(number|string|function)",
          flip: "boolean",
          boundary: "(string|element)",
          reference: "(string|element)",
          display: "string",
          popperConfig: "(null|object)"
        };
        var Dropdown = /* @__PURE__ */ function() {
          function Dropdown2(element, config) {
            this._element = element;
            this._popper = null;
            this._config = this._getConfig(config);
            this._menu = this._getMenuElement();
            this._inNavbar = this._detectNavbar();
            this._addEventListeners();
          }
          var _proto = Dropdown2.prototype;
          _proto.toggle = function toggle() {
            if (this._element.disabled || $__default["default"](this._element).hasClass(CLASS_NAME_DISABLED$1)) {
              return;
            }
            var isActive = $__default["default"](this._menu).hasClass(CLASS_NAME_SHOW$5);
            Dropdown2._clearMenus();
            if (isActive) {
              return;
            }
            this.show(true);
          };
          _proto.show = function show(usePopper) {
            if (usePopper === void 0) {
              usePopper = false;
            }
            if (this._element.disabled || $__default["default"](this._element).hasClass(CLASS_NAME_DISABLED$1) || $__default["default"](this._menu).hasClass(CLASS_NAME_SHOW$5)) {
              return;
            }
            var relatedTarget = {
              relatedTarget: this._element
            };
            var showEvent = $__default["default"].Event(EVENT_SHOW$3, relatedTarget);
            var parent = Dropdown2._getParentFromElement(this._element);
            $__default["default"](parent).trigger(showEvent);
            if (showEvent.isDefaultPrevented()) {
              return;
            }
            if (!this._inNavbar && usePopper) {
              if (typeof Popper__default["default"] === "undefined") {
                throw new TypeError("Bootstrap's dropdowns require Popper (https://popper.js.org)");
              }
              var referenceElement = this._element;
              if (this._config.reference === "parent") {
                referenceElement = parent;
              } else if (Util.isElement(this._config.reference)) {
                referenceElement = this._config.reference;
                if (typeof this._config.reference.jquery !== "undefined") {
                  referenceElement = this._config.reference[0];
                }
              }
              if (this._config.boundary !== "scrollParent") {
                $__default["default"](parent).addClass(CLASS_NAME_POSITION_STATIC);
              }
              this._popper = new Popper__default["default"](referenceElement, this._menu, this._getPopperConfig());
            }
            if ("ontouchstart" in document.documentElement && $__default["default"](parent).closest(SELECTOR_NAVBAR_NAV).length === 0) {
              $__default["default"](document.body).children().on("mouseover", null, $__default["default"].noop);
            }
            this._element.focus();
            this._element.setAttribute("aria-expanded", true);
            $__default["default"](this._menu).toggleClass(CLASS_NAME_SHOW$5);
            $__default["default"](parent).toggleClass(CLASS_NAME_SHOW$5).trigger($__default["default"].Event(EVENT_SHOWN$3, relatedTarget));
          };
          _proto.hide = function hide() {
            if (this._element.disabled || $__default["default"](this._element).hasClass(CLASS_NAME_DISABLED$1) || !$__default["default"](this._menu).hasClass(CLASS_NAME_SHOW$5)) {
              return;
            }
            var relatedTarget = {
              relatedTarget: this._element
            };
            var hideEvent = $__default["default"].Event(EVENT_HIDE$3, relatedTarget);
            var parent = Dropdown2._getParentFromElement(this._element);
            $__default["default"](parent).trigger(hideEvent);
            if (hideEvent.isDefaultPrevented()) {
              return;
            }
            if (this._popper) {
              this._popper.destroy();
            }
            $__default["default"](this._menu).toggleClass(CLASS_NAME_SHOW$5);
            $__default["default"](parent).toggleClass(CLASS_NAME_SHOW$5).trigger($__default["default"].Event(EVENT_HIDDEN$3, relatedTarget));
          };
          _proto.dispose = function dispose() {
            $__default["default"].removeData(this._element, DATA_KEY$6);
            $__default["default"](this._element).off(EVENT_KEY$6);
            this._element = null;
            this._menu = null;
            if (this._popper !== null) {
              this._popper.destroy();
              this._popper = null;
            }
          };
          _proto.update = function update() {
            this._inNavbar = this._detectNavbar();
            if (this._popper !== null) {
              this._popper.scheduleUpdate();
            }
          };
          _proto._addEventListeners = function _addEventListeners() {
            var _this = this;
            $__default["default"](this._element).on(EVENT_CLICK, function(event) {
              event.preventDefault();
              event.stopPropagation();
              _this.toggle();
            });
          };
          _proto._getConfig = function _getConfig(config) {
            config = _extends({}, this.constructor.Default, $__default["default"](this._element).data(), config);
            Util.typeCheckConfig(NAME$6, config, this.constructor.DefaultType);
            return config;
          };
          _proto._getMenuElement = function _getMenuElement() {
            if (!this._menu) {
              var parent = Dropdown2._getParentFromElement(this._element);
              if (parent) {
                this._menu = parent.querySelector(SELECTOR_MENU);
              }
            }
            return this._menu;
          };
          _proto._getPlacement = function _getPlacement() {
            var $parentDropdown = $__default["default"](this._element.parentNode);
            var placement = PLACEMENT_BOTTOM;
            if ($parentDropdown.hasClass(CLASS_NAME_DROPUP)) {
              placement = $__default["default"](this._menu).hasClass(CLASS_NAME_MENURIGHT) ? PLACEMENT_TOPEND : PLACEMENT_TOP;
            } else if ($parentDropdown.hasClass(CLASS_NAME_DROPRIGHT)) {
              placement = PLACEMENT_RIGHT;
            } else if ($parentDropdown.hasClass(CLASS_NAME_DROPLEFT)) {
              placement = PLACEMENT_LEFT;
            } else if ($__default["default"](this._menu).hasClass(CLASS_NAME_MENURIGHT)) {
              placement = PLACEMENT_BOTTOMEND;
            }
            return placement;
          };
          _proto._detectNavbar = function _detectNavbar() {
            return $__default["default"](this._element).closest(".navbar").length > 0;
          };
          _proto._getOffset = function _getOffset() {
            var _this2 = this;
            var offset = {};
            if (typeof this._config.offset === "function") {
              offset.fn = function(data) {
                data.offsets = _extends({}, data.offsets, _this2._config.offset(data.offsets, _this2._element));
                return data;
              };
            } else {
              offset.offset = this._config.offset;
            }
            return offset;
          };
          _proto._getPopperConfig = function _getPopperConfig() {
            var popperConfig = {
              placement: this._getPlacement(),
              modifiers: {
                offset: this._getOffset(),
                flip: {
                  enabled: this._config.flip
                },
                preventOverflow: {
                  boundariesElement: this._config.boundary
                }
              }
            };
            if (this._config.display === "static") {
              popperConfig.modifiers.applyStyle = {
                enabled: false
              };
            }
            return _extends({}, popperConfig, this._config.popperConfig);
          };
          Dropdown2._jQueryInterface = function _jQueryInterface(config) {
            return this.each(function() {
              var data = $__default["default"](this).data(DATA_KEY$6);
              var _config = typeof config === "object" ? config : null;
              if (!data) {
                data = new Dropdown2(this, _config);
                $__default["default"](this).data(DATA_KEY$6, data);
              }
              if (typeof config === "string") {
                if (typeof data[config] === "undefined") {
                  throw new TypeError('No method named "' + config + '"');
                }
                data[config]();
              }
            });
          };
          Dropdown2._clearMenus = function _clearMenus(event) {
            if (event && (event.which === RIGHT_MOUSE_BUTTON_WHICH || event.type === "keyup" && event.which !== TAB_KEYCODE)) {
              return;
            }
            var toggles = [].slice.call(document.querySelectorAll(SELECTOR_DATA_TOGGLE$2));
            for (var i = 0, len = toggles.length; i < len; i++) {
              var parent = Dropdown2._getParentFromElement(toggles[i]);
              var context = $__default["default"](toggles[i]).data(DATA_KEY$6);
              var relatedTarget = {
                relatedTarget: toggles[i]
              };
              if (event && event.type === "click") {
                relatedTarget.clickEvent = event;
              }
              if (!context) {
                continue;
              }
              var dropdownMenu = context._menu;
              if (!$__default["default"](parent).hasClass(CLASS_NAME_SHOW$5)) {
                continue;
              }
              if (event && (event.type === "click" && /input|textarea/i.test(event.target.tagName) || event.type === "keyup" && event.which === TAB_KEYCODE) && $__default["default"].contains(parent, event.target)) {
                continue;
              }
              var hideEvent = $__default["default"].Event(EVENT_HIDE$3, relatedTarget);
              $__default["default"](parent).trigger(hideEvent);
              if (hideEvent.isDefaultPrevented()) {
                continue;
              }
              if ("ontouchstart" in document.documentElement) {
                $__default["default"](document.body).children().off("mouseover", null, $__default["default"].noop);
              }
              toggles[i].setAttribute("aria-expanded", "false");
              if (context._popper) {
                context._popper.destroy();
              }
              $__default["default"](dropdownMenu).removeClass(CLASS_NAME_SHOW$5);
              $__default["default"](parent).removeClass(CLASS_NAME_SHOW$5).trigger($__default["default"].Event(EVENT_HIDDEN$3, relatedTarget));
            }
          };
          Dropdown2._getParentFromElement = function _getParentFromElement(element) {
            var parent;
            var selector = Util.getSelectorFromElement(element);
            if (selector) {
              parent = document.querySelector(selector);
            }
            return parent || element.parentNode;
          };
          Dropdown2._dataApiKeydownHandler = function _dataApiKeydownHandler(event) {
            if (/input|textarea/i.test(event.target.tagName) ? event.which === SPACE_KEYCODE || event.which !== ESCAPE_KEYCODE$1 && (event.which !== ARROW_DOWN_KEYCODE && event.which !== ARROW_UP_KEYCODE || $__default["default"](event.target).closest(SELECTOR_MENU).length) : !REGEXP_KEYDOWN.test(event.which)) {
              return;
            }
            if (this.disabled || $__default["default"](this).hasClass(CLASS_NAME_DISABLED$1)) {
              return;
            }
            var parent = Dropdown2._getParentFromElement(this);
            var isActive = $__default["default"](parent).hasClass(CLASS_NAME_SHOW$5);
            if (!isActive && event.which === ESCAPE_KEYCODE$1) {
              return;
            }
            event.preventDefault();
            event.stopPropagation();
            if (!isActive || event.which === ESCAPE_KEYCODE$1 || event.which === SPACE_KEYCODE) {
              if (event.which === ESCAPE_KEYCODE$1) {
                $__default["default"](parent.querySelector(SELECTOR_DATA_TOGGLE$2)).trigger("focus");
              }
              $__default["default"](this).trigger("click");
              return;
            }
            var items = [].slice.call(parent.querySelectorAll(SELECTOR_VISIBLE_ITEMS)).filter(function(item) {
              return $__default["default"](item).is(":visible");
            });
            if (items.length === 0) {
              return;
            }
            var index = items.indexOf(event.target);
            if (event.which === ARROW_UP_KEYCODE && index > 0) {
              index--;
            }
            if (event.which === ARROW_DOWN_KEYCODE && index < items.length - 1) {
              index++;
            }
            if (index < 0) {
              index = 0;
            }
            items[index].focus();
          };
          _createClass(Dropdown2, null, [{
            key: "VERSION",
            get: function get() {
              return VERSION$6;
            }
          }, {
            key: "Default",
            get: function get() {
              return Default$5;
            }
          }, {
            key: "DefaultType",
            get: function get() {
              return DefaultType$5;
            }
          }]);
          return Dropdown2;
        }();
        $__default["default"](document).on(EVENT_KEYDOWN_DATA_API, SELECTOR_DATA_TOGGLE$2, Dropdown._dataApiKeydownHandler).on(EVENT_KEYDOWN_DATA_API, SELECTOR_MENU, Dropdown._dataApiKeydownHandler).on(EVENT_CLICK_DATA_API$2 + " " + EVENT_KEYUP_DATA_API, Dropdown._clearMenus).on(EVENT_CLICK_DATA_API$2, SELECTOR_DATA_TOGGLE$2, function(event) {
          event.preventDefault();
          event.stopPropagation();
          Dropdown._jQueryInterface.call($__default["default"](this), "toggle");
        }).on(EVENT_CLICK_DATA_API$2, SELECTOR_FORM_CHILD, function(e) {
          e.stopPropagation();
        });
        $__default["default"].fn[NAME$6] = Dropdown._jQueryInterface;
        $__default["default"].fn[NAME$6].Constructor = Dropdown;
        $__default["default"].fn[NAME$6].noConflict = function() {
          $__default["default"].fn[NAME$6] = JQUERY_NO_CONFLICT$6;
          return Dropdown._jQueryInterface;
        };
        var NAME$5 = "modal";
        var VERSION$5 = "4.6.1";
        var DATA_KEY$5 = "bs.modal";
        var EVENT_KEY$5 = "." + DATA_KEY$5;
        var DATA_API_KEY$2 = ".data-api";
        var JQUERY_NO_CONFLICT$5 = $__default["default"].fn[NAME$5];
        var ESCAPE_KEYCODE = 27;
        var CLASS_NAME_SCROLLABLE = "modal-dialog-scrollable";
        var CLASS_NAME_SCROLLBAR_MEASURER = "modal-scrollbar-measure";
        var CLASS_NAME_BACKDROP = "modal-backdrop";
        var CLASS_NAME_OPEN = "modal-open";
        var CLASS_NAME_FADE$4 = "fade";
        var CLASS_NAME_SHOW$4 = "show";
        var CLASS_NAME_STATIC = "modal-static";
        var EVENT_HIDE$2 = "hide" + EVENT_KEY$5;
        var EVENT_HIDE_PREVENTED = "hidePrevented" + EVENT_KEY$5;
        var EVENT_HIDDEN$2 = "hidden" + EVENT_KEY$5;
        var EVENT_SHOW$2 = "show" + EVENT_KEY$5;
        var EVENT_SHOWN$2 = "shown" + EVENT_KEY$5;
        var EVENT_FOCUSIN = "focusin" + EVENT_KEY$5;
        var EVENT_RESIZE = "resize" + EVENT_KEY$5;
        var EVENT_CLICK_DISMISS$1 = "click.dismiss" + EVENT_KEY$5;
        var EVENT_KEYDOWN_DISMISS = "keydown.dismiss" + EVENT_KEY$5;
        var EVENT_MOUSEUP_DISMISS = "mouseup.dismiss" + EVENT_KEY$5;
        var EVENT_MOUSEDOWN_DISMISS = "mousedown.dismiss" + EVENT_KEY$5;
        var EVENT_CLICK_DATA_API$1 = "click" + EVENT_KEY$5 + DATA_API_KEY$2;
        var SELECTOR_DIALOG = ".modal-dialog";
        var SELECTOR_MODAL_BODY = ".modal-body";
        var SELECTOR_DATA_TOGGLE$1 = '[data-toggle="modal"]';
        var SELECTOR_DATA_DISMISS$1 = '[data-dismiss="modal"]';
        var SELECTOR_FIXED_CONTENT = ".fixed-top, .fixed-bottom, .is-fixed, .sticky-top";
        var SELECTOR_STICKY_CONTENT = ".sticky-top";
        var Default$4 = {
          backdrop: true,
          keyboard: true,
          focus: true,
          show: true
        };
        var DefaultType$4 = {
          backdrop: "(boolean|string)",
          keyboard: "boolean",
          focus: "boolean",
          show: "boolean"
        };
        var Modal = /* @__PURE__ */ function() {
          function Modal2(element, config) {
            this._config = this._getConfig(config);
            this._element = element;
            this._dialog = element.querySelector(SELECTOR_DIALOG);
            this._backdrop = null;
            this._isShown = false;
            this._isBodyOverflowing = false;
            this._ignoreBackdropClick = false;
            this._isTransitioning = false;
            this._scrollbarWidth = 0;
          }
          var _proto = Modal2.prototype;
          _proto.toggle = function toggle(relatedTarget) {
            return this._isShown ? this.hide() : this.show(relatedTarget);
          };
          _proto.show = function show(relatedTarget) {
            var _this = this;
            if (this._isShown || this._isTransitioning) {
              return;
            }
            var showEvent = $__default["default"].Event(EVENT_SHOW$2, {
              relatedTarget
            });
            $__default["default"](this._element).trigger(showEvent);
            if (showEvent.isDefaultPrevented()) {
              return;
            }
            this._isShown = true;
            if ($__default["default"](this._element).hasClass(CLASS_NAME_FADE$4)) {
              this._isTransitioning = true;
            }
            this._checkScrollbar();
            this._setScrollbar();
            this._adjustDialog();
            this._setEscapeEvent();
            this._setResizeEvent();
            $__default["default"](this._element).on(EVENT_CLICK_DISMISS$1, SELECTOR_DATA_DISMISS$1, function(event) {
              return _this.hide(event);
            });
            $__default["default"](this._dialog).on(EVENT_MOUSEDOWN_DISMISS, function() {
              $__default["default"](_this._element).one(EVENT_MOUSEUP_DISMISS, function(event) {
                if ($__default["default"](event.target).is(_this._element)) {
                  _this._ignoreBackdropClick = true;
                }
              });
            });
            this._showBackdrop(function() {
              return _this._showElement(relatedTarget);
            });
          };
          _proto.hide = function hide(event) {
            var _this2 = this;
            if (event) {
              event.preventDefault();
            }
            if (!this._isShown || this._isTransitioning) {
              return;
            }
            var hideEvent = $__default["default"].Event(EVENT_HIDE$2);
            $__default["default"](this._element).trigger(hideEvent);
            if (!this._isShown || hideEvent.isDefaultPrevented()) {
              return;
            }
            this._isShown = false;
            var transition = $__default["default"](this._element).hasClass(CLASS_NAME_FADE$4);
            if (transition) {
              this._isTransitioning = true;
            }
            this._setEscapeEvent();
            this._setResizeEvent();
            $__default["default"](document).off(EVENT_FOCUSIN);
            $__default["default"](this._element).removeClass(CLASS_NAME_SHOW$4);
            $__default["default"](this._element).off(EVENT_CLICK_DISMISS$1);
            $__default["default"](this._dialog).off(EVENT_MOUSEDOWN_DISMISS);
            if (transition) {
              var transitionDuration = Util.getTransitionDurationFromElement(this._element);
              $__default["default"](this._element).one(Util.TRANSITION_END, function(event2) {
                return _this2._hideModal(event2);
              }).emulateTransitionEnd(transitionDuration);
            } else {
              this._hideModal();
            }
          };
          _proto.dispose = function dispose() {
            [window, this._element, this._dialog].forEach(function(htmlElement) {
              return $__default["default"](htmlElement).off(EVENT_KEY$5);
            });
            $__default["default"](document).off(EVENT_FOCUSIN);
            $__default["default"].removeData(this._element, DATA_KEY$5);
            this._config = null;
            this._element = null;
            this._dialog = null;
            this._backdrop = null;
            this._isShown = null;
            this._isBodyOverflowing = null;
            this._ignoreBackdropClick = null;
            this._isTransitioning = null;
            this._scrollbarWidth = null;
          };
          _proto.handleUpdate = function handleUpdate() {
            this._adjustDialog();
          };
          _proto._getConfig = function _getConfig(config) {
            config = _extends({}, Default$4, config);
            Util.typeCheckConfig(NAME$5, config, DefaultType$4);
            return config;
          };
          _proto._triggerBackdropTransition = function _triggerBackdropTransition() {
            var _this3 = this;
            var hideEventPrevented = $__default["default"].Event(EVENT_HIDE_PREVENTED);
            $__default["default"](this._element).trigger(hideEventPrevented);
            if (hideEventPrevented.isDefaultPrevented()) {
              return;
            }
            var isModalOverflowing = this._element.scrollHeight > document.documentElement.clientHeight;
            if (!isModalOverflowing) {
              this._element.style.overflowY = "hidden";
            }
            this._element.classList.add(CLASS_NAME_STATIC);
            var modalTransitionDuration = Util.getTransitionDurationFromElement(this._dialog);
            $__default["default"](this._element).off(Util.TRANSITION_END);
            $__default["default"](this._element).one(Util.TRANSITION_END, function() {
              _this3._element.classList.remove(CLASS_NAME_STATIC);
              if (!isModalOverflowing) {
                $__default["default"](_this3._element).one(Util.TRANSITION_END, function() {
                  _this3._element.style.overflowY = "";
                }).emulateTransitionEnd(_this3._element, modalTransitionDuration);
              }
            }).emulateTransitionEnd(modalTransitionDuration);
            this._element.focus();
          };
          _proto._showElement = function _showElement(relatedTarget) {
            var _this4 = this;
            var transition = $__default["default"](this._element).hasClass(CLASS_NAME_FADE$4);
            var modalBody = this._dialog ? this._dialog.querySelector(SELECTOR_MODAL_BODY) : null;
            if (!this._element.parentNode || this._element.parentNode.nodeType !== Node.ELEMENT_NODE) {
              document.body.appendChild(this._element);
            }
            this._element.style.display = "block";
            this._element.removeAttribute("aria-hidden");
            this._element.setAttribute("aria-modal", true);
            this._element.setAttribute("role", "dialog");
            if ($__default["default"](this._dialog).hasClass(CLASS_NAME_SCROLLABLE) && modalBody) {
              modalBody.scrollTop = 0;
            } else {
              this._element.scrollTop = 0;
            }
            if (transition) {
              Util.reflow(this._element);
            }
            $__default["default"](this._element).addClass(CLASS_NAME_SHOW$4);
            if (this._config.focus) {
              this._enforceFocus();
            }
            var shownEvent = $__default["default"].Event(EVENT_SHOWN$2, {
              relatedTarget
            });
            var transitionComplete = function transitionComplete2() {
              if (_this4._config.focus) {
                _this4._element.focus();
              }
              _this4._isTransitioning = false;
              $__default["default"](_this4._element).trigger(shownEvent);
            };
            if (transition) {
              var transitionDuration = Util.getTransitionDurationFromElement(this._dialog);
              $__default["default"](this._dialog).one(Util.TRANSITION_END, transitionComplete).emulateTransitionEnd(transitionDuration);
            } else {
              transitionComplete();
            }
          };
          _proto._enforceFocus = function _enforceFocus() {
            var _this5 = this;
            $__default["default"](document).off(EVENT_FOCUSIN).on(EVENT_FOCUSIN, function(event) {
              if (document !== event.target && _this5._element !== event.target && $__default["default"](_this5._element).has(event.target).length === 0) {
                _this5._element.focus();
              }
            });
          };
          _proto._setEscapeEvent = function _setEscapeEvent() {
            var _this6 = this;
            if (this._isShown) {
              $__default["default"](this._element).on(EVENT_KEYDOWN_DISMISS, function(event) {
                if (_this6._config.keyboard && event.which === ESCAPE_KEYCODE) {
                  event.preventDefault();
                  _this6.hide();
                } else if (!_this6._config.keyboard && event.which === ESCAPE_KEYCODE) {
                  _this6._triggerBackdropTransition();
                }
              });
            } else if (!this._isShown) {
              $__default["default"](this._element).off(EVENT_KEYDOWN_DISMISS);
            }
          };
          _proto._setResizeEvent = function _setResizeEvent() {
            var _this7 = this;
            if (this._isShown) {
              $__default["default"](window).on(EVENT_RESIZE, function(event) {
                return _this7.handleUpdate(event);
              });
            } else {
              $__default["default"](window).off(EVENT_RESIZE);
            }
          };
          _proto._hideModal = function _hideModal() {
            var _this8 = this;
            this._element.style.display = "none";
            this._element.setAttribute("aria-hidden", true);
            this._element.removeAttribute("aria-modal");
            this._element.removeAttribute("role");
            this._isTransitioning = false;
            this._showBackdrop(function() {
              $__default["default"](document.body).removeClass(CLASS_NAME_OPEN);
              _this8._resetAdjustments();
              _this8._resetScrollbar();
              $__default["default"](_this8._element).trigger(EVENT_HIDDEN$2);
            });
          };
          _proto._removeBackdrop = function _removeBackdrop() {
            if (this._backdrop) {
              $__default["default"](this._backdrop).remove();
              this._backdrop = null;
            }
          };
          _proto._showBackdrop = function _showBackdrop(callback) {
            var _this9 = this;
            var animate = $__default["default"](this._element).hasClass(CLASS_NAME_FADE$4) ? CLASS_NAME_FADE$4 : "";
            if (this._isShown && this._config.backdrop) {
              this._backdrop = document.createElement("div");
              this._backdrop.className = CLASS_NAME_BACKDROP;
              if (animate) {
                this._backdrop.classList.add(animate);
              }
              $__default["default"](this._backdrop).appendTo(document.body);
              $__default["default"](this._element).on(EVENT_CLICK_DISMISS$1, function(event) {
                if (_this9._ignoreBackdropClick) {
                  _this9._ignoreBackdropClick = false;
                  return;
                }
                if (event.target !== event.currentTarget) {
                  return;
                }
                if (_this9._config.backdrop === "static") {
                  _this9._triggerBackdropTransition();
                } else {
                  _this9.hide();
                }
              });
              if (animate) {
                Util.reflow(this._backdrop);
              }
              $__default["default"](this._backdrop).addClass(CLASS_NAME_SHOW$4);
              if (!callback) {
                return;
              }
              if (!animate) {
                callback();
                return;
              }
              var backdropTransitionDuration = Util.getTransitionDurationFromElement(this._backdrop);
              $__default["default"](this._backdrop).one(Util.TRANSITION_END, callback).emulateTransitionEnd(backdropTransitionDuration);
            } else if (!this._isShown && this._backdrop) {
              $__default["default"](this._backdrop).removeClass(CLASS_NAME_SHOW$4);
              var callbackRemove = function callbackRemove2() {
                _this9._removeBackdrop();
                if (callback) {
                  callback();
                }
              };
              if ($__default["default"](this._element).hasClass(CLASS_NAME_FADE$4)) {
                var _backdropTransitionDuration = Util.getTransitionDurationFromElement(this._backdrop);
                $__default["default"](this._backdrop).one(Util.TRANSITION_END, callbackRemove).emulateTransitionEnd(_backdropTransitionDuration);
              } else {
                callbackRemove();
              }
            } else if (callback) {
              callback();
            }
          };
          _proto._adjustDialog = function _adjustDialog() {
            var isModalOverflowing = this._element.scrollHeight > document.documentElement.clientHeight;
            if (!this._isBodyOverflowing && isModalOverflowing) {
              this._element.style.paddingLeft = this._scrollbarWidth + "px";
            }
            if (this._isBodyOverflowing && !isModalOverflowing) {
              this._element.style.paddingRight = this._scrollbarWidth + "px";
            }
          };
          _proto._resetAdjustments = function _resetAdjustments() {
            this._element.style.paddingLeft = "";
            this._element.style.paddingRight = "";
          };
          _proto._checkScrollbar = function _checkScrollbar() {
            var rect = document.body.getBoundingClientRect();
            this._isBodyOverflowing = Math.round(rect.left + rect.right) < window.innerWidth;
            this._scrollbarWidth = this._getScrollbarWidth();
          };
          _proto._setScrollbar = function _setScrollbar() {
            var _this10 = this;
            if (this._isBodyOverflowing) {
              var fixedContent = [].slice.call(document.querySelectorAll(SELECTOR_FIXED_CONTENT));
              var stickyContent = [].slice.call(document.querySelectorAll(SELECTOR_STICKY_CONTENT));
              $__default["default"](fixedContent).each(function(index, element) {
                var actualPadding2 = element.style.paddingRight;
                var calculatedPadding2 = $__default["default"](element).css("padding-right");
                $__default["default"](element).data("padding-right", actualPadding2).css("padding-right", parseFloat(calculatedPadding2) + _this10._scrollbarWidth + "px");
              });
              $__default["default"](stickyContent).each(function(index, element) {
                var actualMargin = element.style.marginRight;
                var calculatedMargin = $__default["default"](element).css("margin-right");
                $__default["default"](element).data("margin-right", actualMargin).css("margin-right", parseFloat(calculatedMargin) - _this10._scrollbarWidth + "px");
              });
              var actualPadding = document.body.style.paddingRight;
              var calculatedPadding = $__default["default"](document.body).css("padding-right");
              $__default["default"](document.body).data("padding-right", actualPadding).css("padding-right", parseFloat(calculatedPadding) + this._scrollbarWidth + "px");
            }
            $__default["default"](document.body).addClass(CLASS_NAME_OPEN);
          };
          _proto._resetScrollbar = function _resetScrollbar() {
            var fixedContent = [].slice.call(document.querySelectorAll(SELECTOR_FIXED_CONTENT));
            $__default["default"](fixedContent).each(function(index, element) {
              var padding2 = $__default["default"](element).data("padding-right");
              $__default["default"](element).removeData("padding-right");
              element.style.paddingRight = padding2 ? padding2 : "";
            });
            var elements = [].slice.call(document.querySelectorAll("" + SELECTOR_STICKY_CONTENT));
            $__default["default"](elements).each(function(index, element) {
              var margin = $__default["default"](element).data("margin-right");
              if (typeof margin !== "undefined") {
                $__default["default"](element).css("margin-right", margin).removeData("margin-right");
              }
            });
            var padding = $__default["default"](document.body).data("padding-right");
            $__default["default"](document.body).removeData("padding-right");
            document.body.style.paddingRight = padding ? padding : "";
          };
          _proto._getScrollbarWidth = function _getScrollbarWidth() {
            var scrollDiv = document.createElement("div");
            scrollDiv.className = CLASS_NAME_SCROLLBAR_MEASURER;
            document.body.appendChild(scrollDiv);
            var scrollbarWidth = scrollDiv.getBoundingClientRect().width - scrollDiv.clientWidth;
            document.body.removeChild(scrollDiv);
            return scrollbarWidth;
          };
          Modal2._jQueryInterface = function _jQueryInterface(config, relatedTarget) {
            return this.each(function() {
              var data = $__default["default"](this).data(DATA_KEY$5);
              var _config = _extends({}, Default$4, $__default["default"](this).data(), typeof config === "object" && config ? config : {});
              if (!data) {
                data = new Modal2(this, _config);
                $__default["default"](this).data(DATA_KEY$5, data);
              }
              if (typeof config === "string") {
                if (typeof data[config] === "undefined") {
                  throw new TypeError('No method named "' + config + '"');
                }
                data[config](relatedTarget);
              } else if (_config.show) {
                data.show(relatedTarget);
              }
            });
          };
          _createClass(Modal2, null, [{
            key: "VERSION",
            get: function get() {
              return VERSION$5;
            }
          }, {
            key: "Default",
            get: function get() {
              return Default$4;
            }
          }]);
          return Modal2;
        }();
        $__default["default"](document).on(EVENT_CLICK_DATA_API$1, SELECTOR_DATA_TOGGLE$1, function(event) {
          var _this11 = this;
          var target;
          var selector = Util.getSelectorFromElement(this);
          if (selector) {
            target = document.querySelector(selector);
          }
          var config = $__default["default"](target).data(DATA_KEY$5) ? "toggle" : _extends({}, $__default["default"](target).data(), $__default["default"](this).data());
          if (this.tagName === "A" || this.tagName === "AREA") {
            event.preventDefault();
          }
          var $target = $__default["default"](target).one(EVENT_SHOW$2, function(showEvent) {
            if (showEvent.isDefaultPrevented()) {
              return;
            }
            $target.one(EVENT_HIDDEN$2, function() {
              if ($__default["default"](_this11).is(":visible")) {
                _this11.focus();
              }
            });
          });
          Modal._jQueryInterface.call($__default["default"](target), config, this);
        });
        $__default["default"].fn[NAME$5] = Modal._jQueryInterface;
        $__default["default"].fn[NAME$5].Constructor = Modal;
        $__default["default"].fn[NAME$5].noConflict = function() {
          $__default["default"].fn[NAME$5] = JQUERY_NO_CONFLICT$5;
          return Modal._jQueryInterface;
        };
        var uriAttrs = ["background", "cite", "href", "itemtype", "longdesc", "poster", "src", "xlink:href"];
        var ARIA_ATTRIBUTE_PATTERN = /^aria-[\w-]*$/i;
        var DefaultWhitelist = {
          "*": ["class", "dir", "id", "lang", "role", ARIA_ATTRIBUTE_PATTERN],
          a: ["target", "href", "title", "rel"],
          area: [],
          b: [],
          br: [],
          col: [],
          code: [],
          div: [],
          em: [],
          hr: [],
          h1: [],
          h2: [],
          h3: [],
          h4: [],
          h5: [],
          h6: [],
          i: [],
          img: ["src", "srcset", "alt", "title", "width", "height"],
          li: [],
          ol: [],
          p: [],
          pre: [],
          s: [],
          small: [],
          span: [],
          sub: [],
          sup: [],
          strong: [],
          u: [],
          ul: []
        };
        var SAFE_URL_PATTERN = /^(?:(?:https?|mailto|ftp|tel|file|sms):|[^#&/:?]*(?:[#/?]|$))/i;
        var DATA_URL_PATTERN = /^data:(?:image\/(?:bmp|gif|jpeg|jpg|png|tiff|webp)|video\/(?:mpeg|mp4|ogg|webm)|audio\/(?:mp3|oga|ogg|opus));base64,[\d+/a-z]+=*$/i;
        function allowedAttribute(attr, allowedAttributeList) {
          var attrName = attr.nodeName.toLowerCase();
          if (allowedAttributeList.indexOf(attrName) !== -1) {
            if (uriAttrs.indexOf(attrName) !== -1) {
              return Boolean(SAFE_URL_PATTERN.test(attr.nodeValue) || DATA_URL_PATTERN.test(attr.nodeValue));
            }
            return true;
          }
          var regExp = allowedAttributeList.filter(function(attrRegex) {
            return attrRegex instanceof RegExp;
          });
          for (var i = 0, len = regExp.length; i < len; i++) {
            if (regExp[i].test(attrName)) {
              return true;
            }
          }
          return false;
        }
        function sanitizeHtml(unsafeHtml, whiteList, sanitizeFn) {
          if (unsafeHtml.length === 0) {
            return unsafeHtml;
          }
          if (sanitizeFn && typeof sanitizeFn === "function") {
            return sanitizeFn(unsafeHtml);
          }
          var domParser = new window.DOMParser();
          var createdDocument = domParser.parseFromString(unsafeHtml, "text/html");
          var whitelistKeys = Object.keys(whiteList);
          var elements = [].slice.call(createdDocument.body.querySelectorAll("*"));
          var _loop = function _loop2(i2, len2) {
            var el = elements[i2];
            var elName = el.nodeName.toLowerCase();
            if (whitelistKeys.indexOf(el.nodeName.toLowerCase()) === -1) {
              el.parentNode.removeChild(el);
              return "continue";
            }
            var attributeList = [].slice.call(el.attributes);
            var whitelistedAttributes = [].concat(whiteList["*"] || [], whiteList[elName] || []);
            attributeList.forEach(function(attr) {
              if (!allowedAttribute(attr, whitelistedAttributes)) {
                el.removeAttribute(attr.nodeName);
              }
            });
          };
          for (var i = 0, len = elements.length; i < len; i++) {
            var _ret = _loop(i);
            if (_ret === "continue")
              continue;
          }
          return createdDocument.body.innerHTML;
        }
        var NAME$4 = "tooltip";
        var VERSION$4 = "4.6.1";
        var DATA_KEY$4 = "bs.tooltip";
        var EVENT_KEY$4 = "." + DATA_KEY$4;
        var JQUERY_NO_CONFLICT$4 = $__default["default"].fn[NAME$4];
        var CLASS_PREFIX$1 = "bs-tooltip";
        var BSCLS_PREFIX_REGEX$1 = new RegExp("(^|\\s)" + CLASS_PREFIX$1 + "\\S+", "g");
        var DISALLOWED_ATTRIBUTES = ["sanitize", "whiteList", "sanitizeFn"];
        var CLASS_NAME_FADE$3 = "fade";
        var CLASS_NAME_SHOW$3 = "show";
        var HOVER_STATE_SHOW = "show";
        var HOVER_STATE_OUT = "out";
        var SELECTOR_TOOLTIP_INNER = ".tooltip-inner";
        var SELECTOR_ARROW = ".arrow";
        var TRIGGER_HOVER = "hover";
        var TRIGGER_FOCUS = "focus";
        var TRIGGER_CLICK = "click";
        var TRIGGER_MANUAL = "manual";
        var AttachmentMap = {
          AUTO: "auto",
          TOP: "top",
          RIGHT: "right",
          BOTTOM: "bottom",
          LEFT: "left"
        };
        var Default$3 = {
          animation: true,
          template: '<div class="tooltip" role="tooltip"><div class="arrow"></div><div class="tooltip-inner"></div></div>',
          trigger: "hover focus",
          title: "",
          delay: 0,
          html: false,
          selector: false,
          placement: "top",
          offset: 0,
          container: false,
          fallbackPlacement: "flip",
          boundary: "scrollParent",
          customClass: "",
          sanitize: true,
          sanitizeFn: null,
          whiteList: DefaultWhitelist,
          popperConfig: null
        };
        var DefaultType$3 = {
          animation: "boolean",
          template: "string",
          title: "(string|element|function)",
          trigger: "string",
          delay: "(number|object)",
          html: "boolean",
          selector: "(string|boolean)",
          placement: "(string|function)",
          offset: "(number|string|function)",
          container: "(string|element|boolean)",
          fallbackPlacement: "(string|array)",
          boundary: "(string|element)",
          customClass: "(string|function)",
          sanitize: "boolean",
          sanitizeFn: "(null|function)",
          whiteList: "object",
          popperConfig: "(null|object)"
        };
        var Event$1 = {
          HIDE: "hide" + EVENT_KEY$4,
          HIDDEN: "hidden" + EVENT_KEY$4,
          SHOW: "show" + EVENT_KEY$4,
          SHOWN: "shown" + EVENT_KEY$4,
          INSERTED: "inserted" + EVENT_KEY$4,
          CLICK: "click" + EVENT_KEY$4,
          FOCUSIN: "focusin" + EVENT_KEY$4,
          FOCUSOUT: "focusout" + EVENT_KEY$4,
          MOUSEENTER: "mouseenter" + EVENT_KEY$4,
          MOUSELEAVE: "mouseleave" + EVENT_KEY$4
        };
        var Tooltip = /* @__PURE__ */ function() {
          function Tooltip2(element, config) {
            if (typeof Popper__default["default"] === "undefined") {
              throw new TypeError("Bootstrap's tooltips require Popper (https://popper.js.org)");
            }
            this._isEnabled = true;
            this._timeout = 0;
            this._hoverState = "";
            this._activeTrigger = {};
            this._popper = null;
            this.element = element;
            this.config = this._getConfig(config);
            this.tip = null;
            this._setListeners();
          }
          var _proto = Tooltip2.prototype;
          _proto.enable = function enable() {
            this._isEnabled = true;
          };
          _proto.disable = function disable() {
            this._isEnabled = false;
          };
          _proto.toggleEnabled = function toggleEnabled() {
            this._isEnabled = !this._isEnabled;
          };
          _proto.toggle = function toggle(event) {
            if (!this._isEnabled) {
              return;
            }
            if (event) {
              var dataKey = this.constructor.DATA_KEY;
              var context = $__default["default"](event.currentTarget).data(dataKey);
              if (!context) {
                context = new this.constructor(event.currentTarget, this._getDelegateConfig());
                $__default["default"](event.currentTarget).data(dataKey, context);
              }
              context._activeTrigger.click = !context._activeTrigger.click;
              if (context._isWithActiveTrigger()) {
                context._enter(null, context);
              } else {
                context._leave(null, context);
              }
            } else {
              if ($__default["default"](this.getTipElement()).hasClass(CLASS_NAME_SHOW$3)) {
                this._leave(null, this);
                return;
              }
              this._enter(null, this);
            }
          };
          _proto.dispose = function dispose() {
            clearTimeout(this._timeout);
            $__default["default"].removeData(this.element, this.constructor.DATA_KEY);
            $__default["default"](this.element).off(this.constructor.EVENT_KEY);
            $__default["default"](this.element).closest(".modal").off("hide.bs.modal", this._hideModalHandler);
            if (this.tip) {
              $__default["default"](this.tip).remove();
            }
            this._isEnabled = null;
            this._timeout = null;
            this._hoverState = null;
            this._activeTrigger = null;
            if (this._popper) {
              this._popper.destroy();
            }
            this._popper = null;
            this.element = null;
            this.config = null;
            this.tip = null;
          };
          _proto.show = function show() {
            var _this = this;
            if ($__default["default"](this.element).css("display") === "none") {
              throw new Error("Please use show on visible elements");
            }
            var showEvent = $__default["default"].Event(this.constructor.Event.SHOW);
            if (this.isWithContent() && this._isEnabled) {
              $__default["default"](this.element).trigger(showEvent);
              var shadowRoot = Util.findShadowRoot(this.element);
              var isInTheDom = $__default["default"].contains(shadowRoot !== null ? shadowRoot : this.element.ownerDocument.documentElement, this.element);
              if (showEvent.isDefaultPrevented() || !isInTheDom) {
                return;
              }
              var tip = this.getTipElement();
              var tipId = Util.getUID(this.constructor.NAME);
              tip.setAttribute("id", tipId);
              this.element.setAttribute("aria-describedby", tipId);
              this.setContent();
              if (this.config.animation) {
                $__default["default"](tip).addClass(CLASS_NAME_FADE$3);
              }
              var placement = typeof this.config.placement === "function" ? this.config.placement.call(this, tip, this.element) : this.config.placement;
              var attachment = this._getAttachment(placement);
              this.addAttachmentClass(attachment);
              var container = this._getContainer();
              $__default["default"](tip).data(this.constructor.DATA_KEY, this);
              if (!$__default["default"].contains(this.element.ownerDocument.documentElement, this.tip)) {
                $__default["default"](tip).appendTo(container);
              }
              $__default["default"](this.element).trigger(this.constructor.Event.INSERTED);
              this._popper = new Popper__default["default"](this.element, tip, this._getPopperConfig(attachment));
              $__default["default"](tip).addClass(CLASS_NAME_SHOW$3);
              $__default["default"](tip).addClass(this.config.customClass);
              if ("ontouchstart" in document.documentElement) {
                $__default["default"](document.body).children().on("mouseover", null, $__default["default"].noop);
              }
              var complete = function complete2() {
                if (_this.config.animation) {
                  _this._fixTransition();
                }
                var prevHoverState = _this._hoverState;
                _this._hoverState = null;
                $__default["default"](_this.element).trigger(_this.constructor.Event.SHOWN);
                if (prevHoverState === HOVER_STATE_OUT) {
                  _this._leave(null, _this);
                }
              };
              if ($__default["default"](this.tip).hasClass(CLASS_NAME_FADE$3)) {
                var transitionDuration = Util.getTransitionDurationFromElement(this.tip);
                $__default["default"](this.tip).one(Util.TRANSITION_END, complete).emulateTransitionEnd(transitionDuration);
              } else {
                complete();
              }
            }
          };
          _proto.hide = function hide(callback) {
            var _this2 = this;
            var tip = this.getTipElement();
            var hideEvent = $__default["default"].Event(this.constructor.Event.HIDE);
            var complete = function complete2() {
              if (_this2._hoverState !== HOVER_STATE_SHOW && tip.parentNode) {
                tip.parentNode.removeChild(tip);
              }
              _this2._cleanTipClass();
              _this2.element.removeAttribute("aria-describedby");
              $__default["default"](_this2.element).trigger(_this2.constructor.Event.HIDDEN);
              if (_this2._popper !== null) {
                _this2._popper.destroy();
              }
              if (callback) {
                callback();
              }
            };
            $__default["default"](this.element).trigger(hideEvent);
            if (hideEvent.isDefaultPrevented()) {
              return;
            }
            $__default["default"](tip).removeClass(CLASS_NAME_SHOW$3);
            if ("ontouchstart" in document.documentElement) {
              $__default["default"](document.body).children().off("mouseover", null, $__default["default"].noop);
            }
            this._activeTrigger[TRIGGER_CLICK] = false;
            this._activeTrigger[TRIGGER_FOCUS] = false;
            this._activeTrigger[TRIGGER_HOVER] = false;
            if ($__default["default"](this.tip).hasClass(CLASS_NAME_FADE$3)) {
              var transitionDuration = Util.getTransitionDurationFromElement(tip);
              $__default["default"](tip).one(Util.TRANSITION_END, complete).emulateTransitionEnd(transitionDuration);
            } else {
              complete();
            }
            this._hoverState = "";
          };
          _proto.update = function update() {
            if (this._popper !== null) {
              this._popper.scheduleUpdate();
            }
          };
          _proto.isWithContent = function isWithContent() {
            return Boolean(this.getTitle());
          };
          _proto.addAttachmentClass = function addAttachmentClass(attachment) {
            $__default["default"](this.getTipElement()).addClass(CLASS_PREFIX$1 + "-" + attachment);
          };
          _proto.getTipElement = function getTipElement() {
            this.tip = this.tip || $__default["default"](this.config.template)[0];
            return this.tip;
          };
          _proto.setContent = function setContent() {
            var tip = this.getTipElement();
            this.setElementContent($__default["default"](tip.querySelectorAll(SELECTOR_TOOLTIP_INNER)), this.getTitle());
            $__default["default"](tip).removeClass(CLASS_NAME_FADE$3 + " " + CLASS_NAME_SHOW$3);
          };
          _proto.setElementContent = function setElementContent($element, content) {
            if (typeof content === "object" && (content.nodeType || content.jquery)) {
              if (this.config.html) {
                if (!$__default["default"](content).parent().is($element)) {
                  $element.empty().append(content);
                }
              } else {
                $element.text($__default["default"](content).text());
              }
              return;
            }
            if (this.config.html) {
              if (this.config.sanitize) {
                content = sanitizeHtml(content, this.config.whiteList, this.config.sanitizeFn);
              }
              $element.html(content);
            } else {
              $element.text(content);
            }
          };
          _proto.getTitle = function getTitle() {
            var title = this.element.getAttribute("data-original-title");
            if (!title) {
              title = typeof this.config.title === "function" ? this.config.title.call(this.element) : this.config.title;
            }
            return title;
          };
          _proto._getPopperConfig = function _getPopperConfig(attachment) {
            var _this3 = this;
            var defaultBsConfig = {
              placement: attachment,
              modifiers: {
                offset: this._getOffset(),
                flip: {
                  behavior: this.config.fallbackPlacement
                },
                arrow: {
                  element: SELECTOR_ARROW
                },
                preventOverflow: {
                  boundariesElement: this.config.boundary
                }
              },
              onCreate: function onCreate(data) {
                if (data.originalPlacement !== data.placement) {
                  _this3._handlePopperPlacementChange(data);
                }
              },
              onUpdate: function onUpdate(data) {
                return _this3._handlePopperPlacementChange(data);
              }
            };
            return _extends({}, defaultBsConfig, this.config.popperConfig);
          };
          _proto._getOffset = function _getOffset() {
            var _this4 = this;
            var offset = {};
            if (typeof this.config.offset === "function") {
              offset.fn = function(data) {
                data.offsets = _extends({}, data.offsets, _this4.config.offset(data.offsets, _this4.element));
                return data;
              };
            } else {
              offset.offset = this.config.offset;
            }
            return offset;
          };
          _proto._getContainer = function _getContainer() {
            if (this.config.container === false) {
              return document.body;
            }
            if (Util.isElement(this.config.container)) {
              return $__default["default"](this.config.container);
            }
            return $__default["default"](document).find(this.config.container);
          };
          _proto._getAttachment = function _getAttachment(placement) {
            return AttachmentMap[placement.toUpperCase()];
          };
          _proto._setListeners = function _setListeners() {
            var _this5 = this;
            var triggers = this.config.trigger.split(" ");
            triggers.forEach(function(trigger) {
              if (trigger === "click") {
                $__default["default"](_this5.element).on(_this5.constructor.Event.CLICK, _this5.config.selector, function(event) {
                  return _this5.toggle(event);
                });
              } else if (trigger !== TRIGGER_MANUAL) {
                var eventIn = trigger === TRIGGER_HOVER ? _this5.constructor.Event.MOUSEENTER : _this5.constructor.Event.FOCUSIN;
                var eventOut = trigger === TRIGGER_HOVER ? _this5.constructor.Event.MOUSELEAVE : _this5.constructor.Event.FOCUSOUT;
                $__default["default"](_this5.element).on(eventIn, _this5.config.selector, function(event) {
                  return _this5._enter(event);
                }).on(eventOut, _this5.config.selector, function(event) {
                  return _this5._leave(event);
                });
              }
            });
            this._hideModalHandler = function() {
              if (_this5.element) {
                _this5.hide();
              }
            };
            $__default["default"](this.element).closest(".modal").on("hide.bs.modal", this._hideModalHandler);
            if (this.config.selector) {
              this.config = _extends({}, this.config, {
                trigger: "manual",
                selector: ""
              });
            } else {
              this._fixTitle();
            }
          };
          _proto._fixTitle = function _fixTitle() {
            var titleType = typeof this.element.getAttribute("data-original-title");
            if (this.element.getAttribute("title") || titleType !== "string") {
              this.element.setAttribute("data-original-title", this.element.getAttribute("title") || "");
              this.element.setAttribute("title", "");
            }
          };
          _proto._enter = function _enter(event, context) {
            var dataKey = this.constructor.DATA_KEY;
            context = context || $__default["default"](event.currentTarget).data(dataKey);
            if (!context) {
              context = new this.constructor(event.currentTarget, this._getDelegateConfig());
              $__default["default"](event.currentTarget).data(dataKey, context);
            }
            if (event) {
              context._activeTrigger[event.type === "focusin" ? TRIGGER_FOCUS : TRIGGER_HOVER] = true;
            }
            if ($__default["default"](context.getTipElement()).hasClass(CLASS_NAME_SHOW$3) || context._hoverState === HOVER_STATE_SHOW) {
              context._hoverState = HOVER_STATE_SHOW;
              return;
            }
            clearTimeout(context._timeout);
            context._hoverState = HOVER_STATE_SHOW;
            if (!context.config.delay || !context.config.delay.show) {
              context.show();
              return;
            }
            context._timeout = setTimeout(function() {
              if (context._hoverState === HOVER_STATE_SHOW) {
                context.show();
              }
            }, context.config.delay.show);
          };
          _proto._leave = function _leave(event, context) {
            var dataKey = this.constructor.DATA_KEY;
            context = context || $__default["default"](event.currentTarget).data(dataKey);
            if (!context) {
              context = new this.constructor(event.currentTarget, this._getDelegateConfig());
              $__default["default"](event.currentTarget).data(dataKey, context);
            }
            if (event) {
              context._activeTrigger[event.type === "focusout" ? TRIGGER_FOCUS : TRIGGER_HOVER] = false;
            }
            if (context._isWithActiveTrigger()) {
              return;
            }
            clearTimeout(context._timeout);
            context._hoverState = HOVER_STATE_OUT;
            if (!context.config.delay || !context.config.delay.hide) {
              context.hide();
              return;
            }
            context._timeout = setTimeout(function() {
              if (context._hoverState === HOVER_STATE_OUT) {
                context.hide();
              }
            }, context.config.delay.hide);
          };
          _proto._isWithActiveTrigger = function _isWithActiveTrigger() {
            for (var trigger in this._activeTrigger) {
              if (this._activeTrigger[trigger]) {
                return true;
              }
            }
            return false;
          };
          _proto._getConfig = function _getConfig(config) {
            var dataAttributes = $__default["default"](this.element).data();
            Object.keys(dataAttributes).forEach(function(dataAttr) {
              if (DISALLOWED_ATTRIBUTES.indexOf(dataAttr) !== -1) {
                delete dataAttributes[dataAttr];
              }
            });
            config = _extends({}, this.constructor.Default, dataAttributes, typeof config === "object" && config ? config : {});
            if (typeof config.delay === "number") {
              config.delay = {
                show: config.delay,
                hide: config.delay
              };
            }
            if (typeof config.title === "number") {
              config.title = config.title.toString();
            }
            if (typeof config.content === "number") {
              config.content = config.content.toString();
            }
            Util.typeCheckConfig(NAME$4, config, this.constructor.DefaultType);
            if (config.sanitize) {
              config.template = sanitizeHtml(config.template, config.whiteList, config.sanitizeFn);
            }
            return config;
          };
          _proto._getDelegateConfig = function _getDelegateConfig() {
            var config = {};
            if (this.config) {
              for (var key in this.config) {
                if (this.constructor.Default[key] !== this.config[key]) {
                  config[key] = this.config[key];
                }
              }
            }
            return config;
          };
          _proto._cleanTipClass = function _cleanTipClass() {
            var $tip = $__default["default"](this.getTipElement());
            var tabClass = $tip.attr("class").match(BSCLS_PREFIX_REGEX$1);
            if (tabClass !== null && tabClass.length) {
              $tip.removeClass(tabClass.join(""));
            }
          };
          _proto._handlePopperPlacementChange = function _handlePopperPlacementChange(popperData) {
            this.tip = popperData.instance.popper;
            this._cleanTipClass();
            this.addAttachmentClass(this._getAttachment(popperData.placement));
          };
          _proto._fixTransition = function _fixTransition() {
            var tip = this.getTipElement();
            var initConfigAnimation = this.config.animation;
            if (tip.getAttribute("x-placement") !== null) {
              return;
            }
            $__default["default"](tip).removeClass(CLASS_NAME_FADE$3);
            this.config.animation = false;
            this.hide();
            this.show();
            this.config.animation = initConfigAnimation;
          };
          Tooltip2._jQueryInterface = function _jQueryInterface(config) {
            return this.each(function() {
              var $element = $__default["default"](this);
              var data = $element.data(DATA_KEY$4);
              var _config = typeof config === "object" && config;
              if (!data && /dispose|hide/.test(config)) {
                return;
              }
              if (!data) {
                data = new Tooltip2(this, _config);
                $element.data(DATA_KEY$4, data);
              }
              if (typeof config === "string") {
                if (typeof data[config] === "undefined") {
                  throw new TypeError('No method named "' + config + '"');
                }
                data[config]();
              }
            });
          };
          _createClass(Tooltip2, null, [{
            key: "VERSION",
            get: function get() {
              return VERSION$4;
            }
          }, {
            key: "Default",
            get: function get() {
              return Default$3;
            }
          }, {
            key: "NAME",
            get: function get() {
              return NAME$4;
            }
          }, {
            key: "DATA_KEY",
            get: function get() {
              return DATA_KEY$4;
            }
          }, {
            key: "Event",
            get: function get() {
              return Event$1;
            }
          }, {
            key: "EVENT_KEY",
            get: function get() {
              return EVENT_KEY$4;
            }
          }, {
            key: "DefaultType",
            get: function get() {
              return DefaultType$3;
            }
          }]);
          return Tooltip2;
        }();
        $__default["default"].fn[NAME$4] = Tooltip._jQueryInterface;
        $__default["default"].fn[NAME$4].Constructor = Tooltip;
        $__default["default"].fn[NAME$4].noConflict = function() {
          $__default["default"].fn[NAME$4] = JQUERY_NO_CONFLICT$4;
          return Tooltip._jQueryInterface;
        };
        var NAME$3 = "popover";
        var VERSION$3 = "4.6.1";
        var DATA_KEY$3 = "bs.popover";
        var EVENT_KEY$3 = "." + DATA_KEY$3;
        var JQUERY_NO_CONFLICT$3 = $__default["default"].fn[NAME$3];
        var CLASS_PREFIX = "bs-popover";
        var BSCLS_PREFIX_REGEX = new RegExp("(^|\\s)" + CLASS_PREFIX + "\\S+", "g");
        var CLASS_NAME_FADE$2 = "fade";
        var CLASS_NAME_SHOW$2 = "show";
        var SELECTOR_TITLE = ".popover-header";
        var SELECTOR_CONTENT = ".popover-body";
        var Default$2 = _extends({}, Tooltip.Default, {
          placement: "right",
          trigger: "click",
          content: "",
          template: '<div class="popover" role="tooltip"><div class="arrow"></div><h3 class="popover-header"></h3><div class="popover-body"></div></div>'
        });
        var DefaultType$2 = _extends({}, Tooltip.DefaultType, {
          content: "(string|element|function)"
        });
        var Event2 = {
          HIDE: "hide" + EVENT_KEY$3,
          HIDDEN: "hidden" + EVENT_KEY$3,
          SHOW: "show" + EVENT_KEY$3,
          SHOWN: "shown" + EVENT_KEY$3,
          INSERTED: "inserted" + EVENT_KEY$3,
          CLICK: "click" + EVENT_KEY$3,
          FOCUSIN: "focusin" + EVENT_KEY$3,
          FOCUSOUT: "focusout" + EVENT_KEY$3,
          MOUSEENTER: "mouseenter" + EVENT_KEY$3,
          MOUSELEAVE: "mouseleave" + EVENT_KEY$3
        };
        var Popover = /* @__PURE__ */ function(_Tooltip) {
          _inheritsLoose(Popover2, _Tooltip);
          function Popover2() {
            return _Tooltip.apply(this, arguments) || this;
          }
          var _proto = Popover2.prototype;
          _proto.isWithContent = function isWithContent() {
            return this.getTitle() || this._getContent();
          };
          _proto.addAttachmentClass = function addAttachmentClass(attachment) {
            $__default["default"](this.getTipElement()).addClass(CLASS_PREFIX + "-" + attachment);
          };
          _proto.getTipElement = function getTipElement() {
            this.tip = this.tip || $__default["default"](this.config.template)[0];
            return this.tip;
          };
          _proto.setContent = function setContent() {
            var $tip = $__default["default"](this.getTipElement());
            this.setElementContent($tip.find(SELECTOR_TITLE), this.getTitle());
            var content = this._getContent();
            if (typeof content === "function") {
              content = content.call(this.element);
            }
            this.setElementContent($tip.find(SELECTOR_CONTENT), content);
            $tip.removeClass(CLASS_NAME_FADE$2 + " " + CLASS_NAME_SHOW$2);
          };
          _proto._getContent = function _getContent() {
            return this.element.getAttribute("data-content") || this.config.content;
          };
          _proto._cleanTipClass = function _cleanTipClass() {
            var $tip = $__default["default"](this.getTipElement());
            var tabClass = $tip.attr("class").match(BSCLS_PREFIX_REGEX);
            if (tabClass !== null && tabClass.length > 0) {
              $tip.removeClass(tabClass.join(""));
            }
          };
          Popover2._jQueryInterface = function _jQueryInterface(config) {
            return this.each(function() {
              var data = $__default["default"](this).data(DATA_KEY$3);
              var _config = typeof config === "object" ? config : null;
              if (!data && /dispose|hide/.test(config)) {
                return;
              }
              if (!data) {
                data = new Popover2(this, _config);
                $__default["default"](this).data(DATA_KEY$3, data);
              }
              if (typeof config === "string") {
                if (typeof data[config] === "undefined") {
                  throw new TypeError('No method named "' + config + '"');
                }
                data[config]();
              }
            });
          };
          _createClass(Popover2, null, [{
            key: "VERSION",
            get: function get() {
              return VERSION$3;
            }
          }, {
            key: "Default",
            get: function get() {
              return Default$2;
            }
          }, {
            key: "NAME",
            get: function get() {
              return NAME$3;
            }
          }, {
            key: "DATA_KEY",
            get: function get() {
              return DATA_KEY$3;
            }
          }, {
            key: "Event",
            get: function get() {
              return Event2;
            }
          }, {
            key: "EVENT_KEY",
            get: function get() {
              return EVENT_KEY$3;
            }
          }, {
            key: "DefaultType",
            get: function get() {
              return DefaultType$2;
            }
          }]);
          return Popover2;
        }(Tooltip);
        $__default["default"].fn[NAME$3] = Popover._jQueryInterface;
        $__default["default"].fn[NAME$3].Constructor = Popover;
        $__default["default"].fn[NAME$3].noConflict = function() {
          $__default["default"].fn[NAME$3] = JQUERY_NO_CONFLICT$3;
          return Popover._jQueryInterface;
        };
        var NAME$2 = "scrollspy";
        var VERSION$2 = "4.6.1";
        var DATA_KEY$2 = "bs.scrollspy";
        var EVENT_KEY$2 = "." + DATA_KEY$2;
        var DATA_API_KEY$1 = ".data-api";
        var JQUERY_NO_CONFLICT$2 = $__default["default"].fn[NAME$2];
        var CLASS_NAME_DROPDOWN_ITEM = "dropdown-item";
        var CLASS_NAME_ACTIVE$1 = "active";
        var EVENT_ACTIVATE = "activate" + EVENT_KEY$2;
        var EVENT_SCROLL = "scroll" + EVENT_KEY$2;
        var EVENT_LOAD_DATA_API = "load" + EVENT_KEY$2 + DATA_API_KEY$1;
        var METHOD_OFFSET = "offset";
        var METHOD_POSITION = "position";
        var SELECTOR_DATA_SPY = '[data-spy="scroll"]';
        var SELECTOR_NAV_LIST_GROUP$1 = ".nav, .list-group";
        var SELECTOR_NAV_LINKS = ".nav-link";
        var SELECTOR_NAV_ITEMS = ".nav-item";
        var SELECTOR_LIST_ITEMS = ".list-group-item";
        var SELECTOR_DROPDOWN$1 = ".dropdown";
        var SELECTOR_DROPDOWN_ITEMS = ".dropdown-item";
        var SELECTOR_DROPDOWN_TOGGLE$1 = ".dropdown-toggle";
        var Default$1 = {
          offset: 10,
          method: "auto",
          target: ""
        };
        var DefaultType$1 = {
          offset: "number",
          method: "string",
          target: "(string|element)"
        };
        var ScrollSpy = /* @__PURE__ */ function() {
          function ScrollSpy2(element, config) {
            var _this = this;
            this._element = element;
            this._scrollElement = element.tagName === "BODY" ? window : element;
            this._config = this._getConfig(config);
            this._selector = this._config.target + " " + SELECTOR_NAV_LINKS + "," + (this._config.target + " " + SELECTOR_LIST_ITEMS + ",") + (this._config.target + " " + SELECTOR_DROPDOWN_ITEMS);
            this._offsets = [];
            this._targets = [];
            this._activeTarget = null;
            this._scrollHeight = 0;
            $__default["default"](this._scrollElement).on(EVENT_SCROLL, function(event) {
              return _this._process(event);
            });
            this.refresh();
            this._process();
          }
          var _proto = ScrollSpy2.prototype;
          _proto.refresh = function refresh() {
            var _this2 = this;
            var autoMethod = this._scrollElement === this._scrollElement.window ? METHOD_OFFSET : METHOD_POSITION;
            var offsetMethod = this._config.method === "auto" ? autoMethod : this._config.method;
            var offsetBase = offsetMethod === METHOD_POSITION ? this._getScrollTop() : 0;
            this._offsets = [];
            this._targets = [];
            this._scrollHeight = this._getScrollHeight();
            var targets = [].slice.call(document.querySelectorAll(this._selector));
            targets.map(function(element) {
              var target;
              var targetSelector = Util.getSelectorFromElement(element);
              if (targetSelector) {
                target = document.querySelector(targetSelector);
              }
              if (target) {
                var targetBCR = target.getBoundingClientRect();
                if (targetBCR.width || targetBCR.height) {
                  return [$__default["default"](target)[offsetMethod]().top + offsetBase, targetSelector];
                }
              }
              return null;
            }).filter(function(item) {
              return item;
            }).sort(function(a, b) {
              return a[0] - b[0];
            }).forEach(function(item) {
              _this2._offsets.push(item[0]);
              _this2._targets.push(item[1]);
            });
          };
          _proto.dispose = function dispose() {
            $__default["default"].removeData(this._element, DATA_KEY$2);
            $__default["default"](this._scrollElement).off(EVENT_KEY$2);
            this._element = null;
            this._scrollElement = null;
            this._config = null;
            this._selector = null;
            this._offsets = null;
            this._targets = null;
            this._activeTarget = null;
            this._scrollHeight = null;
          };
          _proto._getConfig = function _getConfig(config) {
            config = _extends({}, Default$1, typeof config === "object" && config ? config : {});
            if (typeof config.target !== "string" && Util.isElement(config.target)) {
              var id = $__default["default"](config.target).attr("id");
              if (!id) {
                id = Util.getUID(NAME$2);
                $__default["default"](config.target).attr("id", id);
              }
              config.target = "#" + id;
            }
            Util.typeCheckConfig(NAME$2, config, DefaultType$1);
            return config;
          };
          _proto._getScrollTop = function _getScrollTop() {
            return this._scrollElement === window ? this._scrollElement.pageYOffset : this._scrollElement.scrollTop;
          };
          _proto._getScrollHeight = function _getScrollHeight() {
            return this._scrollElement.scrollHeight || Math.max(document.body.scrollHeight, document.documentElement.scrollHeight);
          };
          _proto._getOffsetHeight = function _getOffsetHeight() {
            return this._scrollElement === window ? window.innerHeight : this._scrollElement.getBoundingClientRect().height;
          };
          _proto._process = function _process() {
            var scrollTop = this._getScrollTop() + this._config.offset;
            var scrollHeight = this._getScrollHeight();
            var maxScroll = this._config.offset + scrollHeight - this._getOffsetHeight();
            if (this._scrollHeight !== scrollHeight) {
              this.refresh();
            }
            if (scrollTop >= maxScroll) {
              var target = this._targets[this._targets.length - 1];
              if (this._activeTarget !== target) {
                this._activate(target);
              }
              return;
            }
            if (this._activeTarget && scrollTop < this._offsets[0] && this._offsets[0] > 0) {
              this._activeTarget = null;
              this._clear();
              return;
            }
            for (var i = this._offsets.length; i--; ) {
              var isActiveTarget = this._activeTarget !== this._targets[i] && scrollTop >= this._offsets[i] && (typeof this._offsets[i + 1] === "undefined" || scrollTop < this._offsets[i + 1]);
              if (isActiveTarget) {
                this._activate(this._targets[i]);
              }
            }
          };
          _proto._activate = function _activate(target) {
            this._activeTarget = target;
            this._clear();
            var queries = this._selector.split(",").map(function(selector) {
              return selector + '[data-target="' + target + '"],' + selector + '[href="' + target + '"]';
            });
            var $link = $__default["default"]([].slice.call(document.querySelectorAll(queries.join(","))));
            if ($link.hasClass(CLASS_NAME_DROPDOWN_ITEM)) {
              $link.closest(SELECTOR_DROPDOWN$1).find(SELECTOR_DROPDOWN_TOGGLE$1).addClass(CLASS_NAME_ACTIVE$1);
              $link.addClass(CLASS_NAME_ACTIVE$1);
            } else {
              $link.addClass(CLASS_NAME_ACTIVE$1);
              $link.parents(SELECTOR_NAV_LIST_GROUP$1).prev(SELECTOR_NAV_LINKS + ", " + SELECTOR_LIST_ITEMS).addClass(CLASS_NAME_ACTIVE$1);
              $link.parents(SELECTOR_NAV_LIST_GROUP$1).prev(SELECTOR_NAV_ITEMS).children(SELECTOR_NAV_LINKS).addClass(CLASS_NAME_ACTIVE$1);
            }
            $__default["default"](this._scrollElement).trigger(EVENT_ACTIVATE, {
              relatedTarget: target
            });
          };
          _proto._clear = function _clear() {
            [].slice.call(document.querySelectorAll(this._selector)).filter(function(node) {
              return node.classList.contains(CLASS_NAME_ACTIVE$1);
            }).forEach(function(node) {
              return node.classList.remove(CLASS_NAME_ACTIVE$1);
            });
          };
          ScrollSpy2._jQueryInterface = function _jQueryInterface(config) {
            return this.each(function() {
              var data = $__default["default"](this).data(DATA_KEY$2);
              var _config = typeof config === "object" && config;
              if (!data) {
                data = new ScrollSpy2(this, _config);
                $__default["default"](this).data(DATA_KEY$2, data);
              }
              if (typeof config === "string") {
                if (typeof data[config] === "undefined") {
                  throw new TypeError('No method named "' + config + '"');
                }
                data[config]();
              }
            });
          };
          _createClass(ScrollSpy2, null, [{
            key: "VERSION",
            get: function get() {
              return VERSION$2;
            }
          }, {
            key: "Default",
            get: function get() {
              return Default$1;
            }
          }]);
          return ScrollSpy2;
        }();
        $__default["default"](window).on(EVENT_LOAD_DATA_API, function() {
          var scrollSpys = [].slice.call(document.querySelectorAll(SELECTOR_DATA_SPY));
          var scrollSpysLength = scrollSpys.length;
          for (var i = scrollSpysLength; i--; ) {
            var $spy = $__default["default"](scrollSpys[i]);
            ScrollSpy._jQueryInterface.call($spy, $spy.data());
          }
        });
        $__default["default"].fn[NAME$2] = ScrollSpy._jQueryInterface;
        $__default["default"].fn[NAME$2].Constructor = ScrollSpy;
        $__default["default"].fn[NAME$2].noConflict = function() {
          $__default["default"].fn[NAME$2] = JQUERY_NO_CONFLICT$2;
          return ScrollSpy._jQueryInterface;
        };
        var NAME$1 = "tab";
        var VERSION$1 = "4.6.1";
        var DATA_KEY$1 = "bs.tab";
        var EVENT_KEY$1 = "." + DATA_KEY$1;
        var DATA_API_KEY = ".data-api";
        var JQUERY_NO_CONFLICT$1 = $__default["default"].fn[NAME$1];
        var CLASS_NAME_DROPDOWN_MENU = "dropdown-menu";
        var CLASS_NAME_ACTIVE = "active";
        var CLASS_NAME_DISABLED = "disabled";
        var CLASS_NAME_FADE$1 = "fade";
        var CLASS_NAME_SHOW$1 = "show";
        var EVENT_HIDE$1 = "hide" + EVENT_KEY$1;
        var EVENT_HIDDEN$1 = "hidden" + EVENT_KEY$1;
        var EVENT_SHOW$1 = "show" + EVENT_KEY$1;
        var EVENT_SHOWN$1 = "shown" + EVENT_KEY$1;
        var EVENT_CLICK_DATA_API = "click" + EVENT_KEY$1 + DATA_API_KEY;
        var SELECTOR_DROPDOWN = ".dropdown";
        var SELECTOR_NAV_LIST_GROUP = ".nav, .list-group";
        var SELECTOR_ACTIVE = ".active";
        var SELECTOR_ACTIVE_UL = "> li > .active";
        var SELECTOR_DATA_TOGGLE = '[data-toggle="tab"], [data-toggle="pill"], [data-toggle="list"]';
        var SELECTOR_DROPDOWN_TOGGLE = ".dropdown-toggle";
        var SELECTOR_DROPDOWN_ACTIVE_CHILD = "> .dropdown-menu .active";
        var Tab = /* @__PURE__ */ function() {
          function Tab2(element) {
            this._element = element;
          }
          var _proto = Tab2.prototype;
          _proto.show = function show() {
            var _this = this;
            if (this._element.parentNode && this._element.parentNode.nodeType === Node.ELEMENT_NODE && $__default["default"](this._element).hasClass(CLASS_NAME_ACTIVE) || $__default["default"](this._element).hasClass(CLASS_NAME_DISABLED)) {
              return;
            }
            var target;
            var previous;
            var listElement = $__default["default"](this._element).closest(SELECTOR_NAV_LIST_GROUP)[0];
            var selector = Util.getSelectorFromElement(this._element);
            if (listElement) {
              var itemSelector = listElement.nodeName === "UL" || listElement.nodeName === "OL" ? SELECTOR_ACTIVE_UL : SELECTOR_ACTIVE;
              previous = $__default["default"].makeArray($__default["default"](listElement).find(itemSelector));
              previous = previous[previous.length - 1];
            }
            var hideEvent = $__default["default"].Event(EVENT_HIDE$1, {
              relatedTarget: this._element
            });
            var showEvent = $__default["default"].Event(EVENT_SHOW$1, {
              relatedTarget: previous
            });
            if (previous) {
              $__default["default"](previous).trigger(hideEvent);
            }
            $__default["default"](this._element).trigger(showEvent);
            if (showEvent.isDefaultPrevented() || hideEvent.isDefaultPrevented()) {
              return;
            }
            if (selector) {
              target = document.querySelector(selector);
            }
            this._activate(this._element, listElement);
            var complete = function complete2() {
              var hiddenEvent = $__default["default"].Event(EVENT_HIDDEN$1, {
                relatedTarget: _this._element
              });
              var shownEvent = $__default["default"].Event(EVENT_SHOWN$1, {
                relatedTarget: previous
              });
              $__default["default"](previous).trigger(hiddenEvent);
              $__default["default"](_this._element).trigger(shownEvent);
            };
            if (target) {
              this._activate(target, target.parentNode, complete);
            } else {
              complete();
            }
          };
          _proto.dispose = function dispose() {
            $__default["default"].removeData(this._element, DATA_KEY$1);
            this._element = null;
          };
          _proto._activate = function _activate(element, container, callback) {
            var _this2 = this;
            var activeElements = container && (container.nodeName === "UL" || container.nodeName === "OL") ? $__default["default"](container).find(SELECTOR_ACTIVE_UL) : $__default["default"](container).children(SELECTOR_ACTIVE);
            var active = activeElements[0];
            var isTransitioning = callback && active && $__default["default"](active).hasClass(CLASS_NAME_FADE$1);
            var complete = function complete2() {
              return _this2._transitionComplete(element, active, callback);
            };
            if (active && isTransitioning) {
              var transitionDuration = Util.getTransitionDurationFromElement(active);
              $__default["default"](active).removeClass(CLASS_NAME_SHOW$1).one(Util.TRANSITION_END, complete).emulateTransitionEnd(transitionDuration);
            } else {
              complete();
            }
          };
          _proto._transitionComplete = function _transitionComplete(element, active, callback) {
            if (active) {
              $__default["default"](active).removeClass(CLASS_NAME_ACTIVE);
              var dropdownChild = $__default["default"](active.parentNode).find(SELECTOR_DROPDOWN_ACTIVE_CHILD)[0];
              if (dropdownChild) {
                $__default["default"](dropdownChild).removeClass(CLASS_NAME_ACTIVE);
              }
              if (active.getAttribute("role") === "tab") {
                active.setAttribute("aria-selected", false);
              }
            }
            $__default["default"](element).addClass(CLASS_NAME_ACTIVE);
            if (element.getAttribute("role") === "tab") {
              element.setAttribute("aria-selected", true);
            }
            Util.reflow(element);
            if (element.classList.contains(CLASS_NAME_FADE$1)) {
              element.classList.add(CLASS_NAME_SHOW$1);
            }
            var parent = element.parentNode;
            if (parent && parent.nodeName === "LI") {
              parent = parent.parentNode;
            }
            if (parent && $__default["default"](parent).hasClass(CLASS_NAME_DROPDOWN_MENU)) {
              var dropdownElement = $__default["default"](element).closest(SELECTOR_DROPDOWN)[0];
              if (dropdownElement) {
                var dropdownToggleList = [].slice.call(dropdownElement.querySelectorAll(SELECTOR_DROPDOWN_TOGGLE));
                $__default["default"](dropdownToggleList).addClass(CLASS_NAME_ACTIVE);
              }
              element.setAttribute("aria-expanded", true);
            }
            if (callback) {
              callback();
            }
          };
          Tab2._jQueryInterface = function _jQueryInterface(config) {
            return this.each(function() {
              var $this = $__default["default"](this);
              var data = $this.data(DATA_KEY$1);
              if (!data) {
                data = new Tab2(this);
                $this.data(DATA_KEY$1, data);
              }
              if (typeof config === "string") {
                if (typeof data[config] === "undefined") {
                  throw new TypeError('No method named "' + config + '"');
                }
                data[config]();
              }
            });
          };
          _createClass(Tab2, null, [{
            key: "VERSION",
            get: function get() {
              return VERSION$1;
            }
          }]);
          return Tab2;
        }();
        $__default["default"](document).on(EVENT_CLICK_DATA_API, SELECTOR_DATA_TOGGLE, function(event) {
          event.preventDefault();
          Tab._jQueryInterface.call($__default["default"](this), "show");
        });
        $__default["default"].fn[NAME$1] = Tab._jQueryInterface;
        $__default["default"].fn[NAME$1].Constructor = Tab;
        $__default["default"].fn[NAME$1].noConflict = function() {
          $__default["default"].fn[NAME$1] = JQUERY_NO_CONFLICT$1;
          return Tab._jQueryInterface;
        };
        var NAME = "toast";
        var VERSION = "4.6.1";
        var DATA_KEY = "bs.toast";
        var EVENT_KEY = "." + DATA_KEY;
        var JQUERY_NO_CONFLICT = $__default["default"].fn[NAME];
        var CLASS_NAME_FADE = "fade";
        var CLASS_NAME_HIDE = "hide";
        var CLASS_NAME_SHOW = "show";
        var CLASS_NAME_SHOWING = "showing";
        var EVENT_CLICK_DISMISS = "click.dismiss" + EVENT_KEY;
        var EVENT_HIDE = "hide" + EVENT_KEY;
        var EVENT_HIDDEN = "hidden" + EVENT_KEY;
        var EVENT_SHOW = "show" + EVENT_KEY;
        var EVENT_SHOWN = "shown" + EVENT_KEY;
        var SELECTOR_DATA_DISMISS = '[data-dismiss="toast"]';
        var Default = {
          animation: true,
          autohide: true,
          delay: 500
        };
        var DefaultType = {
          animation: "boolean",
          autohide: "boolean",
          delay: "number"
        };
        var Toast = /* @__PURE__ */ function() {
          function Toast2(element, config) {
            this._element = element;
            this._config = this._getConfig(config);
            this._timeout = null;
            this._setListeners();
          }
          var _proto = Toast2.prototype;
          _proto.show = function show() {
            var _this = this;
            var showEvent = $__default["default"].Event(EVENT_SHOW);
            $__default["default"](this._element).trigger(showEvent);
            if (showEvent.isDefaultPrevented()) {
              return;
            }
            this._clearTimeout();
            if (this._config.animation) {
              this._element.classList.add(CLASS_NAME_FADE);
            }
            var complete = function complete2() {
              _this._element.classList.remove(CLASS_NAME_SHOWING);
              _this._element.classList.add(CLASS_NAME_SHOW);
              $__default["default"](_this._element).trigger(EVENT_SHOWN);
              if (_this._config.autohide) {
                _this._timeout = setTimeout(function() {
                  _this.hide();
                }, _this._config.delay);
              }
            };
            this._element.classList.remove(CLASS_NAME_HIDE);
            Util.reflow(this._element);
            this._element.classList.add(CLASS_NAME_SHOWING);
            if (this._config.animation) {
              var transitionDuration = Util.getTransitionDurationFromElement(this._element);
              $__default["default"](this._element).one(Util.TRANSITION_END, complete).emulateTransitionEnd(transitionDuration);
            } else {
              complete();
            }
          };
          _proto.hide = function hide() {
            if (!this._element.classList.contains(CLASS_NAME_SHOW)) {
              return;
            }
            var hideEvent = $__default["default"].Event(EVENT_HIDE);
            $__default["default"](this._element).trigger(hideEvent);
            if (hideEvent.isDefaultPrevented()) {
              return;
            }
            this._close();
          };
          _proto.dispose = function dispose() {
            this._clearTimeout();
            if (this._element.classList.contains(CLASS_NAME_SHOW)) {
              this._element.classList.remove(CLASS_NAME_SHOW);
            }
            $__default["default"](this._element).off(EVENT_CLICK_DISMISS);
            $__default["default"].removeData(this._element, DATA_KEY);
            this._element = null;
            this._config = null;
          };
          _proto._getConfig = function _getConfig(config) {
            config = _extends({}, Default, $__default["default"](this._element).data(), typeof config === "object" && config ? config : {});
            Util.typeCheckConfig(NAME, config, this.constructor.DefaultType);
            return config;
          };
          _proto._setListeners = function _setListeners() {
            var _this2 = this;
            $__default["default"](this._element).on(EVENT_CLICK_DISMISS, SELECTOR_DATA_DISMISS, function() {
              return _this2.hide();
            });
          };
          _proto._close = function _close() {
            var _this3 = this;
            var complete = function complete2() {
              _this3._element.classList.add(CLASS_NAME_HIDE);
              $__default["default"](_this3._element).trigger(EVENT_HIDDEN);
            };
            this._element.classList.remove(CLASS_NAME_SHOW);
            if (this._config.animation) {
              var transitionDuration = Util.getTransitionDurationFromElement(this._element);
              $__default["default"](this._element).one(Util.TRANSITION_END, complete).emulateTransitionEnd(transitionDuration);
            } else {
              complete();
            }
          };
          _proto._clearTimeout = function _clearTimeout() {
            clearTimeout(this._timeout);
            this._timeout = null;
          };
          Toast2._jQueryInterface = function _jQueryInterface(config) {
            return this.each(function() {
              var $element = $__default["default"](this);
              var data = $element.data(DATA_KEY);
              var _config = typeof config === "object" && config;
              if (!data) {
                data = new Toast2(this, _config);
                $element.data(DATA_KEY, data);
              }
              if (typeof config === "string") {
                if (typeof data[config] === "undefined") {
                  throw new TypeError('No method named "' + config + '"');
                }
                data[config](this);
              }
            });
          };
          _createClass(Toast2, null, [{
            key: "VERSION",
            get: function get() {
              return VERSION;
            }
          }, {
            key: "DefaultType",
            get: function get() {
              return DefaultType;
            }
          }, {
            key: "Default",
            get: function get() {
              return Default;
            }
          }]);
          return Toast2;
        }();
        $__default["default"].fn[NAME] = Toast._jQueryInterface;
        $__default["default"].fn[NAME].Constructor = Toast;
        $__default["default"].fn[NAME].noConflict = function() {
          $__default["default"].fn[NAME] = JQUERY_NO_CONFLICT;
          return Toast._jQueryInterface;
        };
        exports2.Alert = Alert;
        exports2.Button = Button;
        exports2.Carousel = Carousel;
        exports2.Collapse = Collapse;
        exports2.Dropdown = Dropdown;
        exports2.Modal = Modal;
        exports2.Popover = Popover;
        exports2.Scrollspy = ScrollSpy;
        exports2.Tab = Tab;
        exports2.Toast = Toast;
        exports2.Tooltip = Tooltip;
        exports2.Util = Util;
        Object.defineProperty(exports2, "__esModule", { value: true });
      });
    }
  });

  // app/javascript/packs/application.js
  var import_jquery = __toESM(require_jquery());
  var import_jquery_ujs = __toESM(require_rails());
  var import_ujs = __toESM(require_rails_ujs());
  var import_popper = __toESM(require_popper());
  var import_bootstrap = __toESM(require_bootstrap());

  // node_modules/data-confirm-modal/vendor/assets/javascripts/data-confirm-modal.js
  (function($2) {
    var defaults = {
      title: "Are you sure?",
      commit: "Confirm",
      commitClass: "btn-danger",
      cancel: "Cancel",
      cancelClass: "btn-default",
      fade: true,
      verifyClass: "form-control",
      elements: ["a[data-confirm]", "button[data-confirm]", "input[type=submit][data-confirm]"],
      focus: "commit",
      zIndex: 1050,
      modalClass: false,
      show: true
    };
    var settings;
    window.dataConfirmModal = {
      setDefaults: function(newSettings) {
        settings = $2.extend(settings, newSettings);
      },
      restoreDefaults: function() {
        settings = $2.extend({}, defaults);
      },
      confirm: function(options) {
        var modal = buildModal(options);
        modal.spawn();
        modal.on("hidden.bs.modal", function() {
          modal.remove();
        });
        modal.find(".commit").on("click", function() {
          if (options.onConfirm && options.onConfirm.call)
            options.onConfirm.call();
          modal.modal("hide");
        });
        modal.find(".cancel").on("click", function() {
          if (options.onCancel && options.onCancel.call)
            options.onCancel.call();
          modal.modal("hide");
        });
      }
    };
    dataConfirmModal.restoreDefaults();
    if ($2.fn.modal == void 0) {
      throw new Error("The bootstrap modal plugin does not appear to be loaded.");
    }
    if ($2.fn.modal.Constructor == void 0) {
      throw new Error("The bootstrap modal plugin does not have a Constructor ?!?");
    }
    if ($2.fn.modal.Constructor.VERSION == void 0) {
      throw new Error("The bootstrap modal plugin does not have its version defined ?!?");
    }
    var versionString = $2.fn.modal.Constructor.VERSION;
    var match = versionString.match(/^(\d)\./);
    if (!match) {
      throw new Error("Cannot identify Bootstrap version. Version string: " + versionString);
    }
    var bootstrapVersion = parseInt(match[1]);
    if (bootstrapVersion != 3 && bootstrapVersion != 4) {
      throw new Error("Unsupported bootstrap version: " + bootstrapVersion + ". data-confirm-modal supports version 3 and 4.");
    }
    var buildElementModal = function(element) {
      var options = {
        title: element.data("title") || element.attr("title") || element.data("original-title"),
        text: element.data("confirm"),
        focus: element.data("focus"),
        method: element.data("method"),
        modalClass: element.data("modal-class"),
        commit: element.data("commit"),
        commitClass: element.data("commit-class"),
        cancel: element.data("cancel"),
        cancelClass: element.data("cancel-class"),
        remote: element.data("remote"),
        verify: element.data("verify"),
        verifyRegexp: element.data("verify-regexp"),
        verifyLabel: element.data("verify-text"),
        verifyRegexpCaseInsensitive: element.data("verify-regexp-caseinsensitive"),
        backdrop: element.data("backdrop"),
        keyboard: element.data("keyboard"),
        show: element.data("show")
      };
      var modal = buildModal(options);
      modal.find(".commit").on("click", function() {
        element.get(0).click();
        modal.modal("hide");
      });
      return modal;
    };
    var buildModal = function(options) {
      var id = "confirm-modal-" + String(Math.random()).slice(2, -1);
      var fade = settings.fade ? "fade" : "";
      var modalClass = options.modalClass ? options.modalClass : settings.modalClass;
      var modalTitle = '<h5 id="' + id + 'Label" class="modal-title"></h5> ';
      var modalClose = '<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>';
      var modalHeader;
      switch (bootstrapVersion) {
        case 3:
          modalHeader = modalClose + modalTitle;
          break;
        case 4:
          modalHeader = modalTitle + modalClose;
          break;
      }
      var modal = $2('<div id="' + id + '" class="modal ' + modalClass + " " + fade + '" tabindex="-1" role="dialog" aria-labelledby="' + id + 'Label" aria-hidden="true"><div class="modal-dialog" role="document"><div class="modal-content"><div class="modal-header">' + modalHeader + '</div><div class="modal-body"></div><div class="modal-footer"><button class="btn cancel" data-dismiss="modal" aria-hidden="true"></button><button class="btn commit"></button></div></div></div></div>');
      var highest = current = settings.zIndex;
      $2(".modal.in").not("#" + id).each(function() {
        current = parseInt($2(this).css("z-index"), 10);
        if (current > highest) {
          highest = current;
        }
      });
      modal.css("z-index", parseInt(highest) + 1);
      modal.find(".modal-title").text(options.title || settings.title);
      var body = modal.find(".modal-body");
      $2.each((options.text || "").split(/\n{2}/), function(i, piece) {
        body.append($2("<p/>").html(piece));
      });
      var commit = modal.find(".commit");
      commit.text(options.commit || settings.commit);
      commit.addClass(options.commitClass || settings.commitClass);
      var cancel = modal.find(".cancel");
      cancel.text(options.cancel || settings.cancel);
      cancel.addClass(options.cancelClass || settings.cancelClass);
      if (options.remote) {
        commit.attr("data-dismiss", "modal");
      }
      if (options.verify || options.verifyRegexp) {
        commit.prop("disabled", true);
        var isMatch;
        if (options.verifyRegexp) {
          var caseInsensitive = options.verifyRegexpCaseInsensitive;
          var regexp = options.verifyRegexp;
          var re = new RegExp(regexp, caseInsensitive ? "i" : "");
          isMatch = function(input) {
            return input.match(re);
          };
        } else {
          isMatch = function(input) {
            return options.verify == input;
          };
        }
        var verification = $2("<input/>", { "type": "text", "class": settings.verifyClass }).on("keyup", function() {
          commit.prop("disabled", !isMatch($2(this).val()));
        });
        modal.on("shown.bs.modal", function() {
          verification.focus();
        });
        modal.on("hidden.bs.modal", function() {
          verification.val("").trigger("keyup");
        });
        if (options.verifyLabel)
          body.append($2("<p>", { text: options.verifyLabel }));
        body.append(verification);
      }
      var focus_element;
      if (options.focus) {
        focus_element = options.focus;
      } else if (options.method == "delete") {
        focus_element = "cancel";
      } else {
        focus_element = settings.focus;
      }
      focus_element = modal.find("." + focus_element);
      modal.on("shown.bs.modal", function() {
        focus_element.focus();
      });
      $2("body").append(modal);
      modal.spawn = function() {
        return modal.modal($2.extend({}, {
          backdrop: options.backdrop,
          keyboard: options.keyboard,
          show: options.show
        }));
      };
      return modal;
    };
    var getModal = function(element) {
      var modal = element.data("confirm-modal");
      if (!modal) {
        modal = buildElementModal(element);
        element.data("confirm-modal", modal);
      }
      return modal;
    };
    $2.fn.confirmModal = function() {
      var modal = getModal($2(this));
      modal.spawn();
      return modal;
    };
    if (window.Rails || $2.rails) {
      var window_confirm = window.confirm;
      $2(document).delegate(settings.elements.join(", "), "confirm", function() {
        var element = $2(this), modal = getModal(element);
        if (!modal.is(":visible")) {
          modal.spawn();
          return false;
        } else {
          window.confirm = function() {
            return true;
          };
          modal.one("hidden.bs.modal", function() {
            window.confirm = window_confirm;
          });
          return true;
        }
      });
    }
  })(jQuery);

  // app/javascript/packs/config.js
  "use strict;";
  var CONFIG_ID = "ood_config";
  function configData() {
    return $(`#${CONFIG_ID}`).data();
  }
  function setNavbarColor() {
    const cfgData = configData();
    const styles = document.styleSheets[0];
    const bgLightColor = cfgData["bgColor"] === "" ? "rgb(248, 248, 248)" : cfgData["bgColor"];
    const bgDarkColor = cfgData["bgColor"] === "" ? "rgb(83, 86, 90)" : cfgData["bgColor"];
    const linkLightColor = cfgData["linkBgColor"] === "" ? "rgb(231, 231, 231)" : cfgData["linkBgColor"];
    const linkDarkColor = cfgData["linkBgColor"] === "" ? "rgb(59, 61, 63)" : cfgData["linkBgColor"];
    styles.insertRule(navbar("light", bgLightColor), styles.rules.length);
    styles.insertRule(navbar("dark", bgDarkColor), styles.rules.length);
    styles.insertRule(navbarHighlight("light", linkLightColor), styles.rules.length);
    styles.insertRule(navbarHighlight("dark", linkDarkColor), styles.rules.length);
  }
  function navbar(theme, color) {
    return `
    .navbar-${theme} {
      background-color: ${color};
    }`;
  }
  function navbarHighlight(theme, color) {
    return `
    .navbar-${theme} ul.navbar-nav > li.nav-item > a:focus, .navbar-${theme} ul.navbar-nav > li.nav-item.show > a {
      background-color: ${color};
      border-radius: 0.25em;
    }`;
  }

  // app/javascript/packs/application.js
  window.jQuery = import_jquery.default;
  window.$ = $;
  import_ujs.default.start();
  (0, import_jquery.default)(function() {
    $("li.vdi").popover({
      trigger: "hover",
      content: "A VDI (Virtual Desktop Interface) gives you desktop access to a shared node. This is the graphical version of a login node. Use this for lightweight tasks like accessing & viewing files, submitting jobs, and for visualizations.",
      title: function() {
        return $(this).text();
      }
    });
    $("li.ihpc").popover({
      trigger: "hover",
      content: "An Interactive HPC session gives you dedicated access to one or more nodes on the cluster. This is similar to an interactive batch session with an accessible desktop on the primary node. Use this for heavyweight jobs such as long-running compute tasks or where you need dedicated resources.",
      title: function() {
        return $(this).text();
      }
    });
    $('[data-toggle="popover"]').popover();
    $('[data-toggle="tooltip"]').tooltip();
    setNavbarColor();
  });
})();
/*!
  * Bootstrap v4.6.1 (https://getbootstrap.com/)
  * Copyright 2011-2021 The Bootstrap Authors (https://github.com/twbs/bootstrap/graphs/contributors)
  * Licensed under MIT (https://github.com/twbs/bootstrap/blob/main/LICENSE)
  */
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
/**!
 * @fileOverview Kickass library to create and place poppers near their reference elements.
 * @version 1.14.3
 * @license
 * Copyright (c) 2016 Federico Zivolo and contributors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
//# sourceMappingURL=application.js.map
