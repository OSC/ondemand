
/*
  While we want Turbo enabled at some point,
  it doesn't really work well yet. So, we'll provide
  this shim until we enable it.
*/

export function replaceHTML(id, html) {
  const ele = document.getElementById(id);

  if(ele == null){
    return;
  } else {
    var tmp = document.createElement('div');
    tmp.innerHTML = html;
    const newHTML = tmp.querySelector('template').innerHTML;
    tmp.remove();

    ele.innerHTML = newHTML;
  }
}

export function pollAndReplace(url, delay, id, callback) {
  fetch(url, { headers: { Accept: "text/vnd.turbo-stream.html" } })
    .then(response => response.ok ? Promise.resolve(response) : Promise.reject(response.text()))
    .then((r) => r.text())
    .then((html) => replaceHTML(id, html))
    .then(() => {
      setTimeout(pollAndReplace, delay, url, delay, id, callback);
      if (typeof callback == 'function') {
        callback();
      }
    })
    .catch((err) => {
      console.log('Cannot retrieve partial due to error:');
      console.log(err);
    });
}
