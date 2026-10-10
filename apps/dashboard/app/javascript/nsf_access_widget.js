export function fetchNsfAccessJson(url) {
  return fetch(url, {
            headers: {
              'Cache-Control': 'max-age=604800'
            }
          })
            .then(response => response.ok ? Promise.resolve(response) : Promise.reject(new Error(response)))
            .then(response => { return response.json() })
            .catch((err) => {
              // TODO: put error in HTML div
              console.log('Cannot get NSF Access details due to error:');
              console.log(err);
            });
}

export function mountNsfAccessAccordion({
  elementId,
  containerId,
  items,
  idPrefix,
  getItemId,
  getTitle,
  getDate,
  getBodyHtml,
  getLink,
}) {
  const container = document.createElement('div');
  container.classList.add('accordion');
  container.id = containerId;

  for (const item of items || []) {
    container.appendChild(itemToElement(item, {
      containerId,
      idPrefix,
      getItemId,
      getTitle,
      getDate,
      getBodyHtml,
      getLink,
    }));
  }

  const ele = document.getElementById(elementId);

  // reset the element
  ele.innerHTML = null;
  ele.classList.remove('spinner-border');
  ele.role = null;

  ele.appendChild(container);
}

function itemToElement(item, opts) {
  const element = document.createElement('div');
  element.classList.add('accordion-item');

  element.appendChild(itemHeader(item, opts));
  element.appendChild(itemBody(item, opts));

  return element;
}

function itemHeader(item, opts) {
  const headerId = `${opts.idPrefix}_header_${opts.getItemId(item)}`;
  const bodyId = `${opts.idPrefix}_body_${opts.getItemId(item)}`;

  const header = document.createElement('div');
  header.classList.add('h5', 'accordion-header');
  header.id = headerId;

  const button = document.createElement('button');
  button.classList.add('accordion-button', 'collapsed');
  button.role = 'button';
  button.dataset.bsToggle = 'collapse';
  button.dataset.bsTarget = `#${bodyId}`;

  const date = new Date(opts.getDate(item)).toDateString();
  button.textContent = `${opts.getTitle(item)} - ${date}`;

  button.setAttribute('aria-expanded', false);
  button.setAttribute('aria-controls', bodyId);

  header.appendChild(button);

  return header;
}

function itemBody(item, opts) {
  const headerId = `${opts.idPrefix}_header_${opts.getItemId(item)}`;
  const bodyId = `${opts.idPrefix}_body_${opts.getItemId(item)}`;

  const wrapper = document.createElement('div');
  wrapper.classList.add('accordion-collapse', 'collapse');
  wrapper.id = bodyId;
  wrapper.setAttribute('aria-labelledby', headerId);
  wrapper.dataset.bsParent = `${opts.containerId}`;

  const body = document.createElement('div');
  body.classList.add('accordion-body');
  // TODO: sanitize this so there's no potentially malicious tags.
  body.innerHTML = opts.getBodyHtml(item);

  wrapper.appendChild(body);
  wrapper.appendChild(linkElement(opts.getLink(item)));

  return wrapper;
}

function linkElement(link) {
  const p = document.createElement('p');
  p.classList.add('ps-4');

  if(link !== undefined && link !== null && link.href !== undefined && link.href !== "") {
    const a = document.createElement('a');

    a.href = link.href;
    a.innerText = link.text;
    p.appendChild(a);
  }

  return p;
}
