
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