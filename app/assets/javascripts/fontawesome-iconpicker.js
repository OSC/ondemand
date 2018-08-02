/*!
 * Font Awesome Icon Picker
 * https://farbelous.github.io/fontawesome-iconpicker/
 *
 * Originally written by (c) 2016 Javi Aguilar
 * Licensed under the MIT License
 * https://github.com/farbelous/fontawesome-iconpicker/blob/master/LICENSE
 *
 */
(function(a) {
    if (typeof define === "function" && define.amd) {
        define([ "jquery" ], a);
    } else {
        a(jQuery);
    }
})(function(a) {
    a.ui = a.ui || {};
    var b = a.ui.version = "1.12.1";
    /*!
     * jQuery UI Position 1.12.1
     * http://jqueryui.com
     *
     * Copyright jQuery Foundation and other contributors
     * Released under the MIT license.
     * http://jquery.org/license
     *
     * http://api.jqueryui.com/position/
     */
    (function() {
        var b, c = Math.max, d = Math.abs, e = /left|center|right/, f = /top|center|bottom/, g = /[\+\-]\d+(\.[\d]+)?%?/, h = /^\w+/, i = /%$/, j = a.fn.pos;
        function k(a, b, c) {
            return [ parseFloat(a[0]) * (i.test(a[0]) ? b / 100 : 1), parseFloat(a[1]) * (i.test(a[1]) ? c / 100 : 1) ];
        }
        function l(b, c) {
            return parseInt(a.css(b, c), 10) || 0;
        }
        function m(b) {
            var c = b[0];
            if (c.nodeType === 9) {
                return {
                    width: b.width(),
                    height: b.height(),
                    offset: {
                        top: 0,
                        left: 0
                    }
                };
            }
            if (a.isWindow(c)) {
                return {
                    width: b.width(),
                    height: b.height(),
                    offset: {
                        top: b.scrollTop(),
                        left: b.scrollLeft()
                    }
                };
            }
            if (c.preventDefault) {
                return {
                    width: 0,
                    height: 0,
                    offset: {
                        top: c.pageY,
                        left: c.pageX
                    }
                };
            }
            return {
                width: b.outerWidth(),
                height: b.outerHeight(),
                offset: b.offset()
            };
        }
        a.pos = {
            scrollbarWidth: function() {
                if (b !== undefined) {
                    return b;
                }
                var c, d, e = a("<div " + "style='display:block;position:absolute;width:50px;height:50px;overflow:hidden;'>" + "<div style='height:100px;width:auto;'></div></div>"), f = e.children()[0];
                a("body").append(e);
                c = f.offsetWidth;
                e.css("overflow", "scroll");
                d = f.offsetWidth;
                if (c === d) {
                    d = e[0].clientWidth;
                }
                e.remove();
                return b = c - d;
            },
            getScrollInfo: function(b) {
                var c = b.isWindow || b.isDocument ? "" : b.element.css("overflow-x"), d = b.isWindow || b.isDocument ? "" : b.element.css("overflow-y"), e = c === "scroll" || c === "auto" && b.width < b.element[0].scrollWidth, f = d === "scroll" || d === "auto" && b.height < b.element[0].scrollHeight;
                return {
                    width: f ? a.pos.scrollbarWidth() : 0,
                    height: e ? a.pos.scrollbarWidth() : 0
                };
            },
            getWithinInfo: function(b) {
                var c = a(b || window), d = a.isWindow(c[0]), e = !!c[0] && c[0].nodeType === 9, f = !d && !e;
                return {
                    element: c,
                    isWindow: d,
                    isDocument: e,
                    offset: f ? a(b).offset() : {
                        left: 0,
                        top: 0
                    },
                    scrollLeft: c.scrollLeft(),
                    scrollTop: c.scrollTop(),
                    width: c.outerWidth(),
                    height: c.outerHeight()
                };
            }
        };
        a.fn.pos = function(b) {
            if (!b || !b.of) {
                return j.apply(this, arguments);
            }
            b = a.extend({}, b);
            var i, n, o, p, q, r, s = a(b.of), t = a.pos.getWithinInfo(b.within), u = a.pos.getScrollInfo(t), v = (b.collision || "flip").split(" "), w = {};
            r = m(s);
            if (s[0].preventDefault) {
                b.at = "left top";
            }
            n = r.width;
            o = r.height;
            p = r.offset;
            q = a.extend({}, p);
            a.each([ "my", "at" ], function() {
                var a = (b[this] || "").split(" "), c, d;
                if (a.length === 1) {
                    a = e.test(a[0]) ? a.concat([ "center" ]) : f.test(a[0]) ? [ "center" ].concat(a) : [ "center", "center" ];
                }
                a[0] = e.test(a[0]) ? a[0] : "center";
                a[1] = f.test(a[1]) ? a[1] : "center";
                c = g.exec(a[0]);
                d = g.exec(a[1]);
                w[this] = [ c ? c[0] : 0, d ? d[0] : 0 ];
                b[this] = [ h.exec(a[0])[0], h.exec(a[1])[0] ];
            });
            if (v.length === 1) {
                v[1] = v[0];
            }
            if (b.at[0] === "right") {
                q.left += n;
            } else if (b.at[0] === "center") {
                q.left += n / 2;
            }
            if (b.at[1] === "bottom") {
                q.top += o;
            } else if (b.at[1] === "center") {
                q.top += o / 2;
            }
            i = k(w.at, n, o);
            q.left += i[0];
            q.top += i[1];
            return this.each(function() {
                var e, f, g = a(this), h = g.outerWidth(), j = g.outerHeight(), m = l(this, "marginLeft"), r = l(this, "marginTop"), x = h + m + l(this, "marginRight") + u.width, y = j + r + l(this, "marginBottom") + u.height, z = a.extend({}, q), A = k(w.my, g.outerWidth(), g.outerHeight());
                if (b.my[0] === "right") {
                    z.left -= h;
                } else if (b.my[0] === "center") {
                    z.left -= h / 2;
                }
                if (b.my[1] === "bottom") {
                    z.top -= j;
                } else if (b.my[1] === "center") {
                    z.top -= j / 2;
                }
                z.left += A[0];
                z.top += A[1];
                e = {
                    marginLeft: m,
                    marginTop: r
                };
                a.each([ "left", "top" ], function(c, d) {
                    if (a.ui.pos[v[c]]) {
                        a.ui.pos[v[c]][d](z, {
                            targetWidth: n,
                            targetHeight: o,
                            elemWidth: h,
                            elemHeight: j,
                            collisionPosition: e,
                            collisionWidth: x,
                            collisionHeight: y,
                            offset: [ i[0] + A[0], i[1] + A[1] ],
                            my: b.my,
                            at: b.at,
                            within: t,
                            elem: g
                        });
                    }
                });
                if (b.using) {
                    f = function(a) {
                        var e = p.left - z.left, f = e + n - h, i = p.top - z.top, k = i + o - j, l = {
                            target: {
                                element: s,
                                left: p.left,
                                top: p.top,
                                width: n,
                                height: o
                            },
                            element: {
                                element: g,
                                left: z.left,
                                top: z.top,
                                width: h,
                                height: j
                            },
                            horizontal: f < 0 ? "left" : e > 0 ? "right" : "center",
                            vertical: k < 0 ? "top" : i > 0 ? "bottom" : "middle"
                        };
                        if (n < h && d(e + f) < n) {
                            l.horizontal = "center";
                        }
                        if (o < j && d(i + k) < o) {
                            l.vertical = "middle";
                        }
                        if (c(d(e), d(f)) > c(d(i), d(k))) {
                            l.important = "horizontal";
                        } else {
                            l.important = "vertical";
                        }
                        b.using.call(this, a, l);
                    };
                }
                g.offset(a.extend(z, {
                    using: f
                }));
            });
        };
        a.ui.pos = {
            _trigger: function(a, b, c, d) {
                if (b.elem) {
                    b.elem.trigger({
                        type: c,
                        position: a,
                        positionData: b,
                        triggered: d
                    });
                }
            },
            fit: {
                left: function(b, d) {
                    a.ui.pos._trigger(b, d, "posCollide", "fitLeft");
                    var e = d.within, f = e.isWindow ? e.scrollLeft : e.offset.left, g = e.width, h = b.left - d.collisionPosition.marginLeft, i = f - h, j = h + d.collisionWidth - g - f, k;
                    if (d.collisionWidth > g) {
                        if (i > 0 && j <= 0) {
                            k = b.left + i + d.collisionWidth - g - f;
                            b.left += i - k;
                        } else if (j > 0 && i <= 0) {
                            b.left = f;
                        } else {
                            if (i > j) {
                                b.left = f + g - d.collisionWidth;
                            } else {
                                b.left = f;
                            }
                        }
                    } else if (i > 0) {
                        b.left += i;
                    } else if (j > 0) {
                        b.left -= j;
                    } else {
                        b.left = c(b.left - h, b.left);
                    }
                    a.ui.pos._trigger(b, d, "posCollided", "fitLeft");
                },
                top: function(b, d) {
                    a.ui.pos._trigger(b, d, "posCollide", "fitTop");
                    var e = d.within, f = e.isWindow ? e.scrollTop : e.offset.top, g = d.within.height, h = b.top - d.collisionPosition.marginTop, i = f - h, j = h + d.collisionHeight - g - f, k;
                    if (d.collisionHeight > g) {
                        if (i > 0 && j <= 0) {
                            k = b.top + i + d.collisionHeight - g - f;
                            b.top += i - k;
                        } else if (j > 0 && i <= 0) {
                            b.top = f;
                        } else {
                            if (i > j) {
                                b.top = f + g - d.collisionHeight;
                            } else {
                                b.top = f;
                            }
                        }
                    } else if (i > 0) {
                        b.top += i;
                    } else if (j > 0) {
                        b.top -= j;
                    } else {
                        b.top = c(b.top - h, b.top);
                    }
                    a.ui.pos._trigger(b, d, "posCollided", "fitTop");
                }
            },
            flip: {
                left: function(b, c) {
                    a.ui.pos._trigger(b, c, "posCollide", "flipLeft");
                    var e = c.within, f = e.offset.left + e.scrollLeft, g = e.width, h = e.isWindow ? e.scrollLeft : e.offset.left, i = b.left - c.collisionPosition.marginLeft, j = i - h, k = i + c.collisionWidth - g - h, l = c.my[0] === "left" ? -c.elemWidth : c.my[0] === "right" ? c.elemWidth : 0, m = c.at[0] === "left" ? c.targetWidth : c.at[0] === "right" ? -c.targetWidth : 0, n = -2 * c.offset[0], o, p;
                    if (j < 0) {
                        o = b.left + l + m + n + c.collisionWidth - g - f;
                        if (o < 0 || o < d(j)) {
                            b.left += l + m + n;
                        }
                    } else if (k > 0) {
                        p = b.left - c.collisionPosition.marginLeft + l + m + n - h;
                        if (p > 0 || d(p) < k) {
                            b.left += l + m + n;
                        }
                    }
                    a.ui.pos._trigger(b, c, "posCollided", "flipLeft");
                },
                top: function(b, c) {
                    a.ui.pos._trigger(b, c, "posCollide", "flipTop");
                    var e = c.within, f = e.offset.top + e.scrollTop, g = e.height, h = e.isWindow ? e.scrollTop : e.offset.top, i = b.top - c.collisionPosition.marginTop, j = i - h, k = i + c.collisionHeight - g - h, l = c.my[1] === "top", m = l ? -c.elemHeight : c.my[1] === "bottom" ? c.elemHeight : 0, n = c.at[1] === "top" ? c.targetHeight : c.at[1] === "bottom" ? -c.targetHeight : 0, o = -2 * c.offset[1], p, q;
                    if (j < 0) {
                        q = b.top + m + n + o + c.collisionHeight - g - f;
                        if (q < 0 || q < d(j)) {
                            b.top += m + n + o;
                        }
                    } else if (k > 0) {
                        p = b.top - c.collisionPosition.marginTop + m + n + o - h;
                        if (p > 0 || d(p) < k) {
                            b.top += m + n + o;
                        }
                    }
                    a.ui.pos._trigger(b, c, "posCollided", "flipTop");
                }
            },
            flipfit: {
                left: function() {
                    a.ui.pos.flip.left.apply(this, arguments);
                    a.ui.pos.fit.left.apply(this, arguments);
                },
                top: function() {
                    a.ui.pos.flip.top.apply(this, arguments);
                    a.ui.pos.fit.top.apply(this, arguments);
                }
            }
        };
        (function() {
            var b, c, d, e, f, g = document.getElementsByTagName("body")[0], h = document.createElement("div");
            b = document.createElement(g ? "div" : "body");
            d = {
                visibility: "hidden",
                width: 0,
                height: 0,
                border: 0,
                margin: 0,
                background: "none"
            };
            if (g) {
                a.extend(d, {
                    position: "absolute",
                    left: "-1000px",
                    top: "-1000px"
                });
            }
            for (f in d) {
                b.style[f] = d[f];
            }
            b.appendChild(h);
            c = g || document.documentElement;
            c.insertBefore(b, c.firstChild);
            h.style.cssText = "position: absolute; left: 10.7432222px;";
            e = a(h).offset().left;
            a.support.offsetFractions = e > 10 && e < 11;
            b.innerHTML = "";
            c.removeChild(b);
        })();
    })();
    var c = a.ui.position;
});

function parseIconURI(a) {
    var b = /^(fa[bsrl]?):\/\/(.*)/;
    var c = b.exec(a);
    if (c) {
        return [ c[1], c[2] ];
    }
    return null;
}

var FA5iconinfolong = {
    icons: [ {
        title: "fab://500px",
        searchTerms: []
    }, {
        title: "fab://accessible-icon",
        searchTerms: [ "accessibility", "wheelchair", "handicap", "person", "wheelchair-alt" ]
    }, {
        title: "fab://accusoft",
        searchTerms: []
    }, {
        title: "fas://address-book",
        searchTerms: []
    }, {
        title: "far://address-book",
        searchTerms: []
    }, {
        title: "fas://address-card",
        searchTerms: []
    }, {
        title: "far://address-card",
        searchTerms: []
    }, {
        title: "fas://adjust",
        searchTerms: [ "contrast" ]
    }, {
        title: "fab://adn",
        searchTerms: []
    }, {
        title: "fab://adversal",
        searchTerms: []
    }, {
        title: "fab://affiliatetheme",
        searchTerms: []
    }, {
        title: "fab://algolia",
        searchTerms: []
    }, {
        title: "fas://align-center",
        searchTerms: [ "middle", "text" ]
    }, {
        title: "fas://align-justify",
        searchTerms: [ "text" ]
    }, {
        title: "fas://align-left",
        searchTerms: [ "text" ]
    }, {
        title: "fas://align-right",
        searchTerms: [ "text" ]
    }, {
        title: "fas://allergies",
        searchTerms: [ "intolerances", "pox", "hand", "freckles", "spots" ]
    }, {
        title: "fab://amazon",
        searchTerms: []
    }, {
        title: "fab://amazon-pay",
        searchTerms: []
    }, {
        title: "fas://ambulance",
        searchTerms: [ "vehicle", "support", "help", "machine" ]
    }, {
        title: "fas://american-sign-language-interpreting",
        searchTerms: []
    }, {
        title: "fab://amilia",
        searchTerms: []
    }, {
        title: "fas://anchor",
        searchTerms: [ "link" ]
    }, {
        title: "fab://android",
        searchTerms: [ "robot" ]
    }, {
        title: "fab://angellist",
        searchTerms: []
    }, {
        title: "fas://angle-double-down",
        searchTerms: [ "arrows" ]
    }, {
        title: "fas://angle-double-left",
        searchTerms: [ "laquo", "quote", "previous", "back", "arrows" ]
    }, {
        title: "fas://angle-double-right",
        searchTerms: [ "raquo", "quote", "next", "forward", "arrows" ]
    }, {
        title: "fas://angle-double-up",
        searchTerms: [ "arrows" ]
    }, {
        title: "fas://angle-down",
        searchTerms: [ "arrow" ]
    }, {
        title: "fas://angle-left",
        searchTerms: [ "previous", "back", "arrow" ]
    }, {
        title: "fas://angle-right",
        searchTerms: [ "next", "forward", "arrow" ]
    }, {
        title: "fas://angle-up",
        searchTerms: [ "arrow" ]
    }, {
        title: "fab://angrycreative",
        searchTerms: []
    }, {
        title: "fab://angular",
        searchTerms: []
    }, {
        title: "fab://app-store",
        searchTerms: []
    }, {
        title: "fab://app-store-ios",
        searchTerms: []
    }, {
        title: "fab://apper",
        searchTerms: []
    }, {
        title: "fab://apple",
        searchTerms: [ "osx", "food" ]
    }, {
        title: "fab://apple-pay",
        searchTerms: []
    }, {
        title: "fas://archive",
        searchTerms: [ "box", "storage", "package" ]
    }, {
        title: "fas://arrow-alt-circle-down",
        searchTerms: [ "download", "arrow-circle-o-down" ]
    }, {
        title: "far://arrow-alt-circle-down",
        searchTerms: [ "download", "arrow-circle-o-down" ]
    }, {
        title: "fas://arrow-alt-circle-left",
        searchTerms: [ "previous", "back", "arrow-circle-o-left" ]
    }, {
        title: "far://arrow-alt-circle-left",
        searchTerms: [ "previous", "back", "arrow-circle-o-left" ]
    }, {
        title: "fas://arrow-alt-circle-right",
        searchTerms: [ "next", "forward", "arrow-circle-o-right" ]
    }, {
        title: "far://arrow-alt-circle-right",
        searchTerms: [ "next", "forward", "arrow-circle-o-right" ]
    }, {
        title: "fas://arrow-alt-circle-up",
        searchTerms: [ "arrow-circle-o-up" ]
    }, {
        title: "far://arrow-alt-circle-up",
        searchTerms: [ "arrow-circle-o-up" ]
    }, {
        title: "fas://arrow-circle-down",
        searchTerms: [ "download" ]
    }, {
        title: "fas://arrow-circle-left",
        searchTerms: [ "previous", "back" ]
    }, {
        title: "fas://arrow-circle-right",
        searchTerms: [ "next", "forward" ]
    }, {
        title: "fas://arrow-circle-up",
        searchTerms: []
    }, {
        title: "fas://arrow-down",
        searchTerms: [ "download" ]
    }, {
        title: "fas://arrow-left",
        searchTerms: [ "previous", "back" ]
    }, {
        title: "fas://arrow-right",
        searchTerms: [ "next", "forward" ]
    }, {
        title: "fas://arrow-up",
        searchTerms: []
    }, {
        title: "fas://arrows-alt",
        searchTerms: [ "expand", "enlarge", "fullscreen", "bigger", "move", "reorder", "resize", "arrow", "arrows" ]
    }, {
        title: "fas://arrows-alt-h",
        searchTerms: [ "resize", "arrows-h" ]
    }, {
        title: "fas://arrows-alt-v",
        searchTerms: [ "resize", "arrows-v" ]
    }, {
        title: "fas://assistive-listening-systems",
        searchTerms: []
    }, {
        title: "fas://asterisk",
        searchTerms: [ "details" ]
    }, {
        title: "fab://asymmetrik",
        searchTerms: []
    }, {
        title: "fas://at",
        searchTerms: [ "email", "e-mail" ]
    }, {
        title: "fab://audible",
        searchTerms: []
    }, {
        title: "fas://audio-description",
        searchTerms: []
    }, {
        title: "fab://autoprefixer",
        searchTerms: []
    }, {
        title: "fab://avianex",
        searchTerms: []
    }, {
        title: "fab://aviato",
        searchTerms: []
    }, {
        title: "fab://aws",
        searchTerms: []
    }, {
        title: "fas://backward",
        searchTerms: [ "rewind", "previous" ]
    }, {
        title: "fas://balance-scale",
        searchTerms: []
    }, {
        title: "fas://ban",
        searchTerms: [ "delete", "remove", "trash", "hide", "block", "stop", "abort", "cancel", "ban", "prohibit" ]
    }, {
        title: "fas://band-aid",
        searchTerms: [ "bandage", "ouch", "boo boo" ]
    }, {
        title: "fab://bandcamp",
        searchTerms: []
    }, {
        title: "fas://barcode",
        searchTerms: [ "scan" ]
    }, {
        title: "fas://bars",
        searchTerms: [ "menu", "drag", "reorder", "settings", "list", "ul", "ol", "checklist", "todo", "hamburger", "navigation", "nav" ]
    }, {
        title: "fas://baseball-ball",
        searchTerms: []
    }, {
        title: "fas://basketball-ball",
        searchTerms: []
    }, {
        title: "fas://bath",
        searchTerms: []
    }, {
        title: "fas://battery-empty",
        searchTerms: [ "power", "status" ]
    }, {
        title: "fas://battery-full",
        searchTerms: [ "power", "status" ]
    }, {
        title: "fas://battery-half",
        searchTerms: [ "power", "status" ]
    }, {
        title: "fas://battery-quarter",
        searchTerms: [ "power", "status" ]
    }, {
        title: "fas://battery-three-quarters",
        searchTerms: [ "power", "status" ]
    }, {
        title: "fas://bed",
        searchTerms: [ "travel" ]
    }, {
        title: "fas://beer",
        searchTerms: [ "alcohol", "stein", "drink", "mug", "bar", "liquor" ]
    }, {
        title: "fab://behance",
        searchTerms: []
    }, {
        title: "fab://behance-square",
        searchTerms: []
    }, {
        title: "fas://bell",
        searchTerms: [ "alert", "reminder", "notification" ]
    }, {
        title: "far://bell",
        searchTerms: [ "alert", "reminder", "notification" ]
    }, {
        title: "fas://bell-slash",
        searchTerms: []
    }, {
        title: "far://bell-slash",
        searchTerms: []
    }, {
        title: "fas://bicycle",
        searchTerms: [ "vehicle", "transportation", "bike", "gears" ]
    }, {
        title: "fab://bimobject",
        searchTerms: []
    }, {
        title: "fas://binoculars",
        searchTerms: []
    }, {
        title: "fas://birthday-cake",
        searchTerms: []
    }, {
        title: "fab://bitbucket",
        searchTerms: [ "git", "bitbucket-square" ]
    }, {
        title: "fab://bitcoin",
        searchTerms: []
    }, {
        title: "fab://bity",
        searchTerms: []
    }, {
        title: "fab://black-tie",
        searchTerms: []
    }, {
        title: "fab://blackberry",
        searchTerms: []
    }, {
        title: "fas://blind",
        searchTerms: []
    }, {
        title: "fab://blogger",
        searchTerms: []
    }, {
        title: "fab://blogger-b",
        searchTerms: []
    }, {
        title: "fab://bluetooth",
        searchTerms: []
    }, {
        title: "fab://bluetooth-b",
        searchTerms: []
    }, {
        title: "fas://bold",
        searchTerms: []
    }, {
        title: "fas://bolt",
        searchTerms: [ "lightning", "weather" ]
    }, {
        title: "fas://bomb",
        searchTerms: []
    }, {
        title: "fas://book",
        searchTerms: [ "read", "documentation" ]
    }, {
        title: "fas://bookmark",
        searchTerms: [ "save" ]
    }, {
        title: "far://bookmark",
        searchTerms: [ "save" ]
    }, {
        title: "fas://bowling-ball",
        searchTerms: []
    }, {
        title: "fas://box",
        searchTerms: [ "package" ]
    }, {
        title: "fas://box-open",
        searchTerms: []
    }, {
        title: "fas://boxes",
        searchTerms: []
    }, {
        title: "fas://braille",
        searchTerms: []
    }, {
        title: "fas://briefcase",
        searchTerms: [ "work", "business", "office", "luggage", "bag" ]
    }, {
        title: "fas://briefcase-medical",
        searchTerms: [ "health briefcase" ]
    }, {
        title: "fab://btc",
        searchTerms: []
    }, {
        title: "fas://bug",
        searchTerms: [ "report", "insect" ]
    }, {
        title: "fas://building",
        searchTerms: [ "work", "business", "apartment", "office", "company" ]
    }, {
        title: "far://building",
        searchTerms: [ "work", "business", "apartment", "office", "company" ]
    }, {
        title: "fas://bullhorn",
        searchTerms: [ "announcement", "share", "broadcast", "louder", "megaphone" ]
    }, {
        title: "fas://bullseye",
        searchTerms: [ "target" ]
    }, {
        title: "fas://burn",
        searchTerms: [ "energy" ]
    }, {
        title: "fab://buromobelexperte",
        searchTerms: []
    }, {
        title: "fas://bus",
        searchTerms: [ "vehicle", "machine", "public transportation", "transportation" ]
    }, {
        title: "fab://buysellads",
        searchTerms: []
    }, {
        title: "fas://calculator",
        searchTerms: []
    }, {
        title: "fas://calendar",
        searchTerms: [ "date", "time", "when", "event", "calendar-o", "schedule" ]
    }, {
        title: "far://calendar",
        searchTerms: [ "date", "time", "when", "event", "calendar-o", "schedule" ]
    }, {
        title: "fas://calendar-alt",
        searchTerms: [ "date", "time", "when", "event", "calendar", "schedule" ]
    }, {
        title: "far://calendar-alt",
        searchTerms: [ "date", "time", "when", "event", "calendar", "schedule" ]
    }, {
        title: "fas://calendar-check",
        searchTerms: [ "todo", "done", "agree", "accept", "confirm", "ok", "select", "success", "appointment", "correct" ]
    }, {
        title: "far://calendar-check",
        searchTerms: [ "todo", "done", "agree", "accept", "confirm", "ok", "select", "success", "appointment", "correct" ]
    }, {
        title: "fas://calendar-minus",
        searchTerms: []
    }, {
        title: "far://calendar-minus",
        searchTerms: []
    }, {
        title: "fas://calendar-plus",
        searchTerms: []
    }, {
        title: "far://calendar-plus",
        searchTerms: []
    }, {
        title: "fas://calendar-times",
        searchTerms: []
    }, {
        title: "far://calendar-times",
        searchTerms: []
    }, {
        title: "fas://camera",
        searchTerms: [ "photo", "picture", "record" ]
    }, {
        title: "fas://camera-retro",
        searchTerms: [ "photo", "picture", "record" ]
    }, {
        title: "fas://capsules",
        searchTerms: [ "medicine", "drugs" ]
    }, {
        title: "fas://car",
        searchTerms: [ "vehicle", "machine", "transportation" ]
    }, {
        title: "fas://caret-down",
        searchTerms: [ "more", "dropdown", "menu", "triangle down", "arrow" ]
    }, {
        title: "fas://caret-left",
        searchTerms: [ "previous", "back", "triangle left", "arrow" ]
    }, {
        title: "fas://caret-right",
        searchTerms: [ "next", "forward", "triangle right", "arrow" ]
    }, {
        title: "fas://caret-square-down",
        searchTerms: [ "more", "dropdown", "menu", "caret-square-o-down" ]
    }, {
        title: "far://caret-square-down",
        searchTerms: [ "more", "dropdown", "menu", "caret-square-o-down" ]
    }, {
        title: "fas://caret-square-left",
        searchTerms: [ "previous", "back", "caret-square-o-left" ]
    }, {
        title: "far://caret-square-left",
        searchTerms: [ "previous", "back", "caret-square-o-left" ]
    }, {
        title: "fas://caret-square-right",
        searchTerms: [ "next", "forward", "caret-square-o-right" ]
    }, {
        title: "far://caret-square-right",
        searchTerms: [ "next", "forward", "caret-square-o-right" ]
    }, {
        title: "fas://caret-square-up",
        searchTerms: [ "caret-square-o-up" ]
    }, {
        title: "far://caret-square-up",
        searchTerms: [ "caret-square-o-up" ]
    }, {
        title: "fas://caret-up",
        searchTerms: [ "triangle up", "arrow" ]
    }, {
        title: "fas://cart-arrow-down",
        searchTerms: [ "shopping" ]
    }, {
        title: "fas://cart-plus",
        searchTerms: [ "add", "shopping" ]
    }, {
        title: "fab://cc-amazon-pay",
        searchTerms: []
    }, {
        title: "fab://cc-amex",
        searchTerms: [ "amex" ]
    }, {
        title: "fab://cc-apple-pay",
        searchTerms: []
    }, {
        title: "fab://cc-diners-club",
        searchTerms: []
    }, {
        title: "fab://cc-discover",
        searchTerms: []
    }, {
        title: "fab://cc-jcb",
        searchTerms: []
    }, {
        title: "fab://cc-mastercard",
        searchTerms: []
    }, {
        title: "fab://cc-paypal",
        searchTerms: []
    }, {
        title: "fab://cc-stripe",
        searchTerms: []
    }, {
        title: "fab://cc-visa",
        searchTerms: []
    }, {
        title: "fab://centercode",
        searchTerms: []
    }, {
        title: "fas://certificate",
        searchTerms: [ "badge", "star" ]
    }, {
        title: "fas://chart-area",
        searchTerms: [ "graph", "analytics", "area-chart" ]
    }, {
        title: "fas://chart-bar",
        searchTerms: [ "graph", "analytics", "bar-chart" ]
    }, {
        title: "far://chart-bar",
        searchTerms: [ "graph", "analytics", "bar-chart" ]
    }, {
        title: "fas://chart-line",
        searchTerms: [ "graph", "analytics", "line-chart", "dashboard" ]
    }, {
        title: "fas://chart-pie",
        searchTerms: [ "graph", "analytics", "pie-chart" ]
    }, {
        title: "fas://check",
        searchTerms: [ "checkmark", "done", "todo", "agree", "accept", "confirm", "tick", "ok", "select", "success", "notification", "notify", "notice", "yes", "correct" ]
    }, {
        title: "fas://check-circle",
        searchTerms: [ "todo", "done", "agree", "accept", "confirm", "ok", "select", "success", "yes", "correct" ]
    }, {
        title: "far://check-circle",
        searchTerms: [ "todo", "done", "agree", "accept", "confirm", "ok", "select", "success", "yes", "correct" ]
    }, {
        title: "fas://check-square",
        searchTerms: [ "checkmark", "done", "todo", "agree", "accept", "confirm", "ok", "select", "success", "yes", "correct" ]
    }, {
        title: "far://check-square",
        searchTerms: [ "checkmark", "done", "todo", "agree", "accept", "confirm", "ok", "select", "success", "yes", "correct" ]
    }, {
        title: "fas://chess",
        searchTerms: []
    }, {
        title: "fas://chess-bishop",
        searchTerms: []
    }, {
        title: "fas://chess-board",
        searchTerms: []
    }, {
        title: "fas://chess-king",
        searchTerms: []
    }, {
        title: "fas://chess-knight",
        searchTerms: []
    }, {
        title: "fas://chess-pawn",
        searchTerms: []
    }, {
        title: "fas://chess-queen",
        searchTerms: []
    }, {
        title: "fas://chess-rook",
        searchTerms: []
    }, {
        title: "fas://chevron-circle-down",
        searchTerms: [ "more", "dropdown", "menu", "arrow" ]
    }, {
        title: "fas://chevron-circle-left",
        searchTerms: [ "previous", "back", "arrow" ]
    }, {
        title: "fas://chevron-circle-right",
        searchTerms: [ "next", "forward", "arrow" ]
    }, {
        title: "fas://chevron-circle-up",
        searchTerms: [ "arrow" ]
    }, {
        title: "fas://chevron-down",
        searchTerms: []
    }, {
        title: "fas://chevron-left",
        searchTerms: [ "bracket", "previous", "back" ]
    }, {
        title: "fas://chevron-right",
        searchTerms: [ "bracket", "next", "forward" ]
    }, {
        title: "fas://chevron-up",
        searchTerms: []
    }, {
        title: "fas://child",
        searchTerms: []
    }, {
        title: "fab://chrome",
        searchTerms: [ "browser" ]
    }, {
        title: "fas://circle",
        searchTerms: [ "dot", "notification", "circle-thin" ]
    }, {
        title: "far://circle",
        searchTerms: [ "dot", "notification", "circle-thin" ]
    }, {
        title: "fas://circle-notch",
        searchTerms: [ "circle-o-notch" ]
    }, {
        title: "fas://clipboard",
        searchTerms: [ "paste" ]
    }, {
        title: "far://clipboard",
        searchTerms: [ "paste" ]
    }, {
        title: "fas://clipboard-check",
        searchTerms: [ "todo", "done", "agree", "accept", "confirm", "ok", "select", "success", "yes" ]
    }, {
        title: "fas://clipboard-list",
        searchTerms: [ "todo", "ul", "ol", "checklist", "finished", "completed", "done", "schedule", "intinerary" ]
    }, {
        title: "fas://clock",
        searchTerms: [ "watch", "timer", "late", "timestamp", "date", "schedule" ]
    }, {
        title: "far://clock",
        searchTerms: [ "watch", "timer", "late", "timestamp", "date", "schedule" ]
    }, {
        title: "fas://clone",
        searchTerms: [ "copy" ]
    }, {
        title: "far://clone",
        searchTerms: [ "copy" ]
    }, {
        title: "fas://closed-captioning",
        searchTerms: [ "cc" ]
    }, {
        title: "far://closed-captioning",
        searchTerms: [ "cc" ]
    }, {
        title: "fas://cloud",
        searchTerms: [ "save" ]
    }, {
        title: "fas://cloud-download-alt",
        searchTerms: [ "cloud-download" ]
    }, {
        title: "fas://cloud-upload-alt",
        searchTerms: [ "cloud-upload" ]
    }, {
        title: "fab://cloudscale",
        searchTerms: []
    }, {
        title: "fab://cloudsmith",
        searchTerms: []
    }, {
        title: "fab://cloudversify",
        searchTerms: []
    }, {
        title: "fas://code",
        searchTerms: [ "html", "brackets" ]
    }, {
        title: "fas://code-branch",
        searchTerms: [ "git", "fork", "vcs", "svn", "github", "rebase", "version", "branch", "code-fork" ]
    }, {
        title: "fab://codepen",
        searchTerms: []
    }, {
        title: "fab://codiepie",
        searchTerms: []
    }, {
        title: "fas://coffee",
        searchTerms: [ "morning", "mug", "breakfast", "tea", "drink", "cafe" ]
    }, {
        title: "fas://cog",
        searchTerms: [ "settings" ]
    }, {
        title: "fas://cogs",
        searchTerms: [ "settings", "gears" ]
    }, {
        title: "fas://columns",
        searchTerms: [ "split", "panes", "dashboard" ]
    }, {
        title: "fas://comment",
        searchTerms: [ "speech", "notification", "note", "chat", "bubble", "feedback", "message", "texting", "sms", "conversation" ]
    }, {
        title: "far://comment",
        searchTerms: [ "speech", "notification", "note", "chat", "bubble", "feedback", "message", "texting", "sms", "conversation" ]
    }, {
        title: "fas://comment-alt",
        searchTerms: [ "speech", "notification", "note", "chat", "bubble", "feedback", "message", "texting", "sms", "conversation", "commenting", "commenting" ]
    }, {
        title: "far://comment-alt",
        searchTerms: [ "speech", "notification", "note", "chat", "bubble", "feedback", "message", "texting", "sms", "conversation", "commenting", "commenting" ]
    }, {
        title: "fas://comment-dots",
        searchTerms: []
    }, {
        title: "fas://comment-slash",
        searchTerms: []
    }, {
        title: "fas://comments",
        searchTerms: [ "speech", "notification", "note", "chat", "bubble", "feedback", "message", "texting", "sms", "conversation" ]
    }, {
        title: "far://comments",
        searchTerms: [ "speech", "notification", "note", "chat", "bubble", "feedback", "message", "texting", "sms", "conversation" ]
    }, {
        title: "fas://compass",
        searchTerms: [ "safari", "directory", "menu", "location" ]
    }, {
        title: "far://compass",
        searchTerms: [ "safari", "directory", "menu", "location" ]
    }, {
        title: "fas://compress",
        searchTerms: [ "collapse", "combine", "contract", "merge", "smaller" ]
    }, {
        title: "fab://connectdevelop",
        searchTerms: []
    }, {
        title: "fab://contao",
        searchTerms: []
    }, {
        title: "fas://copy",
        searchTerms: [ "duplicate", "clone", "file", "files-o" ]
    }, {
        title: "far://copy",
        searchTerms: [ "duplicate", "clone", "file", "files-o" ]
    }, {
        title: "fas://copyright",
        searchTerms: []
    }, {
        title: "far://copyright",
        searchTerms: []
    }, {
        title: "fas://couch",
        searchTerms: []
    }, {
        title: "fab://cpanel",
        searchTerms: []
    }, {
        title: "fab://creative-commons",
        searchTerms: []
    }, {
        title: "fas://credit-card",
        searchTerms: [ "money", "buy", "debit", "checkout", "purchase", "payment", "credit-card-alt" ]
    }, {
        title: "far://credit-card",
        searchTerms: [ "money", "buy", "debit", "checkout", "purchase", "payment", "credit-card-alt" ]
    }, {
        title: "fas://crop",
        searchTerms: [ "design" ]
    }, {
        title: "fas://crosshairs",
        searchTerms: [ "picker", "gpd" ]
    }, {
        title: "fab://css3",
        searchTerms: [ "code" ]
    }, {
        title: "fab://css3-alt",
        searchTerms: []
    }, {
        title: "fas://cube",
        searchTerms: [ "package" ]
    }, {
        title: "fas://cubes",
        searchTerms: [ "packages" ]
    }, {
        title: "fas://cut",
        searchTerms: [ "scissors", "scissors" ]
    }, {
        title: "fab://cuttlefish",
        searchTerms: []
    }, {
        title: "fab://d-and-d",
        searchTerms: []
    }, {
        title: "fab://dashcube",
        searchTerms: []
    }, {
        title: "fas://database",
        searchTerms: []
    }, {
        title: "fas://deaf",
        searchTerms: []
    }, {
        title: "fab://delicious",
        searchTerms: []
    }, {
        title: "fab://deploydog",
        searchTerms: []
    }, {
        title: "fab://deskpro",
        searchTerms: []
    }, {
        title: "fas://desktop",
        searchTerms: [ "monitor", "screen", "desktop", "computer", "demo", "device", "pc", "machine" ]
    }, {
        title: "fab://deviantart",
        searchTerms: []
    }, {
        title: "fas://diagnoses",
        searchTerms: []
    }, {
        title: "fab://digg",
        searchTerms: []
    }, {
        title: "fab://digital-ocean",
        searchTerms: []
    }, {
        title: "fab://discord",
        searchTerms: []
    }, {
        title: "fab://discourse",
        searchTerms: []
    }, {
        title: "fas://dna",
        searchTerms: [ "double helix", "helix" ]
    }, {
        title: "fab://dochub",
        searchTerms: []
    }, {
        title: "fab://docker",
        searchTerms: []
    }, {
        title: "fas://dollar-sign",
        searchTerms: [ "usd", "price" ]
    }, {
        title: "fas://dolly",
        searchTerms: []
    }, {
        title: "fas://dolly-flatbed",
        searchTerms: []
    }, {
        title: "fas://donate",
        searchTerms: [ "give", "generosity" ]
    }, {
        title: "fas://dot-circle",
        searchTerms: [ "target", "bullseye", "notification" ]
    }, {
        title: "far://dot-circle",
        searchTerms: [ "target", "bullseye", "notification" ]
    }, {
        title: "fas://dove",
        searchTerms: []
    }, {
        title: "fas://download",
        searchTerms: [ "import" ]
    }, {
        title: "fab://draft2digital",
        searchTerms: []
    }, {
        title: "fab://dribbble",
        searchTerms: []
    }, {
        title: "fab://dribbble-square",
        searchTerms: []
    }, {
        title: "fab://dropbox",
        searchTerms: []
    }, {
        title: "fab://drupal",
        searchTerms: []
    }, {
        title: "fab://dyalog",
        searchTerms: []
    }, {
        title: "fab://earlybirds",
        searchTerms: []
    }, {
        title: "fab://edge",
        searchTerms: [ "browser", "ie" ]
    }, {
        title: "fas://edit",
        searchTerms: [ "write", "edit", "update", "pencil", "pen" ]
    }, {
        title: "far://edit",
        searchTerms: [ "write", "edit", "update", "pencil", "pen" ]
    }, {
        title: "fas://eject",
        searchTerms: []
    }, {
        title: "fab://elementor",
        searchTerms: []
    }, {
        title: "fas://ellipsis-h",
        searchTerms: [ "dots", "menu", "drag", "reorder", "settings", "list", "ul", "ol", "kebab", "navigation", "nav" ]
    }, {
        title: "fas://ellipsis-v",
        searchTerms: [ "dots", "menu", "drag", "reorder", "settings", "list", "ul", "ol", "kebab", "navigation", "nav" ]
    }, {
        title: "fab://ember",
        searchTerms: []
    }, {
        title: "fab://empire",
        searchTerms: []
    }, {
        title: "fas://envelope",
        searchTerms: [ "email", "e-mail", "letter", "support", "mail", "message", "notification" ]
    }, {
        title: "far://envelope",
        searchTerms: [ "email", "e-mail", "letter", "support", "mail", "message", "notification" ]
    }, {
        title: "fas://envelope-open",
        searchTerms: [ "email", "e-mail", "letter", "support", "mail", "message", "notification" ]
    }, {
        title: "far://envelope-open",
        searchTerms: [ "email", "e-mail", "letter", "support", "mail", "message", "notification" ]
    }, {
        title: "fas://envelope-square",
        searchTerms: [ "email", "e-mail", "letter", "support", "mail", "message", "notification" ]
    }, {
        title: "fab://envira",
        searchTerms: [ "leaf" ]
    }, {
        title: "fas://eraser",
        searchTerms: [ "remove", "delete" ]
    }, {
        title: "fab://erlang",
        searchTerms: []
    }, {
        title: "fab://ethereum",
        searchTerms: []
    }, {
        title: "fab://etsy",
        searchTerms: []
    }, {
        title: "fas://euro-sign",
        searchTerms: [ "eur", "eur" ]
    }, {
        title: "fas://exchange-alt",
        searchTerms: [ "transfer", "arrows", "arrow", "exchange", "swap", "return", "reciprocate" ]
    }, {
        title: "fas://exclamation",
        searchTerms: [ "warning", "error", "problem", "notification", "notify", "notice", "alert", "danger" ]
    }, {
        title: "fas://exclamation-circle",
        searchTerms: [ "warning", "error", "problem", "notification", "notify", "notice", "alert", "danger" ]
    }, {
        title: "fas://exclamation-triangle",
        searchTerms: [ "warning", "error", "problem", "notification", "notify", "notice", "alert", "danger" ]
    }, {
        title: "fas://expand",
        searchTerms: [ "enlarge", "bigger", "resize" ]
    }, {
        title: "fas://expand-arrows-alt",
        searchTerms: [ "enlarge", "bigger", "resize", "move", "arrows-alt" ]
    }, {
        title: "fab://expeditedssl",
        searchTerms: []
    }, {
        title: "fas://external-link-alt",
        searchTerms: [ "open", "new", "external-link" ]
    }, {
        title: "fas://external-link-square-alt",
        searchTerms: [ "open", "new", "external-link-square" ]
    }, {
        title: "fas://eye",
        searchTerms: [ "show", "visible", "views", "see", "seen", "sight", "optic" ]
    }, {
        title: "fas://eye-dropper",
        searchTerms: [ "eyedropper" ]
    }, {
        title: "fas://eye-slash",
        searchTerms: [ "toggle", "show", "hide", "visible", "visiblity", "views", "unseen", "blind" ]
    }, {
        title: "far://eye-slash",
        searchTerms: [ "toggle", "show", "hide", "visible", "visiblity", "views", "unseen", "blind" ]
    }, {
        title: "fab://facebook",
        searchTerms: [ "social network", "facebook-official" ]
    }, {
        title: "fab://facebook-f",
        searchTerms: [ "facebook" ]
    }, {
        title: "fab://facebook-messenger",
        searchTerms: []
    }, {
        title: "fab://facebook-square",
        searchTerms: [ "social network" ]
    }, {
        title: "fas://fast-backward",
        searchTerms: [ "rewind", "previous", "beginning", "start", "first" ]
    }, {
        title: "fas://fast-forward",
        searchTerms: [ "next", "end", "last" ]
    }, {
        title: "fas://fax",
        searchTerms: []
    }, {
        title: "fas://female",
        searchTerms: [ "woman", "human", "user", "person", "profile" ]
    }, {
        title: "fas://fighter-jet",
        searchTerms: [ "fly", "plane", "airplane", "quick", "fast", "travel", "transportation", "maverick", "goose", "top gun" ]
    }, {
        title: "fas://file",
        searchTerms: [ "new", "page", "pdf", "document" ]
    }, {
        title: "far://file",
        searchTerms: [ "new", "page", "pdf", "document" ]
    }, {
        title: "fas://file-alt",
        searchTerms: [ "new", "page", "pdf", "document", "file-text", "invoice" ]
    }, {
        title: "far://file-alt",
        searchTerms: [ "new", "page", "pdf", "document", "file-text", "invoice" ]
    }, {
        title: "fas://file-archive",
        searchTerms: [ "zip", ".zip", "compress", "compression", "bundle", "download" ]
    }, {
        title: "far://file-archive",
        searchTerms: [ "zip", ".zip", "compress", "compression", "bundle", "download" ]
    }, {
        title: "fas://file-audio",
        searchTerms: []
    }, {
        title: "far://file-audio",
        searchTerms: []
    }, {
        title: "fas://file-code",
        searchTerms: []
    }, {
        title: "far://file-code",
        searchTerms: []
    }, {
        title: "fas://file-excel",
        searchTerms: []
    }, {
        title: "far://file-excel",
        searchTerms: []
    }, {
        title: "fas://file-image",
        searchTerms: []
    }, {
        title: "far://file-image",
        searchTerms: []
    }, {
        title: "fas://file-medical",
        searchTerms: []
    }, {
        title: "fas://file-medical-alt",
        searchTerms: []
    }, {
        title: "fas://file-pdf",
        searchTerms: []
    }, {
        title: "far://file-pdf",
        searchTerms: []
    }, {
        title: "fas://file-powerpoint",
        searchTerms: []
    }, {
        title: "far://file-powerpoint",
        searchTerms: []
    }, {
        title: "fas://file-video",
        searchTerms: []
    }, {
        title: "far://file-video",
        searchTerms: []
    }, {
        title: "fas://file-word",
        searchTerms: []
    }, {
        title: "far://file-word",
        searchTerms: []
    }, {
        title: "fas://film",
        searchTerms: [ "movie" ]
    }, {
        title: "fas://filter",
        searchTerms: [ "funnel", "options" ]
    }, {
        title: "fas://fire",
        searchTerms: [ "flame", "hot", "popular" ]
    }, {
        title: "fas://fire-extinguisher",
        searchTerms: []
    }, {
        title: "fab://firefox",
        searchTerms: [ "browser" ]
    }, {
        title: "fas://first-aid",
        searchTerms: []
    }, {
        title: "fab://first-order",
        searchTerms: []
    }, {
        title: "fab://firstdraft",
        searchTerms: []
    }, {
        title: "fas://flag",
        searchTerms: [ "report", "notification", "notify", "notice" ]
    }, {
        title: "far://flag",
        searchTerms: [ "report", "notification", "notify", "notice" ]
    }, {
        title: "fas://flag-checkered",
        searchTerms: [ "report", "notification", "notify", "notice" ]
    }, {
        title: "fas://flask",
        searchTerms: [ "science", "beaker", "experimental", "labs" ]
    }, {
        title: "fab://flickr",
        searchTerms: []
    }, {
        title: "fab://flipboard",
        searchTerms: []
    }, {
        title: "fab://fly",
        searchTerms: []
    }, {
        title: "fas://folder",
        searchTerms: []
    }, {
        title: "far://folder",
        searchTerms: []
    }, {
        title: "fas://folder-open",
        searchTerms: []
    }, {
        title: "far://folder-open",
        searchTerms: []
    }, {
        title: "fas://font",
        searchTerms: [ "text" ]
    }, {
        title: "fab://font-awesome",
        searchTerms: [ "meanpath" ]
    }, {
        title: "fab://font-awesome-alt",
        searchTerms: []
    }, {
        title: "fab://font-awesome-flag",
        searchTerms: []
    }, {
        title: "fab://fonticons",
        searchTerms: []
    }, {
        title: "fab://fonticons-fi",
        searchTerms: []
    }, {
        title: "fas://football-ball",
        searchTerms: []
    }, {
        title: "fab://fort-awesome",
        searchTerms: [ "castle" ]
    }, {
        title: "fab://fort-awesome-alt",
        searchTerms: [ "castle" ]
    }, {
        title: "fab://forumbee",
        searchTerms: []
    }, {
        title: "fas://forward",
        searchTerms: [ "forward", "next" ]
    }, {
        title: "fab://foursquare",
        searchTerms: []
    }, {
        title: "fab://free-code-camp",
        searchTerms: []
    }, {
        title: "fab://freebsd",
        searchTerms: []
    }, {
        title: "fas://frown",
        searchTerms: [ "face", "emoticon", "sad", "disapprove", "rating" ]
    }, {
        title: "far://frown",
        searchTerms: [ "face", "emoticon", "sad", "disapprove", "rating" ]
    }, {
        title: "fas://futbol",
        searchTerms: [ "soccer", "football", "ball" ]
    }, {
        title: "far://futbol",
        searchTerms: [ "soccer", "football", "ball" ]
    }, {
        title: "fas://gamepad",
        searchTerms: [ "controller" ]
    }, {
        title: "fas://gavel",
        searchTerms: [ "judge", "lawyer", "opinion", "hammer" ]
    }, {
        title: "fas://gem",
        searchTerms: [ "diamond" ]
    }, {
        title: "far://gem",
        searchTerms: [ "diamond" ]
    }, {
        title: "fas://genderless",
        searchTerms: []
    }, {
        title: "fab://get-pocket",
        searchTerms: []
    }, {
        title: "fab://gg",
        searchTerms: []
    }, {
        title: "fab://gg-circle",
        searchTerms: []
    }, {
        title: "fas://gift",
        searchTerms: [ "present", "party", "wrapped", "giving", "generosity" ]
    }, {
        title: "fab://git",
        searchTerms: []
    }, {
        title: "fab://git-square",
        searchTerms: []
    }, {
        title: "fab://github",
        searchTerms: [ "octocat" ]
    }, {
        title: "fab://github-alt",
        searchTerms: [ "octocat" ]
    }, {
        title: "fab://github-square",
        searchTerms: [ "octocat" ]
    }, {
        title: "fab://gitkraken",
        searchTerms: []
    }, {
        title: "fab://gitlab",
        searchTerms: [ "Axosoft" ]
    }, {
        title: "fab://gitter",
        searchTerms: []
    }, {
        title: "fas://glass-martini",
        searchTerms: [ "martini", "drink", "bar", "alcohol", "liquor", "glass" ]
    }, {
        title: "fab://glide",
        searchTerms: []
    }, {
        title: "fab://glide-g",
        searchTerms: []
    }, {
        title: "fas://globe",
        searchTerms: [ "world", "planet", "map", "place", "travel", "earth", "global", "translate", "all", "language", "localize", "location", "coordinates", "country", "gps", "online" ]
    }, {
        title: "fab://gofore",
        searchTerms: []
    }, {
        title: "fas://golf-ball",
        searchTerms: []
    }, {
        title: "fab://goodreads",
        searchTerms: []
    }, {
        title: "fab://goodreads-g",
        searchTerms: []
    }, {
        title: "fab://google",
        searchTerms: []
    }, {
        title: "fab://google-drive",
        searchTerms: []
    }, {
        title: "fab://google-play",
        searchTerms: []
    }, {
        title: "fab://google-plus",
        searchTerms: [ "google-plus-circle", "google-plus-official" ]
    }, {
        title: "fab://google-plus-g",
        searchTerms: [ "social network", "google-plus" ]
    }, {
        title: "fab://google-plus-square",
        searchTerms: [ "social network" ]
    }, {
        title: "fab://google-wallet",
        searchTerms: []
    }, {
        title: "fas://graduation-cap",
        searchTerms: [ "learning", "school", "student" ]
    }, {
        title: "fab://gratipay",
        searchTerms: [ "heart", "like", "favorite", "love" ]
    }, {
        title: "fab://grav",
        searchTerms: []
    }, {
        title: "fab://gripfire",
        searchTerms: []
    }, {
        title: "fab://grunt",
        searchTerms: []
    }, {
        title: "fab://gulp",
        searchTerms: []
    }, {
        title: "fas://h-square",
        searchTerms: [ "hospital", "hotel" ]
    }, {
        title: "fab://hacker-news",
        searchTerms: []
    }, {
        title: "fab://hacker-news-square",
        searchTerms: []
    }, {
        title: "fas://hand-holding",
        searchTerms: []
    }, {
        title: "fas://hand-holding-heart",
        searchTerms: []
    }, {
        title: "fas://hand-holding-usd",
        searchTerms: [ "dollar sign", "price", "donation", "giving" ]
    }, {
        title: "fas://hand-lizard",
        searchTerms: []
    }, {
        title: "far://hand-lizard",
        searchTerms: []
    }, {
        title: "fas://hand-paper",
        searchTerms: [ "stop" ]
    }, {
        title: "far://hand-paper",
        searchTerms: [ "stop" ]
    }, {
        title: "fas://hand-peace",
        searchTerms: []
    }, {
        title: "far://hand-peace",
        searchTerms: []
    }, {
        title: "fas://hand-point-down",
        searchTerms: [ "point", "finger", "hand-o-down" ]
    }, {
        title: "far://hand-point-down",
        searchTerms: [ "point", "finger", "hand-o-down" ]
    }, {
        title: "fas://hand-point-left",
        searchTerms: [ "point", "left", "previous", "back", "finger", "hand-o-left" ]
    }, {
        title: "far://hand-point-left",
        searchTerms: [ "point", "left", "previous", "back", "finger", "hand-o-left" ]
    }, {
        title: "fas://hand-point-right",
        searchTerms: [ "point", "right", "next", "forward", "finger", "hand-o-right" ]
    }, {
        title: "far://hand-point-right",
        searchTerms: [ "point", "right", "next", "forward", "finger", "hand-o-right" ]
    }, {
        title: "fas://hand-point-up",
        searchTerms: [ "point", "finger", "hand-o-up" ]
    }, {
        title: "far://hand-point-up",
        searchTerms: [ "point", "finger", "hand-o-up" ]
    }, {
        title: "fas://hand-pointer",
        searchTerms: [ "select" ]
    }, {
        title: "far://hand-pointer",
        searchTerms: [ "select" ]
    }, {
        title: "fas://hand-rock",
        searchTerms: []
    }, {
        title: "far://hand-rock",
        searchTerms: []
    }, {
        title: "fas://hand-scissors",
        searchTerms: []
    }, {
        title: "far://hand-scissors",
        searchTerms: []
    }, {
        title: "fas://hand-spock",
        searchTerms: []
    }, {
        title: "far://hand-spock",
        searchTerms: []
    }, {
        title: "fas://hands",
        searchTerms: []
    }, {
        title: "fas://hands-helping",
        searchTerms: [ "assistance", "aid", "partnership", "volunteering" ]
    }, {
        title: "fas://handshake",
        searchTerms: [ "greeting", "partnership" ]
    }, {
        title: "far://handshake",
        searchTerms: [ "greeting", "partnership" ]
    }, {
        title: "fas://hashtag",
        searchTerms: []
    }, {
        title: "fas://hdd",
        searchTerms: [ "harddrive", "hard drive", "storage", "save", "machine" ]
    }, {
        title: "far://hdd",
        searchTerms: [ "harddrive", "hard drive", "storage", "save", "machine" ]
    }, {
        title: "fas://heading",
        searchTerms: [ "header", "header" ]
    }, {
        title: "fas://headphones",
        searchTerms: [ "sound", "listen", "music", "audio", "speaker" ]
    }, {
        title: "fas://heart",
        searchTerms: [ "love", "like", "favorite" ]
    }, {
        title: "far://heart",
        searchTerms: [ "love", "like", "favorite" ]
    }, {
        title: "fas://heartbeat",
        searchTerms: [ "ekg", "vital signs", "lifeline" ]
    }, {
        title: "fab://hips",
        searchTerms: []
    }, {
        title: "fab://hire-a-helper",
        searchTerms: []
    }, {
        title: "fas://history",
        searchTerms: []
    }, {
        title: "fas://hockey-puck",
        searchTerms: []
    }, {
        title: "fas://home",
        searchTerms: [ "main", "house" ]
    }, {
        title: "fab://hooli",
        searchTerms: []
    }, {
        title: "fas://hospital",
        searchTerms: [ "building", "medical center", "emergency room" ]
    }, {
        title: "far://hospital",
        searchTerms: [ "building", "medical center", "emergency room" ]
    }, {
        title: "fas://hospital-alt",
        searchTerms: [ "building", "medical center", "emergency room" ]
    }, {
        title: "fas://hospital-symbol",
        searchTerms: []
    }, {
        title: "fab://hotjar",
        searchTerms: []
    }, {
        title: "fas://hourglass",
        searchTerms: []
    }, {
        title: "far://hourglass",
        searchTerms: []
    }, {
        title: "fas://hourglass-end",
        searchTerms: []
    }, {
        title: "fas://hourglass-half",
        searchTerms: []
    }, {
        title: "fas://hourglass-start",
        searchTerms: []
    }, {
        title: "fab://houzz",
        searchTerms: []
    }, {
        title: "fab://html5",
        searchTerms: []
    }, {
        title: "fab://hubspot",
        searchTerms: []
    }, {
        title: "fas://i-cursor",
        searchTerms: []
    }, {
        title: "fas://id-badge",
        searchTerms: []
    }, {
        title: "far://id-badge",
        searchTerms: []
    }, {
        title: "fas://id-card",
        searchTerms: []
    }, {
        title: "far://id-card",
        searchTerms: []
    }, {
        title: "fas://id-card-alt",
        searchTerms: [ "demographics" ]
    }, {
        title: "fas://image",
        searchTerms: [ "photo", "album", "picture", "picture" ]
    }, {
        title: "far://image",
        searchTerms: [ "photo", "album", "picture", "picture" ]
    }, {
        title: "fas://images",
        searchTerms: [ "photo", "album", "picture" ]
    }, {
        title: "far://images",
        searchTerms: [ "photo", "album", "picture" ]
    }, {
        title: "fab://imdb",
        searchTerms: []
    }, {
        title: "fas://inbox",
        searchTerms: []
    }, {
        title: "fas://indent",
        searchTerms: []
    }, {
        title: "fas://industry",
        searchTerms: [ "factory", "manufacturing" ]
    }, {
        title: "fas://info",
        searchTerms: [ "help", "information", "more", "details" ]
    }, {
        title: "fas://info-circle",
        searchTerms: [ "help", "information", "more", "details" ]
    }, {
        title: "fab://instagram",
        searchTerms: []
    }, {
        title: "fab://internet-explorer",
        searchTerms: [ "browser", "ie" ]
    }, {
        title: "fab://ioxhost",
        searchTerms: []
    }, {
        title: "fas://italic",
        searchTerms: [ "italics" ]
    }, {
        title: "fab://itunes",
        searchTerms: []
    }, {
        title: "fab://itunes-note",
        searchTerms: []
    }, {
        title: "fab://jenkins",
        searchTerms: []
    }, {
        title: "fab://joget",
        searchTerms: []
    }, {
        title: "fab://joomla",
        searchTerms: []
    }, {
        title: "fab://js",
        searchTerms: []
    }, {
        title: "fab://js-square",
        searchTerms: []
    }, {
        title: "fab://jsfiddle",
        searchTerms: []
    }, {
        title: "fas://key",
        searchTerms: [ "unlock", "password" ]
    }, {
        title: "fas://keyboard",
        searchTerms: [ "type", "input" ]
    }, {
        title: "far://keyboard",
        searchTerms: [ "type", "input" ]
    }, {
        title: "fab://keycdn",
        searchTerms: []
    }, {
        title: "fab://kickstarter",
        searchTerms: []
    }, {
        title: "fab://kickstarter-k",
        searchTerms: []
    }, {
        title: "fab://korvue",
        searchTerms: []
    }, {
        title: "fas://language",
        searchTerms: []
    }, {
        title: "fas://laptop",
        searchTerms: [ "demo", "computer", "device", "pc", "mac", "pc", "macbook", "dell", "dude you're getting", "machine" ]
    }, {
        title: "fab://laravel",
        searchTerms: []
    }, {
        title: "fab://lastfm",
        searchTerms: []
    }, {
        title: "fab://lastfm-square",
        searchTerms: []
    }, {
        title: "fas://leaf",
        searchTerms: [ "eco", "nature", "plant" ]
    }, {
        title: "fab://leanpub",
        searchTerms: []
    }, {
        title: "fas://lemon",
        searchTerms: [ "food" ]
    }, {
        title: "far://lemon",
        searchTerms: [ "food" ]
    }, {
        title: "fab://less",
        searchTerms: []
    }, {
        title: "fas://level-down-alt",
        searchTerms: [ "level-down" ]
    }, {
        title: "fas://level-up-alt",
        searchTerms: [ "level-up" ]
    }, {
        title: "fas://life-ring",
        searchTerms: [ "support" ]
    }, {
        title: "far://life-ring",
        searchTerms: [ "support" ]
    }, {
        title: "fas://lightbulb",
        searchTerms: [ "idea", "inspiration" ]
    }, {
        title: "far://lightbulb",
        searchTerms: [ "idea", "inspiration" ]
    }, {
        title: "fab://line",
        searchTerms: []
    }, {
        title: "fas://link",
        searchTerms: [ "chain" ]
    }, {
        title: "fab://linkedin",
        searchTerms: [ "linkedin-square" ]
    }, {
        title: "fab://linkedin-in",
        searchTerms: [ "linkedin" ]
    }, {
        title: "fab://linode",
        searchTerms: []
    }, {
        title: "fab://linux",
        searchTerms: [ "tux" ]
    }, {
        title: "fas://lira-sign",
        searchTerms: [ "try", "turkish", "try" ]
    }, {
        title: "fas://list",
        searchTerms: [ "ul", "ol", "checklist", "finished", "completed", "done", "todo" ]
    }, {
        title: "fas://list-alt",
        searchTerms: [ "ul", "ol", "checklist", "finished", "completed", "done", "todo" ]
    }, {
        title: "far://list-alt",
        searchTerms: [ "ul", "ol", "checklist", "finished", "completed", "done", "todo" ]
    }, {
        title: "fas://list-ol",
        searchTerms: [ "ul", "ol", "checklist", "list", "todo", "list", "numbers" ]
    }, {
        title: "fas://list-ul",
        searchTerms: [ "ul", "ol", "checklist", "todo", "list" ]
    }, {
        title: "fas://location-arrow",
        searchTerms: [ "map", "coordinates", "location", "address", "place", "where", "gps" ]
    }, {
        title: "fas://lock",
        searchTerms: [ "protect", "admin", "security" ]
    }, {
        title: "fas://lock-open",
        searchTerms: [ "protect", "admin", "password", "lock", "open" ]
    }, {
        title: "fas://long-arrow-alt-down",
        searchTerms: [ "long-arrow-down" ]
    }, {
        title: "fas://long-arrow-alt-left",
        searchTerms: [ "previous", "back", "long-arrow-left" ]
    }, {
        title: "fas://long-arrow-alt-right",
        searchTerms: [ "long-arrow-right" ]
    }, {
        title: "fas://long-arrow-alt-up",
        searchTerms: [ "long-arrow-up" ]
    }, {
        title: "fas://low-vision",
        searchTerms: []
    }, {
        title: "fab://lyft",
        searchTerms: []
    }, {
        title: "fab://magento",
        searchTerms: []
    }, {
        title: "fas://magic",
        searchTerms: [ "wizard", "automatic", "autocomplete" ]
    }, {
        title: "fas://magnet",
        searchTerms: []
    }, {
        title: "fas://male",
        searchTerms: [ "man", "human", "user", "person", "profile" ]
    }, {
        title: "fas://map",
        searchTerms: []
    }, {
        title: "far://map",
        searchTerms: []
    }, {
        title: "fas://map-marker",
        searchTerms: [ "map", "pin", "location", "coordinates", "localize", "address", "travel", "where", "place", "gps" ]
    }, {
        title: "fas://map-marker-alt",
        searchTerms: [ "map-marker", "gps" ]
    }, {
        title: "fas://map-pin",
        searchTerms: []
    }, {
        title: "fas://map-signs",
        searchTerms: []
    }, {
        title: "fas://mars",
        searchTerms: [ "male" ]
    }, {
        title: "fas://mars-double",
        searchTerms: []
    }, {
        title: "fas://mars-stroke",
        searchTerms: []
    }, {
        title: "fas://mars-stroke-h",
        searchTerms: []
    }, {
        title: "fas://mars-stroke-v",
        searchTerms: []
    }, {
        title: "fab://maxcdn",
        searchTerms: []
    }, {
        title: "fab://medapps",
        searchTerms: []
    }, {
        title: "fab://medium",
        searchTerms: []
    }, {
        title: "fab://medium-m",
        searchTerms: []
    }, {
        title: "fas://medkit",
        searchTerms: [ "first aid", "firstaid", "help", "support", "health" ]
    }, {
        title: "fab://medrt",
        searchTerms: []
    }, {
        title: "fab://meetup",
        searchTerms: []
    }, {
        title: "fas://meh",
        searchTerms: [ "face", "emoticon", "rating", "neutral" ]
    }, {
        title: "far://meh",
        searchTerms: [ "face", "emoticon", "rating", "neutral" ]
    }, {
        title: "fas://mercury",
        searchTerms: [ "transgender" ]
    }, {
        title: "fas://microchip",
        searchTerms: []
    }, {
        title: "fas://microphone",
        searchTerms: [ "record", "voice", "sound" ]
    }, {
        title: "fas://microphone-slash",
        searchTerms: [ "record", "voice", "sound", "mute" ]
    }, {
        title: "fab://microsoft",
        searchTerms: []
    }, {
        title: "fas://minus",
        searchTerms: [ "hide", "minify", "delete", "remove", "trash", "hide", "collapse" ]
    }, {
        title: "fas://minus-circle",
        searchTerms: [ "delete", "remove", "trash", "hide" ]
    }, {
        title: "fas://minus-square",
        searchTerms: [ "hide", "minify", "delete", "remove", "trash", "hide", "collapse" ]
    }, {
        title: "far://minus-square",
        searchTerms: [ "hide", "minify", "delete", "remove", "trash", "hide", "collapse" ]
    }, {
        title: "fab://mix",
        searchTerms: []
    }, {
        title: "fab://mixcloud",
        searchTerms: []
    }, {
        title: "fab://mizuni",
        searchTerms: []
    }, {
        title: "fas://mobile",
        searchTerms: [ "cell phone", "cellphone", "text", "call", "number", "telephone", "device", "screen", "apple", "iphone" ]
    }, {
        title: "fas://mobile-alt",
        searchTerms: [ "cell phone", "cellphone", "text", "call", "number", "telephone", "device", "screen", "apple", "iphone" ]
    }, {
        title: "fab://modx",
        searchTerms: []
    }, {
        title: "fab://monero",
        searchTerms: []
    }, {
        title: "fas://money-bill-alt",
        searchTerms: [ "cash", "money", "buy", "checkout", "purchase", "payment", "price" ]
    }, {
        title: "far://money-bill-alt",
        searchTerms: [ "cash", "money", "buy", "checkout", "purchase", "payment", "price" ]
    }, {
        title: "fas://moon",
        searchTerms: [ "night", "darker", "contrast" ]
    }, {
        title: "far://moon",
        searchTerms: [ "night", "darker", "contrast" ]
    }, {
        title: "fas://motorcycle",
        searchTerms: [ "vehicle", "machine", "transportation", "bike" ]
    }, {
        title: "fas://mouse-pointer",
        searchTerms: [ "select" ]
    }, {
        title: "fas://music",
        searchTerms: [ "note", "sound" ]
    }, {
        title: "fab://napster",
        searchTerms: []
    }, {
        title: "fas://neuter",
        searchTerms: []
    }, {
        title: "fas://newspaper",
        searchTerms: [ "press", "article" ]
    }, {
        title: "far://newspaper",
        searchTerms: [ "press", "article" ]
    }, {
        title: "fab://nintendo-switch",
        searchTerms: []
    }, {
        title: "fab://node",
        searchTerms: []
    }, {
        title: "fab://node-js",
        searchTerms: []
    }, {
        title: "fas://notes-medical",
        searchTerms: []
    }, {
        title: "fab://npm",
        searchTerms: []
    }, {
        title: "fab://ns8",
        searchTerms: []
    }, {
        title: "fab://nutritionix",
        searchTerms: []
    }, {
        title: "fas://object-group",
        searchTerms: [ "design" ]
    }, {
        title: "far://object-group",
        searchTerms: [ "design" ]
    }, {
        title: "fas://object-ungroup",
        searchTerms: [ "design" ]
    }, {
        title: "far://object-ungroup",
        searchTerms: [ "design" ]
    }, {
        title: "fab://odnoklassniki",
        searchTerms: []
    }, {
        title: "fab://odnoklassniki-square",
        searchTerms: []
    }, {
        title: "fab://opencart",
        searchTerms: []
    }, {
        title: "fab://openid",
        searchTerms: []
    }, {
        title: "fab://opera",
        searchTerms: []
    }, {
        title: "fab://optin-monster",
        searchTerms: []
    }, {
        title: "fab://osi",
        searchTerms: []
    }, {
        title: "fas://outdent",
        searchTerms: []
    }, {
        title: "fab://page4",
        searchTerms: []
    }, {
        title: "fab://pagelines",
        searchTerms: [ "leaf", "leaves", "tree", "plant", "eco", "nature" ]
    }, {
        title: "fas://paint-brush",
        searchTerms: []
    }, {
        title: "fab://palfed",
        searchTerms: []
    }, {
        title: "fas://pallet",
        searchTerms: []
    }, {
        title: "fas://paper-plane",
        searchTerms: []
    }, {
        title: "far://paper-plane",
        searchTerms: []
    }, {
        title: "fas://paperclip",
        searchTerms: [ "attachment" ]
    }, {
        title: "fas://parachute-box",
        searchTerms: [ "aid", "assistance", "rescue", "supplies" ]
    }, {
        title: "fas://paragraph",
        searchTerms: []
    }, {
        title: "fas://paste",
        searchTerms: [ "copy", "clipboard" ]
    }, {
        title: "fab://patreon",
        searchTerms: []
    }, {
        title: "fas://pause",
        searchTerms: [ "wait" ]
    }, {
        title: "fas://pause-circle",
        searchTerms: []
    }, {
        title: "far://pause-circle",
        searchTerms: []
    }, {
        title: "fas://paw",
        searchTerms: [ "pet" ]
    }, {
        title: "fab://paypal",
        searchTerms: []
    }, {
        title: "fas://pen-square",
        searchTerms: [ "write", "edit", "update", "pencil-square" ]
    }, {
        title: "fas://pencil-alt",
        searchTerms: [ "write", "edit", "update", "pencil", "design" ]
    }, {
        title: "fas://people-carry",
        searchTerms: [ "movers" ]
    }, {
        title: "fas://percent",
        searchTerms: []
    }, {
        title: "fab://periscope",
        searchTerms: []
    }, {
        title: "fab://phabricator",
        searchTerms: []
    }, {
        title: "fab://phoenix-framework",
        searchTerms: []
    }, {
        title: "fas://phone",
        searchTerms: [ "call", "voice", "number", "support", "earphone", "telephone" ]
    }, {
        title: "fas://phone-slash",
        searchTerms: []
    }, {
        title: "fas://phone-square",
        searchTerms: [ "call", "voice", "number", "support", "telephone" ]
    }, {
        title: "fas://phone-volume",
        searchTerms: [ "telephone", "volume-control-phone" ]
    }, {
        title: "fab://php",
        searchTerms: []
    }, {
        title: "fab://pied-piper",
        searchTerms: []
    }, {
        title: "fab://pied-piper-alt",
        searchTerms: []
    }, {
        title: "fab://pied-piper-pp",
        searchTerms: []
    }, {
        title: "fas://piggy-bank",
        searchTerms: [ "savings", "save" ]
    }, {
        title: "fas://pills",
        searchTerms: [ "medicine", "drugs" ]
    }, {
        title: "fab://pinterest",
        searchTerms: []
    }, {
        title: "fab://pinterest-p",
        searchTerms: []
    }, {
        title: "fab://pinterest-square",
        searchTerms: []
    }, {
        title: "fas://plane",
        searchTerms: [ "travel", "trip", "location", "destination", "airplane", "fly", "mode" ]
    }, {
        title: "fas://play",
        searchTerms: [ "start", "playing", "music", "sound" ]
    }, {
        title: "fas://play-circle",
        searchTerms: [ "start", "playing" ]
    }, {
        title: "far://play-circle",
        searchTerms: [ "start", "playing" ]
    }, {
        title: "fab://playstation",
        searchTerms: []
    }, {
        title: "fas://plug",
        searchTerms: [ "power", "connect", "online" ]
    }, {
        title: "fas://plus",
        searchTerms: [ "add", "new", "create", "expand" ]
    }, {
        title: "fas://plus-circle",
        searchTerms: [ "add", "new", "create", "expand" ]
    }, {
        title: "fas://plus-square",
        searchTerms: [ "add", "new", "create", "expand" ]
    }, {
        title: "far://plus-square",
        searchTerms: [ "add", "new", "create", "expand" ]
    }, {
        title: "fas://podcast",
        searchTerms: []
    }, {
        title: "fas://poo",
        searchTerms: []
    }, {
        title: "fas://pound-sign",
        searchTerms: [ "gbp", "gbp" ]
    }, {
        title: "fas://power-off",
        searchTerms: [ "on" ]
    }, {
        title: "fas://prescription-bottle",
        searchTerms: [ "prescription", "rx" ]
    }, {
        title: "fas://prescription-bottle-alt",
        searchTerms: [ "prescription", "rx" ]
    }, {
        title: "fas://print",
        searchTerms: []
    }, {
        title: "fas://procedures",
        searchTerms: []
    }, {
        title: "fab://product-hunt",
        searchTerms: []
    }, {
        title: "fab://pushed",
        searchTerms: []
    }, {
        title: "fas://puzzle-piece",
        searchTerms: [ "addon", "add-on", "section" ]
    }, {
        title: "fab://python",
        searchTerms: []
    }, {
        title: "fab://qq",
        searchTerms: []
    }, {
        title: "fas://qrcode",
        searchTerms: [ "scan" ]
    }, {
        title: "fas://question",
        searchTerms: [ "help", "information", "unknown", "support" ]
    }, {
        title: "fas://question-circle",
        searchTerms: [ "help", "information", "unknown", "support" ]
    }, {
        title: "far://question-circle",
        searchTerms: [ "help", "information", "unknown", "support" ]
    }, {
        title: "fas://quidditch",
        searchTerms: []
    }, {
        title: "fab://quinscape",
        searchTerms: []
    }, {
        title: "fab://quora",
        searchTerms: []
    }, {
        title: "fas://quote-left",
        searchTerms: []
    }, {
        title: "fas://quote-right",
        searchTerms: []
    }, {
        title: "fas://random",
        searchTerms: [ "sort", "shuffle" ]
    }, {
        title: "fab://ravelry",
        searchTerms: []
    }, {
        title: "fab://react",
        searchTerms: []
    }, {
        title: "fab://readme",
        searchTerms: []
    }, {
        title: "fab://rebel",
        searchTerms: []
    }, {
        title: "fas://recycle",
        searchTerms: []
    }, {
        title: "fab://red-river",
        searchTerms: []
    }, {
        title: "fab://reddit",
        searchTerms: []
    }, {
        title: "fab://reddit-alien",
        searchTerms: []
    }, {
        title: "fab://reddit-square",
        searchTerms: []
    }, {
        title: "fas://redo",
        searchTerms: [ "forward", "repeat", "repeat" ]
    }, {
        title: "fas://redo-alt",
        searchTerms: [ "forward", "repeat" ]
    }, {
        title: "fas://registered",
        searchTerms: []
    }, {
        title: "far://registered",
        searchTerms: []
    }, {
        title: "fab://rendact",
        searchTerms: []
    }, {
        title: "fab://renren",
        searchTerms: []
    }, {
        title: "fas://reply",
        searchTerms: []
    }, {
        title: "fas://reply-all",
        searchTerms: []
    }, {
        title: "fab://replyd",
        searchTerms: []
    }, {
        title: "fab://resolving",
        searchTerms: []
    }, {
        title: "fas://retweet",
        searchTerms: [ "refresh", "reload", "share", "swap" ]
    }, {
        title: "fas://ribbon",
        searchTerms: [ "cause", "badge", "pin", "lapel" ]
    }, {
        title: "fas://road",
        searchTerms: [ "street" ]
    }, {
        title: "fas://rocket",
        searchTerms: [ "app" ]
    }, {
        title: "fab://rocketchat",
        searchTerms: []
    }, {
        title: "fab://rockrms",
        searchTerms: []
    }, {
        title: "fas://rss",
        searchTerms: [ "blog" ]
    }, {
        title: "fas://rss-square",
        searchTerms: [ "feed", "blog" ]
    }, {
        title: "fas://ruble-sign",
        searchTerms: [ "rub", "rub" ]
    }, {
        title: "fas://rupee-sign",
        searchTerms: [ "indian", "inr" ]
    }, {
        title: "fab://safari",
        searchTerms: [ "browser" ]
    }, {
        title: "fab://sass",
        searchTerms: []
    }, {
        title: "fas://save",
        searchTerms: [ "floppy", "floppy-o" ]
    }, {
        title: "far://save",
        searchTerms: [ "floppy", "floppy-o" ]
    }, {
        title: "fab://schlix",
        searchTerms: []
    }, {
        title: "fab://scribd",
        searchTerms: []
    }, {
        title: "fas://search",
        searchTerms: [ "magnify", "zoom", "enlarge", "bigger", "preview" ]
    }, {
        title: "fas://search-minus",
        searchTerms: [ "magnify", "minify", "zoom", "smaller", "zoom out" ]
    }, {
        title: "fas://search-plus",
        searchTerms: [ "magnify", "zoom", "enlarge", "bigger", "zoom in" ]
    }, {
        title: "fab://searchengin",
        searchTerms: []
    }, {
        title: "fas://seedling",
        searchTerms: []
    }, {
        title: "fab://sellcast",
        searchTerms: [ "eercast" ]
    }, {
        title: "fab://sellsy",
        searchTerms: []
    }, {
        title: "fas://server",
        searchTerms: []
    }, {
        title: "fab://servicestack",
        searchTerms: []
    }, {
        title: "fas://share",
        searchTerms: []
    }, {
        title: "fas://share-alt",
        searchTerms: []
    }, {
        title: "fas://share-alt-square",
        searchTerms: []
    }, {
        title: "fas://share-square",
        searchTerms: [ "social", "send" ]
    }, {
        title: "far://share-square",
        searchTerms: [ "social", "send" ]
    }, {
        title: "fas://shekel-sign",
        searchTerms: [ "ils", "ils" ]
    }, {
        title: "fas://shield-alt",
        searchTerms: [ "shield" ]
    }, {
        title: "fas://ship",
        searchTerms: [ "boat", "sea" ]
    }, {
        title: "fas://shipping-fast",
        searchTerms: []
    }, {
        title: "fab://shirtsinbulk",
        searchTerms: []
    }, {
        title: "fas://shopping-bag",
        searchTerms: []
    }, {
        title: "fas://shopping-basket",
        searchTerms: []
    }, {
        title: "fas://shopping-cart",
        searchTerms: [ "checkout", "buy", "purchase", "payment" ]
    }, {
        title: "fas://shower",
        searchTerms: []
    }, {
        title: "fas://sign",
        searchTerms: []
    }, {
        title: "fas://sign-in-alt",
        searchTerms: [ "enter", "join", "log in", "login", "sign up", "sign in", "signin", "signup", "arrow", "sign-in" ]
    }, {
        title: "fas://sign-language",
        searchTerms: []
    }, {
        title: "fas://sign-out-alt",
        searchTerms: [ "log out", "logout", "leave", "exit", "arrow", "sign-out" ]
    }, {
        title: "fas://signal",
        searchTerms: [ "graph", "bars", "status", "online" ]
    }, {
        title: "fab://simplybuilt",
        searchTerms: []
    }, {
        title: "fab://sistrix",
        searchTerms: []
    }, {
        title: "fas://sitemap",
        searchTerms: [ "directory", "hierarchy", "organization" ]
    }, {
        title: "fab://skyatlas",
        searchTerms: []
    }, {
        title: "fab://skype",
        searchTerms: []
    }, {
        title: "fab://slack",
        searchTerms: [ "hashtag", "anchor", "hash" ]
    }, {
        title: "fab://slack-hash",
        searchTerms: [ "hashtag", "anchor", "hash" ]
    }, {
        title: "fas://sliders-h",
        searchTerms: [ "settings", "sliders" ]
    }, {
        title: "fab://slideshare",
        searchTerms: []
    }, {
        title: "fas://smile",
        searchTerms: [ "face", "emoticon", "happy", "approve", "satisfied", "rating" ]
    }, {
        title: "far://smile",
        searchTerms: [ "face", "emoticon", "happy", "approve", "satisfied", "rating" ]
    }, {
        title: "fas://smoking",
        searchTerms: [ "smoking status", "cigarette", "nicotine" ]
    }, {
        title: "fab://snapchat",
        searchTerms: []
    }, {
        title: "fab://snapchat-ghost",
        searchTerms: []
    }, {
        title: "fab://snapchat-square",
        searchTerms: []
    }, {
        title: "fas://snowflake",
        searchTerms: []
    }, {
        title: "far://snowflake",
        searchTerms: []
    }, {
        title: "fas://sort",
        searchTerms: [ "order" ]
    }, {
        title: "fas://sort-alpha-down",
        searchTerms: [ "sort-alpha-asc" ]
    }, {
        title: "fas://sort-alpha-up",
        searchTerms: [ "sort-alpha-desc" ]
    }, {
        title: "fas://sort-amount-down",
        searchTerms: [ "sort-amount-asc" ]
    }, {
        title: "fas://sort-amount-up",
        searchTerms: [ "sort-amount-desc" ]
    }, {
        title: "fas://sort-down",
        searchTerms: [ "arrow", "descending", "sort-desc" ]
    }, {
        title: "fas://sort-numeric-down",
        searchTerms: [ "numbers", "sort-numeric-asc" ]
    }, {
        title: "fas://sort-numeric-up",
        searchTerms: [ "numbers", "sort-numeric-desc" ]
    }, {
        title: "fas://sort-up",
        searchTerms: [ "arrow", "ascending", "sort-asc" ]
    }, {
        title: "fab://soundcloud",
        searchTerms: []
    }, {
        title: "fas://space-shuttle",
        searchTerms: [ "nasa", "astronaut", "rocket", "machine", "transportation" ]
    }, {
        title: "fab://speakap",
        searchTerms: []
    }, {
        title: "fas://spinner",
        searchTerms: [ "loading", "progress" ]
    }, {
        title: "fab://spotify",
        searchTerms: []
    }, {
        title: "fas://square",
        searchTerms: [ "block", "box" ]
    }, {
        title: "far://square",
        searchTerms: [ "block", "box" ]
    }, {
        title: "fas://square-full",
        searchTerms: []
    }, {
        title: "fab://stack-exchange",
        searchTerms: []
    }, {
        title: "fab://stack-overflow",
        searchTerms: []
    }, {
        title: "fas://star",
        searchTerms: [ "award", "achievement", "night", "rating", "score", "favorite" ]
    }, {
        title: "far://star",
        searchTerms: [ "award", "achievement", "night", "rating", "score", "favorite" ]
    }, {
        title: "fas://star-half",
        searchTerms: [ "award", "achievement", "rating", "score", "star-half-empty", "star-half-full" ]
    }, {
        title: "far://star-half",
        searchTerms: [ "award", "achievement", "rating", "score", "star-half-empty", "star-half-full" ]
    }, {
        title: "fab://staylinked",
        searchTerms: []
    }, {
        title: "fab://steam",
        searchTerms: []
    }, {
        title: "fab://steam-square",
        searchTerms: []
    }, {
        title: "fab://steam-symbol",
        searchTerms: []
    }, {
        title: "fas://step-backward",
        searchTerms: [ "rewind", "previous", "beginning", "start", "first" ]
    }, {
        title: "fas://step-forward",
        searchTerms: [ "next", "end", "last" ]
    }, {
        title: "fas://stethoscope",
        searchTerms: []
    }, {
        title: "fab://sticker-mule",
        searchTerms: []
    }, {
        title: "fas://sticky-note",
        searchTerms: []
    }, {
        title: "far://sticky-note",
        searchTerms: []
    }, {
        title: "fas://stop",
        searchTerms: [ "block", "box", "square" ]
    }, {
        title: "fas://stop-circle",
        searchTerms: []
    }, {
        title: "far://stop-circle",
        searchTerms: []
    }, {
        title: "fas://stopwatch",
        searchTerms: [ "time" ]
    }, {
        title: "fab://strava",
        searchTerms: []
    }, {
        title: "fas://street-view",
        searchTerms: [ "map" ]
    }, {
        title: "fas://strikethrough",
        searchTerms: []
    }, {
        title: "fab://stripe",
        searchTerms: []
    }, {
        title: "fab://stripe-s",
        searchTerms: []
    }, {
        title: "fab://studiovinari",
        searchTerms: []
    }, {
        title: "fab://stumbleupon",
        searchTerms: []
    }, {
        title: "fab://stumbleupon-circle",
        searchTerms: []
    }, {
        title: "fas://subscript",
        searchTerms: []
    }, {
        title: "fas://subway",
        searchTerms: [ "vehicle", "train", "railway", "machine", "transportation" ]
    }, {
        title: "fas://suitcase",
        searchTerms: [ "trip", "luggage", "travel", "move", "baggage" ]
    }, {
        title: "fas://sun",
        searchTerms: [ "weather", "contrast", "lighter", "brighten", "day" ]
    }, {
        title: "far://sun",
        searchTerms: [ "weather", "contrast", "lighter", "brighten", "day" ]
    }, {
        title: "fab://superpowers",
        searchTerms: []
    }, {
        title: "fas://superscript",
        searchTerms: [ "exponential" ]
    }, {
        title: "fab://supple",
        searchTerms: []
    }, {
        title: "fas://sync",
        searchTerms: [ "reload", "refresh", "exchange", "swap" ]
    }, {
        title: "fas://sync-alt",
        searchTerms: [ "reload", "refresh" ]
    }, {
        title: "fas://syringe",
        searchTerms: [ "immunizations", "needle" ]
    }, {
        title: "fas://table",
        searchTerms: [ "data", "excel", "spreadsheet" ]
    }, {
        title: "fas://table-tennis",
        searchTerms: []
    }, {
        title: "fas://tablet",
        searchTerms: [ "device", "screen", "apple", "ipad", "kindle" ]
    }, {
        title: "fas://tablet-alt",
        searchTerms: [ "device", "screen", "apple", "ipad", "kindle" ]
    }, {
        title: "fas://tablets",
        searchTerms: [ "medicine", "drugs" ]
    }, {
        title: "fas://tachometer-alt",
        searchTerms: [ "tachometer", "dashboard" ]
    }, {
        title: "fas://tag",
        searchTerms: [ "label" ]
    }, {
        title: "fas://tags",
        searchTerms: [ "labels" ]
    }, {
        title: "fas://tape",
        searchTerms: []
    }, {
        title: "fas://tasks",
        searchTerms: [ "progress", "loading", "downloading", "downloads", "settings" ]
    }, {
        title: "fas://taxi",
        searchTerms: [ "vehicle", "machine", "transportation", "cab", "cabbie", "car", "uber", "lyft", "car service" ]
    }, {
        title: "fab://telegram",
        searchTerms: []
    }, {
        title: "fab://telegram-plane",
        searchTerms: []
    }, {
        title: "fab://tencent-weibo",
        searchTerms: []
    }, {
        title: "fas://terminal",
        searchTerms: [ "command", "prompt", "code", "console" ]
    }, {
        title: "fas://text-height",
        searchTerms: []
    }, {
        title: "fas://text-width",
        searchTerms: []
    }, {
        title: "fas://th",
        searchTerms: [ "blocks", "squares", "boxes", "grid" ]
    }, {
        title: "fas://th-large",
        searchTerms: [ "blocks", "squares", "boxes", "grid" ]
    }, {
        title: "fas://th-list",
        searchTerms: [ "ul", "ol", "checklist", "finished", "completed", "done", "todo" ]
    }, {
        title: "fab://themeisle",
        searchTerms: []
    }, {
        title: "fas://thermometer",
        searchTerms: [ "temperature", "fever" ]
    }, {
        title: "fas://thermometer-empty",
        searchTerms: [ "status" ]
    }, {
        title: "fas://thermometer-full",
        searchTerms: [ "status" ]
    }, {
        title: "fas://thermometer-half",
        searchTerms: [ "status" ]
    }, {
        title: "fas://thermometer-quarter",
        searchTerms: [ "status" ]
    }, {
        title: "fas://thermometer-three-quarters",
        searchTerms: [ "status" ]
    }, {
        title: "fas://thumbs-down",
        searchTerms: [ "dislike", "disapprove", "disagree", "hand", "thumbs-o-down" ]
    }, {
        title: "far://thumbs-down",
        searchTerms: [ "dislike", "disapprove", "disagree", "hand", "thumbs-o-down" ]
    }, {
        title: "fas://thumbs-up",
        searchTerms: [ "like", "favorite", "approve", "agree", "hand", "thumbs-o-up", "success", "yes", "ok", "okay", "you got it dude" ]
    }, {
        title: "far://thumbs-up",
        searchTerms: [ "like", "favorite", "approve", "agree", "hand", "thumbs-o-up", "success", "yes", "ok", "okay", "you got it dude" ]
    }, {
        title: "fas://thumbtack",
        searchTerms: [ "marker", "pin", "location", "coordinates", "thumb-tack" ]
    }, {
        title: "fas://ticket-alt",
        searchTerms: [ "ticket" ]
    }, {
        title: "fas://times",
        searchTerms: [ "close", "exit", "x", "cross", "error", "problem", "notification", "notify", "notice", "wrong", "incorrect" ]
    }, {
        title: "fas://times-circle",
        searchTerms: [ "close", "exit", "x", "cross", "problem", "notification", "notify", "notice", "wrong", "incorrect" ]
    }, {
        title: "far://times-circle",
        searchTerms: [ "close", "exit", "x", "cross", "problem", "notification", "notify", "notice", "wrong", "incorrect" ]
    }, {
        title: "fas://tint",
        searchTerms: [ "raindrop", "waterdrop", "drop", "droplet" ]
    }, {
        title: "fas://toggle-off",
        searchTerms: [ "switch" ]
    }, {
        title: "fas://toggle-on",
        searchTerms: [ "switch" ]
    }, {
        title: "fas://trademark",
        searchTerms: []
    }, {
        title: "fas://train",
        searchTerms: [ "bullet", "locomotive", "railway" ]
    }, {
        title: "fas://transgender",
        searchTerms: [ "intersex" ]
    }, {
        title: "fas://transgender-alt",
        searchTerms: []
    }, {
        title: "fas://trash",
        searchTerms: [ "garbage", "delete", "remove", "hide" ]
    }, {
        title: "fas://trash-alt",
        searchTerms: [ "garbage", "delete", "remove", "hide", "trash", "trash-o" ]
    }, {
        title: "far://trash-alt",
        searchTerms: [ "garbage", "delete", "remove", "hide", "trash", "trash-o" ]
    }, {
        title: "fas://tree",
        searchTerms: []
    }, {
        title: "fab://trello",
        searchTerms: []
    }, {
        title: "fab://tripadvisor",
        searchTerms: []
    }, {
        title: "fas://trophy",
        searchTerms: [ "award", "achievement", "cup", "winner", "game" ]
    }, {
        title: "fas://truck",
        searchTerms: [ "shipping", "delivery" ]
    }, {
        title: "fas://truck-loading",
        searchTerms: []
    }, {
        title: "fas://truck-moving",
        searchTerms: []
    }, {
        title: "fas://tty",
        searchTerms: []
    }, {
        title: "fab://tumblr",
        searchTerms: []
    }, {
        title: "fab://tumblr-square",
        searchTerms: []
    }, {
        title: "fas://tv",
        searchTerms: [ "display", "computer", "monitor", "television" ]
    }, {
        title: "fab://twitch",
        searchTerms: []
    }, {
        title: "fab://twitter",
        searchTerms: [ "tweet", "social network" ]
    }, {
        title: "fab://twitter-square",
        searchTerms: [ "tweet", "social network" ]
    }, {
        title: "fab://typo3",
        searchTerms: []
    }, {
        title: "fab://uber",
        searchTerms: []
    }, {
        title: "fab://uikit",
        searchTerms: []
    }, {
        title: "fas://umbrella",
        searchTerms: []
    }, {
        title: "fas://underline",
        searchTerms: []
    }, {
        title: "fas://undo",
        searchTerms: [ "back", "exchange", "swap", "return", "control z", "oops" ]
    }, {
        title: "fas://undo-alt",
        searchTerms: [ "back", "exchange", "swap", "return", "control z", "oops" ]
    }, {
        title: "fab://uniregistry",
        searchTerms: []
    }, {
        title: "fas://universal-access",
        searchTerms: []
    }, {
        title: "fas://university",
        searchTerms: [ "bank", "institution" ]
    }, {
        title: "fas://unlink",
        searchTerms: [ "remove", "chain", "chain-broken" ]
    }, {
        title: "fas://unlock",
        searchTerms: [ "protect", "admin", "password", "lock" ]
    }, {
        title: "fas://unlock-alt",
        searchTerms: [ "protect", "admin", "password", "lock" ]
    }, {
        title: "fab://untappd",
        searchTerms: []
    }, {
        title: "fas://upload",
        searchTerms: [ "import" ]
    }, {
        title: "fab://usb",
        searchTerms: []
    }, {
        title: "fas://user",
        searchTerms: [ "person", "man", "head", "profile", "account" ]
    }, {
        title: "far://user",
        searchTerms: [ "person", "man", "head", "profile", "account" ]
    }, {
        title: "fas://user-circle",
        searchTerms: [ "person", "man", "head", "profile", "account" ]
    }, {
        title: "far://user-circle",
        searchTerms: [ "person", "man", "head", "profile", "account" ]
    }, {
        title: "fas://user-md",
        searchTerms: [ "doctor", "profile", "medical", "nurse", "job", "occupation" ]
    }, {
        title: "fas://user-plus",
        searchTerms: [ "sign up", "signup" ]
    }, {
        title: "fas://user-secret",
        searchTerms: [ "whisper", "spy", "incognito", "privacy" ]
    }, {
        title: "fas://user-times",
        searchTerms: []
    }, {
        title: "fas://users",
        searchTerms: [ "people", "profiles", "persons" ]
    }, {
        title: "fab://ussunnah",
        searchTerms: []
    }, {
        title: "fas://utensil-spoon",
        searchTerms: [ "spoon" ]
    }, {
        title: "fas://utensils",
        searchTerms: [ "food", "restaurant", "spoon", "knife", "dinner", "eat", "cutlery" ]
    }, {
        title: "fab://vaadin",
        searchTerms: []
    }, {
        title: "fas://venus",
        searchTerms: [ "female" ]
    }, {
        title: "fas://venus-double",
        searchTerms: []
    }, {
        title: "fas://venus-mars",
        searchTerms: []
    }, {
        title: "fab://viacoin",
        searchTerms: []
    }, {
        title: "fab://viadeo",
        searchTerms: []
    }, {
        title: "fab://viadeo-square",
        searchTerms: []
    }, {
        title: "fas://vial",
        searchTerms: [ "test tube" ]
    }, {
        title: "fas://vials",
        searchTerms: [ "lab results", "test tubes" ]
    }, {
        title: "fab://viber",
        searchTerms: []
    }, {
        title: "fas://video",
        searchTerms: [ "film", "movie", "record", "camera", "video-camera" ]
    }, {
        title: "fas://video-slash",
        searchTerms: []
    }, {
        title: "fab://vimeo",
        searchTerms: []
    }, {
        title: "fab://vimeo-square",
        searchTerms: []
    }, {
        title: "fab://vimeo-v",
        searchTerms: [ "vimeo" ]
    }, {
        title: "fab://vine",
        searchTerms: []
    }, {
        title: "fab://vk",
        searchTerms: []
    }, {
        title: "fab://vnv",
        searchTerms: []
    }, {
        title: "fas://volleyball-ball",
        searchTerms: []
    }, {
        title: "fas://volume-down",
        searchTerms: [ "audio", "lower", "quieter", "sound", "music", "speaker" ]
    }, {
        title: "fas://volume-off",
        searchTerms: [ "audio", "mute", "sound", "music" ]
    }, {
        title: "fas://volume-up",
        searchTerms: [ "audio", "higher", "louder", "sound", "music", "speaker" ]
    }, {
        title: "fab://vuejs",
        searchTerms: []
    }, {
        title: "fas://warehouse",
        searchTerms: []
    }, {
        title: "fab://weibo",
        searchTerms: []
    }, {
        title: "fas://weight",
        searchTerms: [ "scale" ]
    }, {
        title: "fab://weixin",
        searchTerms: []
    }, {
        title: "fab://whatsapp",
        searchTerms: []
    }, {
        title: "fab://whatsapp-square",
        searchTerms: []
    }, {
        title: "fas://wheelchair",
        searchTerms: [ "handicap", "person" ]
    }, {
        title: "fab://whmcs",
        searchTerms: []
    }, {
        title: "fas://wifi",
        searchTerms: []
    }, {
        title: "fab://wikipedia-w",
        searchTerms: []
    }, {
        title: "fas://window-close",
        searchTerms: []
    }, {
        title: "far://window-close",
        searchTerms: []
    }, {
        title: "fas://window-maximize",
        searchTerms: []
    }, {
        title: "far://window-maximize",
        searchTerms: []
    }, {
        title: "fas://window-minimize",
        searchTerms: []
    }, {
        title: "far://window-minimize",
        searchTerms: []
    }, {
        title: "fas://window-restore",
        searchTerms: []
    }, {
        title: "far://window-restore",
        searchTerms: []
    }, {
        title: "fab://windows",
        searchTerms: [ "microsoft" ]
    }, {
        title: "fas://wine-glass",
        searchTerms: []
    }, {
        title: "fas://won-sign",
        searchTerms: [ "krw", "krw" ]
    }, {
        title: "fab://wordpress",
        searchTerms: []
    }, {
        title: "fab://wordpress-simple",
        searchTerms: []
    }, {
        title: "fab://wpbeginner",
        searchTerms: []
    }, {
        title: "fab://wpexplorer",
        searchTerms: []
    }, {
        title: "fab://wpforms",
        searchTerms: []
    }, {
        title: "fas://wrench",
        searchTerms: [ "settings", "fix", "update", "spanner", "tool" ]
    }, {
        title: "fas://x-ray",
        searchTerms: [ "radiological images", "radiology" ]
    }, {
        title: "fab://xbox",
        searchTerms: []
    }, {
        title: "fab://xing",
        searchTerms: []
    }, {
        title: "fab://xing-square",
        searchTerms: []
    }, {
        title: "fab://y-combinator",
        searchTerms: []
    }, {
        title: "fab://yahoo",
        searchTerms: []
    }, {
        title: "fab://yandex",
        searchTerms: []
    }, {
        title: "fab://yandex-international",
        searchTerms: []
    }, {
        title: "fab://yelp",
        searchTerms: []
    }, {
        title: "fas://yen-sign",
        searchTerms: [ "jpy", "jpy" ]
    }, {
        title: "fab://yoast",
        searchTerms: []
    }, {
        title: "fab://youtube",
        searchTerms: [ "video", "film", "youtube-play", "youtube-square" ]
    }, {
        title: "fab://youtube-square",
        searchTerms: []
    } ]
};

var FA5iconinfo = FA5iconinfolong["icons"];

var FA4iconinfolong = {
    icons: [ {
        title: "fa://glass",
        searchTerms: [ "martini", "drink", "bar", "alcohol", "liquor" ]
    }, {
        title: "fa://music",
        searchTerms: [ "note", "sound" ]
    }, {
        title: "fa://search",
        searchTerms: [ "magnify", "zoom", "enlarge", "bigger" ]
    }, {
        title: "fa://envelope-o",
        searchTerms: [ "email", "support", "e-mail", "letter", "mail", "notification" ]
    }, {
        title: "fa://heart",
        searchTerms: [ "love", "like", "favorite" ]
    }, {
        title: "fa://star",
        searchTerms: [ "award", "achievement", "night", "rating", "score", "favorite" ]
    }, {
        title: "fa://star-o",
        searchTerms: [ "award", "achievement", "night", "rating", "score", "favorite" ]
    }, {
        title: "fa://user",
        searchTerms: [ "person", "man", "head", "profile" ]
    }, {
        title: "fa://film",
        searchTerms: [ "movie" ]
    }, {
        title: "fa://th-large",
        searchTerms: [ "blocks", "squares", "boxes", "grid" ]
    }, {
        title: "fa://th",
        searchTerms: [ "blocks", "squares", "boxes", "grid" ]
    }, {
        title: "fa://th-list",
        searchTerms: [ "ul", "ol", "checklist", "finished", "completed", "done", "todo" ]
    }, {
        title: "fa://check",
        searchTerms: [ "checkmark", "done", "todo", "agree", "accept", "confirm", "tick", "ok" ]
    }, {
        title: "fa://times",
        searchTerms: [ "close", "exit", "x", "cross" ]
    }, {
        title: "fa://search-plus",
        searchTerms: [ "magnify", "zoom", "enlarge", "bigger" ]
    }, {
        title: "fa://search-minus",
        searchTerms: [ "magnify", "minify", "zoom", "smaller" ]
    }, {
        title: "fa://power-off",
        searchTerms: [ "on" ]
    }, {
        title: "fa://signal",
        searchTerms: [ "graph", "bars" ]
    }, {
        title: "fa://cog",
        searchTerms: [ "settings" ]
    }, {
        title: "fa://trash-o",
        searchTerms: [ "garbage", "delete", "remove", "trash", "hide" ]
    }, {
        title: "fa://home",
        searchTerms: [ "main", "house" ]
    }, {
        title: "fa://file-o",
        searchTerms: [ "new", "page", "pdf", "document" ]
    }, {
        title: "fa://clock-o",
        searchTerms: [ "watch", "timer", "late", "timestamp" ]
    }, {
        title: "fa://road",
        searchTerms: [ "street" ]
    }, {
        title: "fa://download",
        searchTerms: [ "import" ]
    }, {
        title: "fa://arrow-circle-o-down",
        searchTerms: [ "download" ]
    }, {
        title: "fa://arrow-circle-o-up",
        searchTerms: []
    }, {
        title: "fa://inbox",
        searchTerms: []
    }, {
        title: "fa://play-circle-o",
        searchTerms: []
    }, {
        title: "fa://repeat",
        searchTerms: [ "redo", "forward" ]
    }, {
        title: "fa://refresh",
        searchTerms: [ "reload", "sync" ]
    }, {
        title: "fa://list-alt",
        searchTerms: [ "ul", "ol", "checklist", "finished", "completed", "done", "todo" ]
    }, {
        title: "fa://lock",
        searchTerms: [ "protect", "admin", "security" ]
    }, {
        title: "fa://flag",
        searchTerms: [ "report", "notification", "notify" ]
    }, {
        title: "fa://headphones",
        searchTerms: [ "sound", "listen", "music", "audio" ]
    }, {
        title: "fa://volume-off",
        searchTerms: [ "audio", "mute", "sound", "music" ]
    }, {
        title: "fa://volume-down",
        searchTerms: [ "audio", "lower", "quieter", "sound", "music" ]
    }, {
        title: "fa://volume-up",
        searchTerms: [ "audio", "higher", "louder", "sound", "music" ]
    }, {
        title: "fa://qrcode",
        searchTerms: [ "scan" ]
    }, {
        title: "fa://barcode",
        searchTerms: [ "scan" ]
    }, {
        title: "fa://tag",
        searchTerms: [ "label" ]
    }, {
        title: "fa://tags",
        searchTerms: [ "labels" ]
    }, {
        title: "fa://book",
        searchTerms: [ "read", "documentation" ]
    }, {
        title: "fa://bookmark",
        searchTerms: [ "save" ]
    }, {
        title: "fa://print",
        searchTerms: []
    }, {
        title: "fa://camera",
        searchTerms: [ "photo", "picture", "record" ]
    }, {
        title: "fa://font",
        searchTerms: [ "text" ]
    }, {
        title: "fa://bold",
        searchTerms: []
    }, {
        title: "fa://italic",
        searchTerms: [ "italics" ]
    }, {
        title: "fa://text-height",
        searchTerms: []
    }, {
        title: "fa://text-width",
        searchTerms: []
    }, {
        title: "fa://align-left",
        searchTerms: [ "text" ]
    }, {
        title: "fa://align-center",
        searchTerms: [ "middle", "text" ]
    }, {
        title: "fa://align-right",
        searchTerms: [ "text" ]
    }, {
        title: "fa://align-justify",
        searchTerms: [ "text" ]
    }, {
        title: "fa://list",
        searchTerms: [ "ul", "ol", "checklist", "finished", "completed", "done", "todo" ]
    }, {
        title: "fa://outdent",
        searchTerms: []
    }, {
        title: "fa://indent",
        searchTerms: []
    }, {
        title: "fa://video-camera",
        searchTerms: [ "film", "movie", "record" ]
    }, {
        title: "fa://picture-o",
        searchTerms: []
    }, {
        title: "fa://pencil",
        searchTerms: [ "write", "edit", "update" ]
    }, {
        title: "fa://map-marker",
        searchTerms: [ "map", "pin", "location", "coordinates", "localize", "address", "travel", "where", "place" ]
    }, {
        title: "fa://adjust",
        searchTerms: [ "contrast" ]
    }, {
        title: "fa://tint",
        searchTerms: [ "raindrop", "waterdrop", "drop", "droplet" ]
    }, {
        title: "fa://pencil-square-o",
        searchTerms: [ "write", "edit", "update" ]
    }, {
        title: "fa://share-square-o",
        searchTerms: [ "social", "send", "arrow" ]
    }, {
        title: "fa://check-square-o",
        searchTerms: [ "todo", "done", "agree", "accept", "confirm", "ok" ]
    }, {
        title: "fa://arrows",
        searchTerms: [ "move", "reorder", "resize" ]
    }, {
        title: "fa://step-backward",
        searchTerms: [ "rewind", "previous", "beginning", "start", "first" ]
    }, {
        title: "fa://fast-backward",
        searchTerms: [ "rewind", "previous", "beginning", "start", "first" ]
    }, {
        title: "fa://backward",
        searchTerms: [ "rewind", "previous" ]
    }, {
        title: "fa://play",
        searchTerms: [ "start", "playing", "music", "sound" ]
    }, {
        title: "fa://pause",
        searchTerms: [ "wait" ]
    }, {
        title: "fa://stop",
        searchTerms: [ "block", "box", "square" ]
    }, {
        title: "fa://forward",
        searchTerms: [ "forward", "next" ]
    }, {
        title: "fa://fast-forward",
        searchTerms: [ "next", "end", "last" ]
    }, {
        title: "fa://step-forward",
        searchTerms: [ "next", "end", "last" ]
    }, {
        title: "fa://eject",
        searchTerms: []
    }, {
        title: "fa://chevron-left",
        searchTerms: [ "bracket", "previous", "back" ]
    }, {
        title: "fa://chevron-right",
        searchTerms: [ "bracket", "next", "forward" ]
    }, {
        title: "fa://plus-circle",
        searchTerms: [ "add", "new", "create", "expand" ]
    }, {
        title: "fa://minus-circle",
        searchTerms: [ "delete", "remove", "trash", "hide" ]
    }, {
        title: "fa://times-circle",
        searchTerms: [ "close", "exit", "x" ]
    }, {
        title: "fa://check-circle",
        searchTerms: [ "todo", "done", "agree", "accept", "confirm", "ok" ]
    }, {
        title: "fa://question-circle",
        searchTerms: [ "help", "information", "unknown", "support" ]
    }, {
        title: "fa://info-circle",
        searchTerms: [ "help", "information", "more", "details" ]
    }, {
        title: "fa://crosshairs",
        searchTerms: [ "picker" ]
    }, {
        title: "fa://times-circle-o",
        searchTerms: [ "close", "exit", "x" ]
    }, {
        title: "fa://check-circle-o",
        searchTerms: [ "todo", "done", "agree", "accept", "confirm", "ok" ]
    }, {
        title: "fa://ban",
        searchTerms: [ "delete", "remove", "trash", "hide", "block", "stop", "abort", "cancel" ]
    }, {
        title: "fa://arrow-left",
        searchTerms: [ "previous", "back" ]
    }, {
        title: "fa://arrow-right",
        searchTerms: [ "next", "forward" ]
    }, {
        title: "fa://arrow-up",
        searchTerms: []
    }, {
        title: "fa://arrow-down",
        searchTerms: [ "download" ]
    }, {
        title: "fa://share",
        searchTerms: []
    }, {
        title: "fa://expand",
        searchTerms: [ "enlarge", "bigger", "resize" ]
    }, {
        title: "fa://compress",
        searchTerms: [ "collapse", "combine", "contract", "merge", "smaller" ]
    }, {
        title: "fa://plus",
        searchTerms: [ "add", "new", "create", "expand" ]
    }, {
        title: "fa://minus",
        searchTerms: [ "hide", "minify", "delete", "remove", "trash", "hide", "collapse" ]
    }, {
        title: "fa://asterisk",
        searchTerms: [ "details" ]
    }, {
        title: "fa://exclamation-circle",
        searchTerms: [ "warning", "error", "problem", "notification", "alert" ]
    }, {
        title: "fa://gift",
        searchTerms: [ "present" ]
    }, {
        title: "fa://leaf",
        searchTerms: [ "eco", "nature", "plant" ]
    }, {
        title: "fa://fire",
        searchTerms: [ "flame", "hot", "popular" ]
    }, {
        title: "fa://eye",
        searchTerms: [ "show", "visible", "views" ]
    }, {
        title: "fa://eye-slash",
        searchTerms: [ "toggle", "show", "hide", "visible", "visiblity", "views" ]
    }, {
        title: "fa://exclamation-triangle",
        searchTerms: [ "warning", "error", "problem", "notification", "alert" ]
    }, {
        title: "fa://plane",
        searchTerms: [ "travel", "trip", "location", "destination", "airplane", "fly", "mode" ]
    }, {
        title: "fa://calendar",
        searchTerms: [ "date", "time", "when", "event" ]
    }, {
        title: "fa://random",
        searchTerms: [ "sort", "shuffle" ]
    }, {
        title: "fa://comment",
        searchTerms: [ "speech", "notification", "note", "chat", "bubble", "feedback", "message", "texting", "sms", "conversation" ]
    }, {
        title: "fa://magnet",
        searchTerms: []
    }, {
        title: "fa://chevron-up",
        searchTerms: []
    }, {
        title: "fa://chevron-down",
        searchTerms: []
    }, {
        title: "fa://retweet",
        searchTerms: [ "refresh", "reload", "share" ]
    }, {
        title: "fa://shopping-cart",
        searchTerms: [ "checkout", "buy", "purchase", "payment" ]
    }, {
        title: "fa://folder",
        searchTerms: []
    }, {
        title: "fa://folder-open",
        searchTerms: []
    }, {
        title: "fa://arrows-v",
        searchTerms: [ "resize" ]
    }, {
        title: "fa://arrows-h",
        searchTerms: [ "resize" ]
    }, {
        title: "fa://bar-chart",
        searchTerms: [ "graph", "analytics" ]
    }, {
        title: "fa://twitter-square",
        searchTerms: [ "tweet", "social network" ]
    }, {
        title: "fa://facebook-square",
        searchTerms: [ "social network" ]
    }, {
        title: "fa://camera-retro",
        searchTerms: [ "photo", "picture", "record" ]
    }, {
        title: "fa://key",
        searchTerms: [ "unlock", "password" ]
    }, {
        title: "fa://cogs",
        searchTerms: [ "settings" ]
    }, {
        title: "fa://comments",
        searchTerms: [ "speech", "notification", "note", "chat", "bubble", "feedback", "message", "texting", "sms", "conversation" ]
    }, {
        title: "fa://thumbs-o-up",
        searchTerms: [ "like", "approve", "favorite", "agree", "hand" ]
    }, {
        title: "fa://thumbs-o-down",
        searchTerms: [ "dislike", "disapprove", "disagree", "hand" ]
    }, {
        title: "fa://star-half",
        searchTerms: [ "award", "achievement", "rating", "score" ]
    }, {
        title: "fa://heart-o",
        searchTerms: [ "love", "like", "favorite" ]
    }, {
        title: "fa://sign-out",
        searchTerms: [ "log out", "logout", "leave", "exit", "arrow" ]
    }, {
        title: "fa://linkedin-square",
        searchTerms: []
    }, {
        title: "fa://thumb-tack",
        searchTerms: [ "marker", "pin", "location", "coordinates" ]
    }, {
        title: "fa://external-link",
        searchTerms: [ "open", "new" ]
    }, {
        title: "fa://sign-in",
        searchTerms: [ "enter", "join", "log in", "login", "sign up", "sign in", "signin", "signup", "arrow" ]
    }, {
        title: "fa://trophy",
        searchTerms: [ "award", "achievement", "cup", "winner", "game" ]
    }, {
        title: "fa://github-square",
        searchTerms: [ "octocat" ]
    }, {
        title: "fa://upload",
        searchTerms: [ "import" ]
    }, {
        title: "fa://lemon-o",
        searchTerms: [ "food" ]
    }, {
        title: "fa://phone",
        searchTerms: [ "call", "voice", "number", "support", "earphone", "telephone" ]
    }, {
        title: "fa://square-o",
        searchTerms: [ "block", "square", "box" ]
    }, {
        title: "fa://bookmark-o",
        searchTerms: [ "save" ]
    }, {
        title: "fa://phone-square",
        searchTerms: [ "call", "voice", "number", "support", "telephone" ]
    }, {
        title: "fa://twitter",
        searchTerms: [ "tweet", "social network" ]
    }, {
        title: "fa://facebook",
        searchTerms: [ "social network" ]
    }, {
        title: "fa://github",
        searchTerms: [ "octocat" ]
    }, {
        title: "fa://unlock",
        searchTerms: [ "protect", "admin", "password", "lock" ]
    }, {
        title: "fa://credit-card",
        searchTerms: [ "money", "buy", "debit", "checkout", "purchase", "payment" ]
    }, {
        title: "fa://rss",
        searchTerms: [ "blog" ]
    }, {
        title: "fa://hdd-o",
        searchTerms: [ "harddrive", "hard drive", "storage", "save" ]
    }, {
        title: "fa://bullhorn",
        searchTerms: [ "announcement", "share", "broadcast", "louder", "megaphone" ]
    }, {
        title: "fa://bell",
        searchTerms: [ "alert", "reminder", "notification" ]
    }, {
        title: "fa://certificate",
        searchTerms: [ "badge", "star" ]
    }, {
        title: "fa://hand-o-right",
        searchTerms: [ "point", "right", "next", "forward", "finger" ]
    }, {
        title: "fa://hand-o-left",
        searchTerms: [ "point", "left", "previous", "back", "finger" ]
    }, {
        title: "fa://hand-o-up",
        searchTerms: [ "point", "finger" ]
    }, {
        title: "fa://hand-o-down",
        searchTerms: [ "point", "finger" ]
    }, {
        title: "fa://arrow-circle-left",
        searchTerms: [ "previous", "back" ]
    }, {
        title: "fa://arrow-circle-right",
        searchTerms: [ "next", "forward" ]
    }, {
        title: "fa://arrow-circle-up",
        searchTerms: []
    }, {
        title: "fa://arrow-circle-down",
        searchTerms: [ "download" ]
    }, {
        title: "fa://globe",
        searchTerms: [ "world", "planet", "map", "place", "travel", "earth", "global", "translate", "all", "language", "localize", "location", "coordinates", "country" ]
    }, {
        title: "fa://wrench",
        searchTerms: [ "settings", "fix", "update", "spanner" ]
    }, {
        title: "fa://tasks",
        searchTerms: [ "progress", "loading", "downloading", "downloads", "settings" ]
    }, {
        title: "fa://filter",
        searchTerms: [ "funnel", "options" ]
    }, {
        title: "fa://briefcase",
        searchTerms: [ "work", "business", "office", "luggage", "bag" ]
    }, {
        title: "fa://arrows-alt",
        searchTerms: [ "expand", "enlarge", "fullscreen", "bigger", "move", "reorder", "resize", "arrow" ]
    }, {
        title: "fa://users",
        searchTerms: [ "people", "profiles", "persons" ]
    }, {
        title: "fa://link",
        searchTerms: [ "chain" ]
    }, {
        title: "fa://cloud",
        searchTerms: [ "save" ]
    }, {
        title: "fa://flask",
        searchTerms: [ "science", "beaker", "experimental", "labs" ]
    }, {
        title: "fa://scissors",
        searchTerms: []
    }, {
        title: "fa://files-o",
        searchTerms: [ "duplicate", "clone", "copy" ]
    }, {
        title: "fa://paperclip",
        searchTerms: [ "attachment" ]
    }, {
        title: "fa://floppy-o",
        searchTerms: []
    }, {
        title: "fa://square",
        searchTerms: [ "block", "box" ]
    }, {
        title: "fa://bars",
        searchTerms: [ "menu", "drag", "reorder", "settings", "list", "ul", "ol", "checklist", "todo", "list", "hamburger" ]
    }, {
        title: "fa://list-ul",
        searchTerms: [ "ul", "ol", "checklist", "todo", "list" ]
    }, {
        title: "fa://list-ol",
        searchTerms: [ "ul", "ol", "checklist", "list", "todo", "list", "numbers" ]
    }, {
        title: "fa://strikethrough",
        searchTerms: []
    }, {
        title: "fa://underline",
        searchTerms: []
    }, {
        title: "fa://table",
        searchTerms: [ "data", "excel", "spreadsheet" ]
    }, {
        title: "fa://magic",
        searchTerms: [ "wizard", "automatic", "autocomplete" ]
    }, {
        title: "fa://truck",
        searchTerms: [ "shipping" ]
    }, {
        title: "fa://pinterest",
        searchTerms: []
    }, {
        title: "fa://pinterest-square",
        searchTerms: []
    }, {
        title: "fa://google-plus-square",
        searchTerms: [ "social network" ]
    }, {
        title: "fa://google-plus",
        searchTerms: [ "social network" ]
    }, {
        title: "fa://money",
        searchTerms: [ "cash", "money", "buy", "checkout", "purchase", "payment" ]
    }, {
        title: "fa://caret-down",
        searchTerms: [ "more", "dropdown", "menu", "triangle down", "arrow" ]
    }, {
        title: "fa://caret-up",
        searchTerms: [ "triangle up", "arrow" ]
    }, {
        title: "fa://caret-left",
        searchTerms: [ "previous", "back", "triangle left", "arrow" ]
    }, {
        title: "fa://caret-right",
        searchTerms: [ "next", "forward", "triangle right", "arrow" ]
    }, {
        title: "fa://columns",
        searchTerms: [ "split", "panes" ]
    }, {
        title: "fa://sort",
        searchTerms: [ "order" ]
    }, {
        title: "fa://sort-desc",
        searchTerms: [ "dropdown", "more", "menu", "arrow" ]
    }, {
        title: "fa://sort-asc",
        searchTerms: [ "arrow" ]
    }, {
        title: "fa://envelope",
        searchTerms: [ "email", "e-mail", "letter", "support", "mail", "notification" ]
    }, {
        title: "fa://linkedin",
        searchTerms: []
    }, {
        title: "fa://undo",
        searchTerms: [ "back" ]
    }, {
        title: "fa://gavel",
        searchTerms: []
    }, {
        title: "fa://tachometer",
        searchTerms: []
    }, {
        title: "fa://comment-o",
        searchTerms: [ "speech", "notification", "note", "chat", "bubble", "feedback", "message", "texting", "sms", "conversation" ]
    }, {
        title: "fa://comments-o",
        searchTerms: [ "speech", "notification", "note", "chat", "bubble", "feedback", "message", "texting", "sms", "conversation" ]
    }, {
        title: "fa://bolt",
        searchTerms: [ "lightning", "weather" ]
    }, {
        title: "fa://sitemap",
        searchTerms: [ "directory", "hierarchy", "organization" ]
    }, {
        title: "fa://umbrella",
        searchTerms: []
    }, {
        title: "fa://clipboard",
        searchTerms: [ "copy" ]
    }, {
        title: "fa://lightbulb-o",
        searchTerms: [ "idea", "inspiration" ]
    }, {
        title: "fa://exchange",
        searchTerms: [ "transfer", "arrows", "arrow" ]
    }, {
        title: "fa://cloud-download",
        searchTerms: [ "import" ]
    }, {
        title: "fa://cloud-upload",
        searchTerms: [ "import" ]
    }, {
        title: "fa://user-md",
        searchTerms: [ "doctor", "profile", "medical", "nurse" ]
    }, {
        title: "fa://stethoscope",
        searchTerms: []
    }, {
        title: "fa://suitcase",
        searchTerms: [ "trip", "luggage", "travel", "move", "baggage" ]
    }, {
        title: "fa://bell-o",
        searchTerms: [ "alert", "reminder", "notification" ]
    }, {
        title: "fa://coffee",
        searchTerms: [ "morning", "mug", "breakfast", "tea", "drink", "cafe" ]
    }, {
        title: "fa://cutlery",
        searchTerms: [ "food", "restaurant", "spoon", "knife", "dinner", "eat" ]
    }, {
        title: "fa://file-text-o",
        searchTerms: [ "new", "page", "pdf", "document" ]
    }, {
        title: "fa://building-o",
        searchTerms: [ "work", "business", "apartment", "office", "company" ]
    }, {
        title: "fa://hospital-o",
        searchTerms: [ "building" ]
    }, {
        title: "fa://ambulance",
        searchTerms: [ "vehicle", "support", "help" ]
    }, {
        title: "fa://medkit",
        searchTerms: [ "first aid", "firstaid", "help", "support", "health" ]
    }, {
        title: "fa://fighter-jet",
        searchTerms: [ "fly", "plane", "airplane", "quick", "fast", "travel" ]
    }, {
        title: "fa://beer",
        searchTerms: [ "alcohol", "stein", "drink", "mug", "bar", "liquor" ]
    }, {
        title: "fa://h-square",
        searchTerms: [ "hospital", "hotel" ]
    }, {
        title: "fa://plus-square",
        searchTerms: [ "add", "new", "create", "expand" ]
    }, {
        title: "fa://angle-double-left",
        searchTerms: [ "laquo", "quote", "previous", "back", "arrows" ]
    }, {
        title: "fa://angle-double-right",
        searchTerms: [ "raquo", "quote", "next", "forward", "arrows" ]
    }, {
        title: "fa://angle-double-up",
        searchTerms: [ "arrows" ]
    }, {
        title: "fa://angle-double-down",
        searchTerms: [ "arrows" ]
    }, {
        title: "fa://angle-left",
        searchTerms: [ "previous", "back", "arrow" ]
    }, {
        title: "fa://angle-right",
        searchTerms: [ "next", "forward", "arrow" ]
    }, {
        title: "fa://angle-up",
        searchTerms: [ "arrow" ]
    }, {
        title: "fa://angle-down",
        searchTerms: [ "arrow" ]
    }, {
        title: "fa://desktop",
        searchTerms: [ "monitor", "screen", "desktop", "computer", "demo", "device" ]
    }, {
        title: "fa://laptop",
        searchTerms: [ "demo", "computer", "device" ]
    }, {
        title: "fa://tablet",
        searchTerms: [ "ipad", "device" ]
    }, {
        title: "fa://mobile",
        searchTerms: [ "cell phone", "cellphone", "text", "call", "iphone", "number", "telephone" ]
    }, {
        title: "fa://circle-o",
        searchTerms: []
    }, {
        title: "fa://quote-left",
        searchTerms: []
    }, {
        title: "fa://quote-right",
        searchTerms: []
    }, {
        title: "fa://spinner",
        searchTerms: [ "loading", "progress" ]
    }, {
        title: "fa://circle",
        searchTerms: [ "dot", "notification" ]
    }, {
        title: "fa://reply",
        searchTerms: []
    }, {
        title: "fa://github-alt",
        searchTerms: [ "octocat" ]
    }, {
        title: "fa://folder-o",
        searchTerms: []
    }, {
        title: "fa://folder-open-o",
        searchTerms: []
    }, {
        title: "fa://smile-o",
        searchTerms: [ "face", "emoticon", "happy", "approve", "satisfied", "rating" ]
    }, {
        title: "fa://frown-o",
        searchTerms: [ "face", "emoticon", "sad", "disapprove", "rating" ]
    }, {
        title: "fa://meh-o",
        searchTerms: [ "face", "emoticon", "rating", "neutral" ]
    }, {
        title: "fa://gamepad",
        searchTerms: [ "controller" ]
    }, {
        title: "fa://keyboard-o",
        searchTerms: [ "type", "input" ]
    }, {
        title: "fa://flag-o",
        searchTerms: [ "report", "notification" ]
    }, {
        title: "fa://flag-checkered",
        searchTerms: [ "report", "notification", "notify" ]
    }, {
        title: "fa://terminal",
        searchTerms: [ "command", "prompt", "code" ]
    }, {
        title: "fa://code",
        searchTerms: [ "html", "brackets" ]
    }, {
        title: "fa://reply-all",
        searchTerms: []
    }, {
        title: "fa://star-half-o",
        searchTerms: [ "award", "achievement", "rating", "score" ]
    }, {
        title: "fa://location-arrow",
        searchTerms: [ "map", "coordinates", "location", "address", "place", "where" ]
    }, {
        title: "fa://crop",
        searchTerms: []
    }, {
        title: "fa://code-fork",
        searchTerms: [ "git", "fork", "vcs", "svn", "github", "rebase", "version", "merge" ]
    }, {
        title: "fa://chain-broken",
        searchTerms: [ "remove" ]
    }, {
        title: "fa://question",
        searchTerms: [ "help", "information", "unknown", "support" ]
    }, {
        title: "fa://info",
        searchTerms: [ "help", "information", "more", "details" ]
    }, {
        title: "fa://exclamation",
        searchTerms: [ "warning", "error", "problem", "notification", "notify", "alert" ]
    }, {
        title: "fa://superscript",
        searchTerms: [ "exponential" ]
    }, {
        title: "fa://subscript",
        searchTerms: []
    }, {
        title: "fa://eraser",
        searchTerms: [ "remove", "delete" ]
    }, {
        title: "fa://puzzle-piece",
        searchTerms: [ "addon", "add-on", "section" ]
    }, {
        title: "fa://microphone",
        searchTerms: [ "record", "voice", "sound" ]
    }, {
        title: "fa://microphone-slash",
        searchTerms: [ "record", "voice", "sound", "mute" ]
    }, {
        title: "fa://shield",
        searchTerms: [ "award", "achievement", "security", "winner" ]
    }, {
        title: "fa://calendar-o",
        searchTerms: [ "date", "time", "when", "event" ]
    }, {
        title: "fa://fire-extinguisher",
        searchTerms: []
    }, {
        title: "fa://rocket",
        searchTerms: [ "app" ]
    }, {
        title: "fa://maxcdn",
        searchTerms: []
    }, {
        title: "fa://chevron-circle-left",
        searchTerms: [ "previous", "back", "arrow" ]
    }, {
        title: "fa://chevron-circle-right",
        searchTerms: [ "next", "forward", "arrow" ]
    }, {
        title: "fa://chevron-circle-up",
        searchTerms: [ "arrow" ]
    }, {
        title: "fa://chevron-circle-down",
        searchTerms: [ "more", "dropdown", "menu", "arrow" ]
    }, {
        title: "fa://html5",
        searchTerms: []
    }, {
        title: "fa://css3",
        searchTerms: [ "code" ]
    }, {
        title: "fa://anchor",
        searchTerms: [ "link" ]
    }, {
        title: "fa://unlock-alt",
        searchTerms: [ "protect", "admin", "password", "lock" ]
    }, {
        title: "fa://bullseye",
        searchTerms: [ "target" ]
    }, {
        title: "fa://ellipsis-h",
        searchTerms: [ "dots" ]
    }, {
        title: "fa://ellipsis-v",
        searchTerms: [ "dots" ]
    }, {
        title: "fa://rss-square",
        searchTerms: [ "feed", "blog" ]
    }, {
        title: "fa://play-circle",
        searchTerms: [ "start", "playing" ]
    }, {
        title: "fa://ticket",
        searchTerms: [ "movie", "pass", "support" ]
    }, {
        title: "fa://minus-square",
        searchTerms: [ "hide", "minify", "delete", "remove", "trash", "hide", "collapse" ]
    }, {
        title: "fa://minus-square-o",
        searchTerms: [ "hide", "minify", "delete", "remove", "trash", "hide", "collapse" ]
    }, {
        title: "fa://level-up",
        searchTerms: [ "arrow" ]
    }, {
        title: "fa://level-down",
        searchTerms: [ "arrow" ]
    }, {
        title: "fa://check-square",
        searchTerms: [ "checkmark", "done", "todo", "agree", "accept", "confirm", "ok" ]
    }, {
        title: "fa://pencil-square",
        searchTerms: [ "write", "edit", "update" ]
    }, {
        title: "fa://external-link-square",
        searchTerms: [ "open", "new" ]
    }, {
        title: "fa://share-square",
        searchTerms: [ "social", "send" ]
    }, {
        title: "fa://compass",
        searchTerms: [ "safari", "directory", "menu", "location" ]
    }, {
        title: "fa://caret-square-o-down",
        searchTerms: [ "more", "dropdown", "menu" ]
    }, {
        title: "fa://caret-square-o-up",
        searchTerms: []
    }, {
        title: "fa://caret-square-o-right",
        searchTerms: [ "next", "forward" ]
    }, {
        title: "fa://eur",
        searchTerms: []
    }, {
        title: "fa://gbp",
        searchTerms: []
    }, {
        title: "fa://usd",
        searchTerms: []
    }, {
        title: "fa://inr",
        searchTerms: []
    }, {
        title: "fa://jpy",
        searchTerms: []
    }, {
        title: "fa://rub",
        searchTerms: []
    }, {
        title: "fa://krw",
        searchTerms: []
    }, {
        title: "fa://btc",
        searchTerms: []
    }, {
        title: "fa://file",
        searchTerms: [ "new", "page", "pdf", "document" ]
    }, {
        title: "fa://file-text",
        searchTerms: [ "new", "page", "pdf", "document" ]
    }, {
        title: "fa://sort-alpha-asc",
        searchTerms: []
    }, {
        title: "fa://sort-alpha-desc",
        searchTerms: []
    }, {
        title: "fa://sort-amount-asc",
        searchTerms: []
    }, {
        title: "fa://sort-amount-desc",
        searchTerms: []
    }, {
        title: "fa://sort-numeric-asc",
        searchTerms: [ "numbers" ]
    }, {
        title: "fa://sort-numeric-desc",
        searchTerms: [ "numbers" ]
    }, {
        title: "fa://thumbs-up",
        searchTerms: [ "like", "favorite", "approve", "agree", "hand" ]
    }, {
        title: "fa://thumbs-down",
        searchTerms: [ "dislike", "disapprove", "disagree", "hand" ]
    }, {
        title: "fa://youtube-square",
        searchTerms: [ "video", "film" ]
    }, {
        title: "fa://youtube",
        searchTerms: [ "video", "film" ]
    }, {
        title: "fa://xing",
        searchTerms: []
    }, {
        title: "fa://xing-square",
        searchTerms: []
    }, {
        title: "fa://youtube-play",
        searchTerms: [ "start", "playing" ]
    }, {
        title: "fa://dropbox",
        searchTerms: []
    }, {
        title: "fa://stack-overflow",
        searchTerms: []
    }, {
        title: "fa://instagram",
        searchTerms: []
    }, {
        title: "fa://flickr",
        searchTerms: []
    }, {
        title: "fa://adn",
        searchTerms: []
    }, {
        title: "fa://bitbucket",
        searchTerms: [ "git" ]
    }, {
        title: "fa://bitbucket-square",
        searchTerms: [ "git" ]
    }, {
        title: "fa://tumblr",
        searchTerms: []
    }, {
        title: "fa://tumblr-square",
        searchTerms: []
    }, {
        title: "fa://long-arrow-down",
        searchTerms: []
    }, {
        title: "fa://long-arrow-up",
        searchTerms: []
    }, {
        title: "fa://long-arrow-left",
        searchTerms: [ "previous", "back" ]
    }, {
        title: "fa://long-arrow-right",
        searchTerms: []
    }, {
        title: "fa://apple",
        searchTerms: [ "osx", "food" ]
    }, {
        title: "fa://windows",
        searchTerms: [ "microsoft" ]
    }, {
        title: "fa://android",
        searchTerms: [ "robot" ]
    }, {
        title: "fa://linux",
        searchTerms: [ "tux" ]
    }, {
        title: "fa://dribbble",
        searchTerms: []
    }, {
        title: "fa://skype",
        searchTerms: []
    }, {
        title: "fa://foursquare",
        searchTerms: []
    }, {
        title: "fa://trello",
        searchTerms: []
    }, {
        title: "fa://female",
        searchTerms: [ "woman", "user", "person", "profile" ]
    }, {
        title: "fa://male",
        searchTerms: [ "man", "user", "person", "profile" ]
    }, {
        title: "fa://gratipay",
        searchTerms: [ "heart", "like", "favorite", "love" ]
    }, {
        title: "fa://sun-o",
        searchTerms: [ "weather", "contrast", "lighter", "brighten", "day" ]
    }, {
        title: "fa://moon-o",
        searchTerms: [ "night", "darker", "contrast" ]
    }, {
        title: "fa://archive",
        searchTerms: [ "box", "storage" ]
    }, {
        title: "fa://bug",
        searchTerms: [ "report", "insect" ]
    }, {
        title: "fa://vk",
        searchTerms: []
    }, {
        title: "fa://weibo",
        searchTerms: []
    }, {
        title: "fa://renren",
        searchTerms: []
    }, {
        title: "fa://pagelines",
        searchTerms: [ "leaf", "leaves", "tree", "plant", "eco", "nature" ]
    }, {
        title: "fa://stack-exchange",
        searchTerms: []
    }, {
        title: "fa://arrow-circle-o-right",
        searchTerms: [ "next", "forward" ]
    }, {
        title: "fa://arrow-circle-o-left",
        searchTerms: [ "previous", "back" ]
    }, {
        title: "fa://caret-square-o-left",
        searchTerms: [ "previous", "back" ]
    }, {
        title: "fa://dot-circle-o",
        searchTerms: [ "target", "bullseye", "notification" ]
    }, {
        title: "fa://wheelchair",
        searchTerms: [ "handicap", "person" ]
    }, {
        title: "fa://vimeo-square",
        searchTerms: []
    }, {
        title: "fa://try",
        searchTerms: []
    }, {
        title: "fa://plus-square-o",
        searchTerms: [ "add", "new", "create", "expand" ]
    }, {
        title: "fa://space-shuttle",
        searchTerms: []
    }, {
        title: "fa://slack",
        searchTerms: [ "hashtag", "anchor", "hash" ]
    }, {
        title: "fa://envelope-square",
        searchTerms: []
    }, {
        title: "fa://wordpress",
        searchTerms: []
    }, {
        title: "fa://openid",
        searchTerms: []
    }, {
        title: "fa://university",
        searchTerms: []
    }, {
        title: "fa://graduation-cap",
        searchTerms: [ "learning", "school", "student" ]
    }, {
        title: "fa://yahoo",
        searchTerms: []
    }, {
        title: "fa://google",
        searchTerms: []
    }, {
        title: "fa://reddit",
        searchTerms: []
    }, {
        title: "fa://reddit-square",
        searchTerms: []
    }, {
        title: "fa://stumbleupon-circle",
        searchTerms: []
    }, {
        title: "fa://stumbleupon",
        searchTerms: []
    }, {
        title: "fa://delicious",
        searchTerms: []
    }, {
        title: "fa://digg",
        searchTerms: []
    }, {
        title: "fa://pied-piper-pp",
        searchTerms: []
    }, {
        title: "fa://pied-piper-alt",
        searchTerms: []
    }, {
        title: "fa://drupal",
        searchTerms: []
    }, {
        title: "fa://joomla",
        searchTerms: []
    }, {
        title: "fa://language",
        searchTerms: []
    }, {
        title: "fa://fax",
        searchTerms: []
    }, {
        title: "fa://building",
        searchTerms: [ "work", "business", "apartment", "office", "company" ]
    }, {
        title: "fa://child",
        searchTerms: []
    }, {
        title: "fa://paw",
        searchTerms: [ "pet" ]
    }, {
        title: "fa://spoon",
        searchTerms: []
    }, {
        title: "fa://cube",
        searchTerms: []
    }, {
        title: "fa://cubes",
        searchTerms: []
    }, {
        title: "fa://behance",
        searchTerms: []
    }, {
        title: "fa://behance-square",
        searchTerms: []
    }, {
        title: "fa://steam",
        searchTerms: []
    }, {
        title: "fa://steam-square",
        searchTerms: []
    }, {
        title: "fa://recycle",
        searchTerms: []
    }, {
        title: "fa://car",
        searchTerms: [ "vehicle" ]
    }, {
        title: "fa://taxi",
        searchTerms: [ "vehicle" ]
    }, {
        title: "fa://tree",
        searchTerms: []
    }, {
        title: "fa://spotify",
        searchTerms: []
    }, {
        title: "fa://deviantart",
        searchTerms: []
    }, {
        title: "fa://soundcloud",
        searchTerms: []
    }, {
        title: "fa://database",
        searchTerms: []
    }, {
        title: "fa://file-pdf-o",
        searchTerms: []
    }, {
        title: "fa://file-word-o",
        searchTerms: []
    }, {
        title: "fa://file-excel-o",
        searchTerms: []
    }, {
        title: "fa://file-powerpoint-o",
        searchTerms: []
    }, {
        title: "fa://file-image-o",
        searchTerms: []
    }, {
        title: "fa://file-archive-o",
        searchTerms: []
    }, {
        title: "fa://file-audio-o",
        searchTerms: []
    }, {
        title: "fa://file-video-o",
        searchTerms: []
    }, {
        title: "fa://file-code-o",
        searchTerms: []
    }, {
        title: "fa://vine",
        searchTerms: []
    }, {
        title: "fa://codepen",
        searchTerms: []
    }, {
        title: "fa://jsfiddle",
        searchTerms: []
    }, {
        title: "fa://life-ring",
        searchTerms: []
    }, {
        title: "fa://circle-o-notch",
        searchTerms: []
    }, {
        title: "fa://rebel",
        searchTerms: []
    }, {
        title: "fa://empire",
        searchTerms: []
    }, {
        title: "fa://git-square",
        searchTerms: []
    }, {
        title: "fa://git",
        searchTerms: []
    }, {
        title: "fa://hacker-news",
        searchTerms: []
    }, {
        title: "fa://tencent-weibo",
        searchTerms: []
    }, {
        title: "fa://qq",
        searchTerms: []
    }, {
        title: "fa://weixin",
        searchTerms: []
    }, {
        title: "fa://paper-plane",
        searchTerms: []
    }, {
        title: "fa://paper-plane-o",
        searchTerms: []
    }, {
        title: "fa://history",
        searchTerms: []
    }, {
        title: "fa://circle-thin",
        searchTerms: []
    }, {
        title: "fa://header",
        searchTerms: [ "heading" ]
    }, {
        title: "fa://paragraph",
        searchTerms: []
    }, {
        title: "fa://sliders",
        searchTerms: [ "settings" ]
    }, {
        title: "fa://share-alt",
        searchTerms: []
    }, {
        title: "fa://share-alt-square",
        searchTerms: []
    }, {
        title: "fa://bomb",
        searchTerms: []
    }, {
        title: "fa://futbol-o",
        searchTerms: []
    }, {
        title: "fa://tty",
        searchTerms: []
    }, {
        title: "fa://binoculars",
        searchTerms: []
    }, {
        title: "fa://plug",
        searchTerms: [ "power", "connect" ]
    }, {
        title: "fa://slideshare",
        searchTerms: []
    }, {
        title: "fa://twitch",
        searchTerms: []
    }, {
        title: "fa://yelp",
        searchTerms: []
    }, {
        title: "fa://newspaper-o",
        searchTerms: [ "press" ]
    }, {
        title: "fa://wifi",
        searchTerms: []
    }, {
        title: "fa://calculator",
        searchTerms: []
    }, {
        title: "fa://paypal",
        searchTerms: []
    }, {
        title: "fa://google-wallet",
        searchTerms: []
    }, {
        title: "fa://cc-visa",
        searchTerms: []
    }, {
        title: "fa://cc-mastercard",
        searchTerms: []
    }, {
        title: "fa://cc-discover",
        searchTerms: []
    }, {
        title: "fa://cc-amex",
        searchTerms: [ "amex" ]
    }, {
        title: "fa://cc-paypal",
        searchTerms: []
    }, {
        title: "fa://cc-stripe",
        searchTerms: []
    }, {
        title: "fa://bell-slash",
        searchTerms: []
    }, {
        title: "fa://bell-slash-o",
        searchTerms: []
    }, {
        title: "fa://trash",
        searchTerms: [ "garbage", "delete", "remove", "hide" ]
    }, {
        title: "fa://copyright",
        searchTerms: []
    }, {
        title: "fa://at",
        searchTerms: []
    }, {
        title: "fa://eyedropper",
        searchTerms: []
    }, {
        title: "fa://paint-brush",
        searchTerms: []
    }, {
        title: "fa://birthday-cake",
        searchTerms: []
    }, {
        title: "fa://area-chart",
        searchTerms: [ "graph", "analytics" ]
    }, {
        title: "fa://pie-chart",
        searchTerms: [ "graph", "analytics" ]
    }, {
        title: "fa://line-chart",
        searchTerms: [ "graph", "analytics" ]
    }, {
        title: "fa://lastfm",
        searchTerms: []
    }, {
        title: "fa://lastfm-square",
        searchTerms: []
    }, {
        title: "fa://toggle-off",
        searchTerms: []
    }, {
        title: "fa://toggle-on",
        searchTerms: []
    }, {
        title: "fa://bicycle",
        searchTerms: [ "vehicle", "bike" ]
    }, {
        title: "fa://bus",
        searchTerms: [ "vehicle" ]
    }, {
        title: "fa://ioxhost",
        searchTerms: []
    }, {
        title: "fa://angellist",
        searchTerms: []
    }, {
        title: "fa://cc",
        searchTerms: []
    }, {
        title: "fa://ils",
        searchTerms: []
    }, {
        title: "fa://meanpath",
        searchTerms: []
    }, {
        title: "fa://buysellads",
        searchTerms: []
    }, {
        title: "fa://connectdevelop",
        searchTerms: []
    }, {
        title: "fa://dashcube",
        searchTerms: []
    }, {
        title: "fa://forumbee",
        searchTerms: []
    }, {
        title: "fa://leanpub",
        searchTerms: []
    }, {
        title: "fa://sellsy",
        searchTerms: []
    }, {
        title: "fa://shirtsinbulk",
        searchTerms: []
    }, {
        title: "fa://simplybuilt",
        searchTerms: []
    }, {
        title: "fa://skyatlas",
        searchTerms: []
    }, {
        title: "fa://cart-plus",
        searchTerms: [ "add", "shopping" ]
    }, {
        title: "fa://cart-arrow-down",
        searchTerms: [ "shopping" ]
    }, {
        title: "fa://diamond",
        searchTerms: [ "gem", "gemstone" ]
    }, {
        title: "fa://ship",
        searchTerms: [ "boat", "sea" ]
    }, {
        title: "fa://user-secret",
        searchTerms: [ "whisper", "spy", "incognito", "privacy" ]
    }, {
        title: "fa://motorcycle",
        searchTerms: [ "vehicle", "bike" ]
    }, {
        title: "fa://street-view",
        searchTerms: [ "map" ]
    }, {
        title: "fa://heartbeat",
        searchTerms: [ "ekg" ]
    }, {
        title: "fa://venus",
        searchTerms: [ "female" ]
    }, {
        title: "fa://mars",
        searchTerms: [ "male" ]
    }, {
        title: "fa://mercury",
        searchTerms: [ "transgender" ]
    }, {
        title: "fa://transgender",
        searchTerms: []
    }, {
        title: "fa://transgender-alt",
        searchTerms: []
    }, {
        title: "fa://venus-double",
        searchTerms: []
    }, {
        title: "fa://mars-double",
        searchTerms: []
    }, {
        title: "fa://venus-mars",
        searchTerms: []
    }, {
        title: "fa://mars-stroke",
        searchTerms: []
    }, {
        title: "fa://mars-stroke-v",
        searchTerms: []
    }, {
        title: "fa://mars-stroke-h",
        searchTerms: []
    }, {
        title: "fa://neuter",
        searchTerms: []
    }, {
        title: "fa://genderless",
        searchTerms: []
    }, {
        title: "fa://facebook-official",
        searchTerms: []
    }, {
        title: "fa://pinterest-p",
        searchTerms: []
    }, {
        title: "fa://whatsapp",
        searchTerms: []
    }, {
        title: "fa://server",
        searchTerms: []
    }, {
        title: "fa://user-plus",
        searchTerms: [ "sign up", "signup" ]
    }, {
        title: "fa://user-times",
        searchTerms: []
    }, {
        title: "fa://bed",
        searchTerms: [ "travel" ]
    }, {
        title: "fa://viacoin",
        searchTerms: []
    }, {
        title: "fa://train",
        searchTerms: []
    }, {
        title: "fa://subway",
        searchTerms: []
    }, {
        title: "fa://medium",
        searchTerms: []
    }, {
        title: "fa://y-combinator",
        searchTerms: []
    }, {
        title: "fa://optin-monster",
        searchTerms: []
    }, {
        title: "fa://opencart",
        searchTerms: []
    }, {
        title: "fa://expeditedssl",
        searchTerms: []
    }, {
        title: "fa://battery-full",
        searchTerms: [ "power" ]
    }, {
        title: "fa://battery-three-quarters",
        searchTerms: [ "power" ]
    }, {
        title: "fa://battery-half",
        searchTerms: [ "power" ]
    }, {
        title: "fa://battery-quarter",
        searchTerms: [ "power" ]
    }, {
        title: "fa://battery-empty",
        searchTerms: [ "power" ]
    }, {
        title: "fa://mouse-pointer",
        searchTerms: []
    }, {
        title: "fa://i-cursor",
        searchTerms: []
    }, {
        title: "fa://object-group",
        searchTerms: []
    }, {
        title: "fa://object-ungroup",
        searchTerms: []
    }, {
        title: "fa://sticky-note",
        searchTerms: []
    }, {
        title: "fa://sticky-note-o",
        searchTerms: []
    }, {
        title: "fa://cc-jcb",
        searchTerms: []
    }, {
        title: "fa://cc-diners-club",
        searchTerms: []
    }, {
        title: "fa://clone",
        searchTerms: [ "copy" ]
    }, {
        title: "fa://balance-scale",
        searchTerms: []
    }, {
        title: "fa://hourglass-o",
        searchTerms: []
    }, {
        title: "fa://hourglass-start",
        searchTerms: []
    }, {
        title: "fa://hourglass-half",
        searchTerms: []
    }, {
        title: "fa://hourglass-end",
        searchTerms: []
    }, {
        title: "fa://hourglass",
        searchTerms: []
    }, {
        title: "fa://hand-rock-o",
        searchTerms: []
    }, {
        title: "fa://hand-paper-o",
        searchTerms: [ "stop" ]
    }, {
        title: "fa://hand-scissors-o",
        searchTerms: []
    }, {
        title: "fa://hand-lizard-o",
        searchTerms: []
    }, {
        title: "fa://hand-spock-o",
        searchTerms: []
    }, {
        title: "fa://hand-pointer-o",
        searchTerms: []
    }, {
        title: "fa://hand-peace-o",
        searchTerms: []
    }, {
        title: "fa://trademark",
        searchTerms: []
    }, {
        title: "fa://registered",
        searchTerms: []
    }, {
        title: "fa://creative-commons",
        searchTerms: []
    }, {
        title: "fa://gg",
        searchTerms: []
    }, {
        title: "fa://gg-circle",
        searchTerms: []
    }, {
        title: "fa://tripadvisor",
        searchTerms: []
    }, {
        title: "fa://odnoklassniki",
        searchTerms: []
    }, {
        title: "fa://odnoklassniki-square",
        searchTerms: []
    }, {
        title: "fa://get-pocket",
        searchTerms: []
    }, {
        title: "fa://wikipedia-w",
        searchTerms: []
    }, {
        title: "fa://safari",
        searchTerms: [ "browser" ]
    }, {
        title: "fa://chrome",
        searchTerms: [ "browser" ]
    }, {
        title: "fa://firefox",
        searchTerms: [ "browser" ]
    }, {
        title: "fa://opera",
        searchTerms: []
    }, {
        title: "fa://internet-explorer",
        searchTerms: [ "browser", "ie" ]
    }, {
        title: "fa://television",
        searchTerms: [ "display", "computer", "monitor" ]
    }, {
        title: "fa://contao",
        searchTerms: []
    }, {
        title: "fa://500px",
        searchTerms: []
    }, {
        title: "fa://amazon",
        searchTerms: []
    }, {
        title: "fa://calendar-plus-o",
        searchTerms: []
    }, {
        title: "fa://calendar-minus-o",
        searchTerms: []
    }, {
        title: "fa://calendar-times-o",
        searchTerms: []
    }, {
        title: "fa://calendar-check-o",
        searchTerms: [ "ok" ]
    }, {
        title: "fa://industry",
        searchTerms: [ "factory" ]
    }, {
        title: "fa://map-pin",
        searchTerms: []
    }, {
        title: "fa://map-signs",
        searchTerms: []
    }, {
        title: "fa://map-o",
        searchTerms: []
    }, {
        title: "fa://map",
        searchTerms: []
    }, {
        title: "fa://commenting",
        searchTerms: [ "speech", "notification", "note", "chat", "bubble", "feedback", "message", "texting", "sms", "conversation" ]
    }, {
        title: "fa://commenting-o",
        searchTerms: [ "speech", "notification", "note", "chat", "bubble", "feedback", "message", "texting", "sms", "conversation" ]
    }, {
        title: "fa://houzz",
        searchTerms: []
    }, {
        title: "fa://vimeo",
        searchTerms: []
    }, {
        title: "fa://black-tie",
        searchTerms: []
    }, {
        title: "fa://fonticons",
        searchTerms: []
    }, {
        title: "fa://reddit-alien",
        searchTerms: []
    }, {
        title: "fa://edge",
        searchTerms: [ "browser", "ie" ]
    }, {
        title: "fa://credit-card-alt",
        searchTerms: [ "money", "buy", "debit", "checkout", "purchase", "payment", "credit card" ]
    }, {
        title: "fa://codiepie",
        searchTerms: []
    }, {
        title: "fa://modx",
        searchTerms: []
    }, {
        title: "fa://fort-awesome",
        searchTerms: []
    }, {
        title: "fa://usb",
        searchTerms: []
    }, {
        title: "fa://product-hunt",
        searchTerms: []
    }, {
        title: "fa://mixcloud",
        searchTerms: []
    }, {
        title: "fa://scribd",
        searchTerms: []
    }, {
        title: "fa://pause-circle",
        searchTerms: []
    }, {
        title: "fa://pause-circle-o",
        searchTerms: []
    }, {
        title: "fa://stop-circle",
        searchTerms: []
    }, {
        title: "fa://stop-circle-o",
        searchTerms: []
    }, {
        title: "fa://shopping-bag",
        searchTerms: []
    }, {
        title: "fa://shopping-basket",
        searchTerms: []
    }, {
        title: "fa://hashtag",
        searchTerms: []
    }, {
        title: "fa://bluetooth",
        searchTerms: []
    }, {
        title: "fa://bluetooth-b",
        searchTerms: []
    }, {
        title: "fa://percent",
        searchTerms: []
    }, {
        title: "fa://gitlab",
        searchTerms: []
    }, {
        title: "fa://wpbeginner",
        searchTerms: []
    }, {
        title: "fa://wpforms",
        searchTerms: []
    }, {
        title: "fa://envira",
        searchTerms: [ "leaf" ]
    }, {
        title: "fa://universal-access",
        searchTerms: []
    }, {
        title: "fa://wheelchair-alt",
        searchTerms: [ "handicap", "person" ]
    }, {
        title: "fa://question-circle-o",
        searchTerms: []
    }, {
        title: "fa://blind",
        searchTerms: []
    }, {
        title: "fa://audio-description",
        searchTerms: []
    }, {
        title: "fa://volume-control-phone",
        searchTerms: [ "telephone" ]
    }, {
        title: "fa://braille",
        searchTerms: []
    }, {
        title: "fa://assistive-listening-systems",
        searchTerms: []
    }, {
        title: "fa://american-sign-language-interpreting",
        searchTerms: []
    }, {
        title: "fa://deaf",
        searchTerms: []
    }, {
        title: "fa://glide",
        searchTerms: []
    }, {
        title: "fa://glide-g",
        searchTerms: []
    }, {
        title: "fa://sign-language",
        searchTerms: []
    }, {
        title: "fa://low-vision",
        searchTerms: []
    }, {
        title: "fa://viadeo",
        searchTerms: []
    }, {
        title: "fa://viadeo-square",
        searchTerms: []
    }, {
        title: "fa://snapchat",
        searchTerms: []
    }, {
        title: "fa://snapchat-ghost",
        searchTerms: []
    }, {
        title: "fa://snapchat-square",
        searchTerms: []
    }, {
        title: "fa://pied-piper",
        searchTerms: []
    }, {
        title: "fa://first-order",
        searchTerms: []
    }, {
        title: "fa://yoast",
        searchTerms: []
    }, {
        title: "fa://themeisle",
        searchTerms: []
    }, {
        title: "fa://google-plus-official",
        searchTerms: []
    }, {
        title: "fa://font-awesome",
        searchTerms: []
    }, {
        title: "fa://handshake-o",
        searchTerms: []
    }, {
        title: "fa://envelope-open",
        searchTerms: []
    }, {
        title: "fa://envelope-open-o",
        searchTerms: []
    }, {
        title: "fa://linode",
        searchTerms: []
    }, {
        title: "fa://address-book",
        searchTerms: []
    }, {
        title: "fa://address-book-o",
        searchTerms: []
    }, {
        title: "fa://address-card",
        searchTerms: []
    }, {
        title: "fa://address-card-o",
        searchTerms: []
    }, {
        title: "fa://user-circle",
        searchTerms: []
    }, {
        title: "fa://user-circle-o",
        searchTerms: []
    }, {
        title: "fa://user-o",
        searchTerms: []
    }, {
        title: "fa://id-badge",
        searchTerms: []
    }, {
        title: "fa://id-card",
        searchTerms: []
    }, {
        title: "fa://id-card-o",
        searchTerms: []
    }, {
        title: "fa://quora",
        searchTerms: []
    }, {
        title: "fa://free-code-camp",
        searchTerms: []
    }, {
        title: "fa://telegram",
        searchTerms: []
    }, {
        title: "fa://thermometer-full",
        searchTerms: []
    }, {
        title: "fa://thermometer-three-quarters",
        searchTerms: []
    }, {
        title: "fa://thermometer-half",
        searchTerms: []
    }, {
        title: "fa://thermometer-quarter",
        searchTerms: []
    }, {
        title: "fa://thermometer-empty",
        searchTerms: []
    }, {
        title: "fa://shower",
        searchTerms: []
    }, {
        title: "fa://bath",
        searchTerms: []
    }, {
        title: "fa://podcast",
        searchTerms: []
    }, {
        title: "fa://window-maximize",
        searchTerms: []
    }, {
        title: "fa://window-minimize",
        searchTerms: []
    }, {
        title: "fa://window-restore",
        searchTerms: []
    }, {
        title: "fa://window-close",
        searchTerms: []
    }, {
        title: "fa://window-close-o",
        searchTerms: []
    }, {
        title: "fa://bandcamp",
        searchTerms: []
    }, {
        title: "fa://grav",
        searchTerms: []
    }, {
        title: "fa://etsy",
        searchTerms: []
    }, {
        title: "fa://imdb",
        searchTerms: []
    }, {
        title: "fa://ravelry",
        searchTerms: []
    }, {
        title: "fa://eercast",
        searchTerms: []
    }, {
        title: "fa://microchip",
        searchTerms: []
    }, {
        title: "fa://snowflake-o",
        searchTerms: []
    }, {
        title: "fa://superpowers",
        searchTerms: []
    }, {
        title: "fa://wpexplorer",
        searchTerms: []
    }, {
        title: "fa://meetup",
        searchTerms: []
    } ]
};

var FA4iconinfo = FA4iconinfolong["icons"];

(function(a) {
    "use strict";
    if (typeof define === "function" && define.amd) {
        define([ "jquery" ], a);
    } else if (window.jQuery && !window.jQuery.fn.iconpicker) {
        a(window.jQuery);
    }
})(function(a) {
    "use strict";
    var b = {
        isEmpty: function(a) {
            return a === false || a === "" || a === null || a === undefined;
        },
        isEmptyObject: function(a) {
            return this.isEmpty(a) === true || a.length === 0;
        },
        isElement: function(b) {
            return a(b).length > 0;
        },
        isString: function(a) {
            return typeof a === "string" || a instanceof String;
        },
        isArray: function(b) {
            return a.isArray(b);
        },
        inArray: function(b, c) {
            return a.inArray(b, c) !== -1;
        },
        throwError: function(a) {
            throw "Font Awesome Icon Picker Exception: " + a;
        }
    };
    var c = function(d, e) {
        this._id = c._idCounter++;
        this.element = a(d).addClass("iconpicker-element");
        this._trigger("iconpickerCreate", {
            iconpickerValue: this.iconpickerValue
        });
        this.options = a.extend({}, c.defaultOptions, this.element.data(), e);
        this.options.templates = a.extend({}, c.defaultOptions.templates, this.options.templates);
        this.options.originalPlacement = this.options.placement;
        this.container = b.isElement(this.options.container) ? a(this.options.container) : false;
        if (this.container === false) {
            if (this.element.is(".dropdown-toggle")) {
                this.container = a("~ .dropdown-menu:first", this.element);
            } else {
                this.container = this.element.is("input,textarea,button,.btn") ? this.element.parent() : this.element;
            }
        }
        this.container.addClass("iconpicker-container");
        if (this.isDropdownMenu()) {
            this.options.placement = "inline";
        }
        this.input = this.element.is("input,textarea") ? this.element.addClass("iconpicker-input") : false;
        if (this.input === false) {
            this.input = this.container.find(this.options.input);
            if (!this.input.is("input,textarea")) {
                this.input = false;
            }
        }
        this.component = this.isDropdownMenu() ? this.container.parent().find(this.options.component) : this.container.find(this.options.component);
        if (this.component.length === 0) {
            this.component = false;
        } else {
            this.component.find("i").addClass("iconpicker-component");
        }
        this._createPopover();
        this._createIconpicker();
        if (this.getAcceptButton().length === 0) {
            this.options.mustAccept = false;
        }
        if (this.isInputGroup()) {
            this.container.parent().append(this.popover);
        } else {
            this.container.append(this.popover);
        }
        this._bindElementEvents();
        this._bindWindowEvents();
        this.update(this.options.selected);
        if (this.isInline()) {
            this.show();
        }
        this._trigger("iconpickerCreated", {
            iconpickerValue: this.iconpickerValue
        });
    };
    c._idCounter = 0;
    c.defaultOptions = {
        title: false,
        selected: false,
        defaultValue: false,
        placement: "bottom",
        collision: "none",
        animation: true,
        hideOnSelect: false,
        showFooter: false,
        searchInFooter: false,
        mustAccept: false,
        selectedCustomClass: "bg-primary",
        icons: [],
        fullClassFormatter: function(a) {
            var b = parseIconURI(a);
            if (b.length == 2) {
                return b[0] + " fa-" + b[1];
            } else {
                return a;
            }
        },
        input: "input,.iconpicker-input",
        inputSearch: false,
        container: false,
        component: ".input-group-addon,.iconpicker-component",
        templates: {
            popover: '<div class="iconpicker-popover popover"><div class="arrow"></div>' + '<div class="popover-title"></div><div class="popover-content"></div></div>',
            footer: '<div class="popover-footer"></div>',
            buttons: '<button class="iconpicker-btn iconpicker-btn-cancel btn btn-default btn-sm">Cancel</button>' + ' <button class="iconpicker-btn iconpicker-btn-accept btn btn-primary btn-sm">Accept</button>',
            search: '<input type="search" class="form-control iconpicker-search" placeholder="Type to filter" />',
            iconpicker: '<div class="iconpicker"><div class="iconpicker-items"></div></div>',
            iconpickerItem: '<a role="button" href="#" class="iconpicker-item"><i></i></a>'
        }
    };
    c.batch = function(b, c) {
        var d = Array.prototype.slice.call(arguments, 2);
        return a(b).each(function() {
            var b = a(this).data("iconpicker");
            if (!!b) {
                b[c].apply(b, d);
            }
        });
    };
    c.prototype = {
        constructor: c,
        options: {},
        _id: 0,
        _trigger: function(b, c) {
            c = c || {};
            this.element.trigger(a.extend({
                type: b,
                iconpickerInstance: this
            }, c));
        },
        _createPopover: function() {
            this.popover = a(this.options.templates.popover);
            var c = this.popover.find(".popover-title");
            if (!!this.options.title) {
                c.append(a('<div class="popover-title-text">' + this.options.title + "</div>"));
            }
            if (this.hasSeparatedSearchInput() && !this.options.searchInFooter) {
                c.append(this.options.templates.search);
            } else if (!this.options.title) {
                c.remove();
            }
            if (this.options.showFooter && !b.isEmpty(this.options.templates.footer)) {
                var d = a(this.options.templates.footer);
                if (this.hasSeparatedSearchInput() && this.options.searchInFooter) {
                    d.append(a(this.options.templates.search));
                }
                if (!b.isEmpty(this.options.templates.buttons)) {
                    d.append(a(this.options.templates.buttons));
                }
                this.popover.append(d);
            }
            if (this.options.animation === true) {
                this.popover.addClass("fade");
            }
            return this.popover;
        },
        _createIconpicker: function() {
            var b = this;
            this.iconpicker = a(this.options.templates.iconpicker);
            var c = function(c) {
                var d = a(this);
                if (d.is("i")) {
                    d = d.parent();
                }
                b._trigger("iconpickerSelect", {
                    iconpickerItem: d,
                    iconpickerValue: b.iconpickerValue
                });
                if (b.options.mustAccept === false) {
                    b.update(d.data("iconpickerValue"));
                    b._trigger("iconpickerSelected", {
                        iconpickerItem: this,
                        iconpickerValue: b.iconpickerValue
                    });
                } else {
                    b.update(d.data("iconpickerValue"), true);
                }
                if (b.options.hideOnSelect && b.options.mustAccept === false) {
                    b.hide();
                }
            };
            for (var d in this.options.icons) {
                if (typeof this.options.icons[d].title === "string") {
                    var e = a(this.options.templates.iconpickerItem);
                    var f = parseIconURI(this.options.icons[d].title);
                    e.find("i").addClass(this.options.fullClassFormatter(this.options.icons[d].title));
                    e.data("iconpickerValue", this.options.icons[d].title).on("click.iconpicker", c);
                    this.iconpicker.find(".iconpicker-items").append(e.attr("title", this.options.icons[d].title));
                    if (this.options.icons[d].searchTerms.length > 0) {
                        var g = "";
                        for (var h = 0; h < this.options.icons[d].searchTerms.length; h++) {
                            g = g + this.options.icons[d].searchTerms[h] + " ";
                        }
                        this.iconpicker.find(".iconpicker-items").append(e.attr("data-search-terms", g));
                    }
                }
            }
            this.popover.find(".popover-content").append(this.iconpicker);
            return this.iconpicker;
        },
        _isEventInsideIconpicker: function(b) {
            var c = a(b.target);
            if ((!c.hasClass("iconpicker-element") || c.hasClass("iconpicker-element") && !c.is(this.element)) && c.parents(".iconpicker-popover").length === 0) {
                return false;
            }
            return true;
        },
        _bindElementEvents: function() {
            var c = this;
            this.getSearchInput().on("keyup.iconpicker", function() {
                c.filter(a(this).val().toLowerCase());
            });
            this.getAcceptButton().on("click.iconpicker", function() {
                var a = c.iconpicker.find(".iconpicker-selected").get(0);
                c.update(c.iconpickerValue);
                c._trigger("iconpickerSelected", {
                    iconpickerItem: a,
                    iconpickerValue: c.iconpickerValue
                });
                if (!c.isInline()) {
                    c.hide();
                }
            });
            this.getCancelButton().on("click.iconpicker", function() {
                if (!c.isInline()) {
                    c.hide();
                }
            });
            this.element.on("focus.iconpicker", function(a) {
                c.show();
                a.stopPropagation();
            });
            if (this.hasComponent()) {
                this.component.on("click.iconpicker", function() {
                    c.toggle();
                });
            }
            if (this.hasInput()) {
                this.input.on("keyup.iconpicker", function(d) {
                    if (!b.inArray(d.keyCode, [ 38, 40, 37, 39, 16, 17, 18, 9, 8, 91, 93, 20, 46, 186, 190, 46, 78, 188, 44, 86 ])) {
                        c.update();
                    } else {
                        c._updateFormGroupStatus(c.getValid(this.value) !== false);
                    }
                    if (c.options.inputSearch === true) {
                        c.filter(a(this).val().toLowerCase());
                    }
                });
            }
        },
        _bindWindowEvents: function() {
            var b = a(window.document);
            var c = this;
            var d = ".iconpicker.inst" + this._id;
            a(window).on("resize.iconpicker" + d + " orientationchange.iconpicker" + d, function(a) {
                if (c.popover.hasClass("in")) {
                    c.updatePlacement();
                }
            });
            if (!c.isInline()) {
                b.on("mouseup" + d, function(a) {
                    if (!c._isEventInsideIconpicker(a) && !c.isInline()) {
                        c.hide();
                    }
                });
            }
        },
        _unbindElementEvents: function() {
            this.popover.off(".iconpicker");
            this.element.off(".iconpicker");
            if (this.hasInput()) {
                this.input.off(".iconpicker");
            }
            if (this.hasComponent()) {
                this.component.off(".iconpicker");
            }
            if (this.hasContainer()) {
                this.container.off(".iconpicker");
            }
        },
        _unbindWindowEvents: function() {
            a(window).off(".iconpicker.inst" + this._id);
            a(window.document).off(".iconpicker.inst" + this._id);
        },
        updatePlacement: function(b, c) {
            b = b || this.options.placement;
            this.options.placement = b;
            c = c || this.options.collision;
            c = c === true ? "flip" : c;
            var d = {
                at: "right bottom",
                my: "right top",
                of: this.hasInput() && !this.isInputGroup() ? this.input : this.container,
                collision: c === true ? "flip" : c,
                within: window
            };
            this.popover.removeClass("inline topLeftCorner topLeft top topRight topRightCorner " + "rightTop right rightBottom bottomRight bottomRightCorner " + "bottom bottomLeft bottomLeftCorner leftBottom left leftTop");
            if (typeof b === "object") {
                return this.popover.pos(a.extend({}, d, b));
            }
            switch (b) {
              case "inline":
                {
                    d = false;
                }
                break;

              case "topLeftCorner":
                {
                    d.my = "right bottom";
                    d.at = "left top";
                }
                break;

              case "topLeft":
                {
                    d.my = "left bottom";
                    d.at = "left top";
                }
                break;

              case "top":
                {
                    d.my = "center bottom";
                    d.at = "center top";
                }
                break;

              case "topRight":
                {
                    d.my = "right bottom";
                    d.at = "right top";
                }
                break;

              case "topRightCorner":
                {
                    d.my = "left bottom";
                    d.at = "right top";
                }
                break;

              case "rightTop":
                {
                    d.my = "left bottom";
                    d.at = "right center";
                }
                break;

              case "right":
                {
                    d.my = "left center";
                    d.at = "right center";
                }
                break;

              case "rightBottom":
                {
                    d.my = "left top";
                    d.at = "right center";
                }
                break;

              case "bottomRightCorner":
                {
                    d.my = "left top";
                    d.at = "right bottom";
                }
                break;

              case "bottomRight":
                {
                    d.my = "right top";
                    d.at = "right bottom";
                }
                break;

              case "bottom":
                {
                    d.my = "center top";
                    d.at = "center bottom";
                }
                break;

              case "bottomLeft":
                {
                    d.my = "left top";
                    d.at = "left bottom";
                }
                break;

              case "bottomLeftCorner":
                {
                    d.my = "right top";
                    d.at = "left bottom";
                }
                break;

              case "leftBottom":
                {
                    d.my = "right top";
                    d.at = "left center";
                }
                break;

              case "left":
                {
                    d.my = "right center";
                    d.at = "left center";
                }
                break;

              case "leftTop":
                {
                    d.my = "right bottom";
                    d.at = "left center";
                }
                break;

              default:
                {
                    return false;
                }
                break;
            }
            this.popover.css({
                display: this.options.placement === "inline" ? "" : "block"
            });
            if (d !== false) {
                this.popover.pos(d).css("maxWidth", a(window).width() - this.container.offset().left - 5);
            } else {
                this.popover.css({
                    top: "auto",
                    right: "auto",
                    bottom: "auto",
                    left: "auto",
                    maxWidth: "none"
                });
            }
            this.popover.addClass(this.options.placement);
            return true;
        },
        _updateComponents: function() {
            this.iconpicker.find(".iconpicker-item.iconpicker-selected").removeClass("iconpicker-selected " + this.options.selectedCustomClass);
            if (this.iconpickerValue) {
                this.iconpicker.find("." + this.options.fullClassFormatter(this.iconpickerValue).replace(/ /g, ".")).parent().addClass("iconpicker-selected " + this.options.selectedCustomClass);
            }
            if (this.hasComponent()) {
                var a = this.component.find("i");
                if (a.length > 0) {
                    a.attr("class", this.options.fullClassFormatter(this.iconpickerValue));
                } else {
                    this.component.html(this.getHtml());
                }
            }
        },
        _updateFormGroupStatus: function(a) {
            if (this.hasInput()) {
                if (a !== false) {
                    this.input.parents(".form-group:first").removeClass("has-error");
                } else {
                    this.input.parents(".form-group:first").addClass("has-error");
                }
                return true;
            }
            return false;
        },
        getValid: function(c) {
            if (!b.isString(c)) {
                c = "";
            }
            var d = c === "";
            c = a.trim(c);
            var e = false;
            for (var f = 0; f < this.options.icons.length; f++) {
                if (this.options.icons[f].title === c) {
                    e = true;
                    break;
                }
            }
            if (e || d) {
                return c;
            }
            return false;
        },
        setValue: function(a) {
            var b = this.getValid(a);
            if (b !== false) {
                this.iconpickerValue = b;
                this._trigger("iconpickerSetValue", {
                    iconpickerValue: b
                });
                return this.iconpickerValue;
            } else {
                this._trigger("iconpickerInvalid", {
                    iconpickerValue: a
                });
                return false;
            }
        },
        getHtml: function() {
            return '<i class="' + this.options.fullClassFormatter(this.iconpickerValue) + '"></i>';
        },
        setSourceValue: function(a) {
            a = this.setValue(a);
            if (a !== false && a !== "") {
                if (this.hasInput()) {
                    this.input.val(this.iconpickerValue);
                } else {
                    this.element.data("iconpickerValue", this.iconpickerValue);
                }
                this._trigger("iconpickerSetSourceValue", {
                    iconpickerValue: a
                });
            }
            return a;
        },
        getSourceValue: function(a) {
            a = a || this.options.defaultValue;
            var b = a;
            if (this.hasInput()) {
                b = this.input.val();
            } else {
                b = this.element.data("iconpickerValue");
            }
            if (b === undefined || b === "" || b === null || b === false) {
                b = a;
            }
            return b;
        },
        hasInput: function() {
            return this.input !== false;
        },
        isInputSearch: function() {
            return this.hasInput() && this.options.inputSearch === true;
        },
        isInputGroup: function() {
            return this.container.is(".input-group");
        },
        isDropdownMenu: function() {
            return this.container.is(".dropdown-menu");
        },
        hasSeparatedSearchInput: function() {
            return this.options.templates.search !== false && !this.isInputSearch();
        },
        hasComponent: function() {
            return this.component !== false;
        },
        hasContainer: function() {
            return this.container !== false;
        },
        getAcceptButton: function() {
            return this.popover.find(".iconpicker-btn-accept");
        },
        getCancelButton: function() {
            return this.popover.find(".iconpicker-btn-cancel");
        },
        getSearchInput: function() {
            return this.popover.find(".iconpicker-search");
        },
        filter: function(c) {
            if (b.isEmpty(c)) {
                this.iconpicker.find(".iconpicker-item").show();
                return a(false);
            } else {
                var d = [];
                this.iconpicker.find(".iconpicker-item").each(function() {
                    var b = a(this);
                    var e = b.attr("title").toLowerCase();
                    var f = b.attr("data-search-terms") ? b.attr("data-search-terms").toLowerCase() : "";
                    e = e + " " + f;
                    var g = false;
                    try {
                        g = new RegExp("(^|\\W)" + c, "g");
                    } catch (a) {
                        g = false;
                    }
                    if (g !== false && e.match(g)) {
                        d.push(b);
                        b.show();
                    } else {
                        b.hide();
                    }
                });
                return d;
            }
        },
        show: function() {
            if (this.popover.hasClass("in")) {
                return false;
            }
            a.iconpicker.batch(a(".iconpicker-popover.in:not(.inline)").not(this.popover), "hide");
            this._trigger("iconpickerShow", {
                iconpickerValue: this.iconpickerValue
            });
            this.updatePlacement();
            this.popover.addClass("in");
            setTimeout(a.proxy(function() {
                this.popover.css("display", this.isInline() ? "" : "block");
                this._trigger("iconpickerShown", {
                    iconpickerValue: this.iconpickerValue
                });
            }, this), this.options.animation ? 300 : 1);
        },
        hide: function() {
            if (!this.popover.hasClass("in")) {
                return false;
            }
            this._trigger("iconpickerHide", {
                iconpickerValue: this.iconpickerValue
            });
            this.popover.removeClass("in");
            setTimeout(a.proxy(function() {
                this.popover.css("display", "none");
                this.getSearchInput().val("");
                this.filter("");
                this._trigger("iconpickerHidden", {
                    iconpickerValue: this.iconpickerValue
                });
            }, this), this.options.animation ? 300 : 1);
        },
        toggle: function() {
            if (this.popover.is(":visible")) {
                this.hide();
            } else {
                this.show(true);
            }
        },
        update: function(a, b) {
            a = a ? a : this.getSourceValue(this.iconpickerValue);
            this._trigger("iconpickerUpdate", {
                iconpickerValue: this.iconpickerValue
            });
            if (b === true) {
                a = this.setValue(a);
            } else {
                a = this.setSourceValue(a);
                this._updateFormGroupStatus(a !== false);
            }
            if (a !== false) {
                this._updateComponents();
            }
            this._trigger("iconpickerUpdated", {
                iconpickerValue: this.iconpickerValue
            });
            return a;
        },
        destroy: function() {
            this._trigger("iconpickerDestroy", {
                iconpickerValue: this.iconpickerValue
            });
            this.element.removeData("iconpicker").removeData("iconpickerValue").removeClass("iconpicker-element");
            this._unbindElementEvents();
            this._unbindWindowEvents();
            a(this.popover).remove();
            this._trigger("iconpickerDestroyed", {
                iconpickerValue: this.iconpickerValue
            });
        },
        disable: function() {
            if (this.hasInput()) {
                this.input.prop("disabled", true);
                return true;
            }
            return false;
        },
        enable: function() {
            if (this.hasInput()) {
                this.input.prop("disabled", false);
                return true;
            }
            return false;
        },
        isDisabled: function() {
            if (this.hasInput()) {
                return this.input.prop("disabled") === true;
            }
            return false;
        },
        isInline: function() {
            return this.options.placement === "inline" || this.popover.hasClass("inline");
        }
    };
    a.iconpicker = c;
    a.fn.iconpicker = function(b) {
        return this.each(function() {
            var d = a(this);
            if (!d.data("iconpicker")) {
                d.data("iconpicker", new c(this, typeof b === "object" ? b : {}));
            }
        });
    };
    c.defaultOptions = a.extend(c.defaultOptions);
});
