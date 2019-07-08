<a href="http://promises-aplus.github.com/promises-spec">
    <img src="http://promises-aplus.github.com/promises-spec/assets/logo-small.png"
         align="right" alt="Promises/A+ logo" />
</a>
# Promise
[![travis][travis-image]][travis-url]

[travis-image]: https://img.shields.io/travis/taylorhakes/promise-polyfill.svg?style=flat
[travis-url]: https://travis-ci.org/taylorhakes/promise-polyfill


Lightweight ES6 Promise polyfill for the browser and node. Adheres closely to the spec. It is a perfect polyfill IE, Firefox or any other browser that does not support native promises.

This implementation is based on [then/promise](https://github.com/then/promise). It has been changed to use the prototype for performance and memory reasons.

For API information about Promises, please check out this article [HTML5Rocks article](http://www.html5rocks.com/en/tutorials/es6/promises/).

It is extremely lightweight. ***< 1kb Gzipped***

## Browser Support
IE8+, Chrome, Firefox, IOS 4+, Safari 5+, Opera

## Downloads

- [Promise](https://raw.github.com/taylorhakes/promise-polyfill/master/Promise.js)
- [Promise-min](https://raw.github.com/taylorhakes/promise-polyfill/master/Promise.min.js)

### Node
```
npm install promise-polyfill
```
### Bower
```
bower install promise-polyfill
```

## Simple use
```
var prom = new Promise(function(resolve, reject) {
  // do a thing, possibly async, then…

  if (/* everything turned out fine */) {
    resolve("Stuff worked!");
  }  else {
    reject(new Error("It broke"));
  }
});

// Do something when async done
prom.then(function() {
  ...
});
```

## Performance
By default promise-polyfill uses `setImmediate`, but falls back to `setTimeout` for executing asynchronously. If a browser does not support `setImmediate` (IE/Edge are the only browsers with setImmediate), you may see performance issues.
Use a `setImmediate` polyfill to fix this issue. [setAsap](https://github.com/taylorhakes/setAsap) or [setImmediate](https://github.com/YuzuJS/setImmediate) work well.

If you polyfill `window.setImmediate` or use `Promise._setImmediateFn(immedateFn)` it will be used instead of `window.setTimeout`
```
npm install setasap --save
```
```js
var Promise = require('promise-polyfill');
var setAsap = require('setasap');
Promise._setImmedateFn(setAsap);
```

## Unhandled Rejections
promise-polyfill will warn you about possibly unhandled rejections. It will show a console warning if a Promise is rejected, but no `.catch` is used. You can turn off this behavior by setting `Promise._setUnhandledRejectionFn(<rejectError>)`.
If you would like to disable unhandled rejections. Use a noop like below.
```js
Promise._setUnhandledRejectionFn(function(rejectError) {});
```


## Testing
```
npm install
npm test
```

## License
MIT
