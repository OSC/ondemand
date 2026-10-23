document.addEventListener('DOMContentLoaded', () => {
  listOutages();
});

// TODO: make these configurable
const currentOutagesAPI = "https://operations-api.access-ci.org/wh2/news/v1/affiliation/access-ci.org/current_outages/";
const futureOutagesAPI = "https://operations-api.access-ci.org/wh2/news/v1/affiliation/access-ci.org/future_outages/";

function listOutages() {
  getOutages()
    .then(outages => {
      const container = outagesContainer();

      fillOutagesContainer(container, outages);
      const ele = document.getElementById('nsf_access_outages');

      // reset the element
      ele.innerHTML = null;
      ele.classList.remove('spinner-border');
      ele.role = null;

      ele.appendChild(container);
    });
}

function fillOutagesContainer(container, outages) {
  for (const outage of outages) {
    const listItem = outageToElement(outage);
    container.appendChild(listItem);
  }
}

function outagesContainer() {
  const container = document.createElement('div');
  container.classList.add('accordion');
  container.id = outagesWidgetId();
  
  return container;
}

function getOutages() {
  return Promise.all([
    fetchOutages(currentOutagesAPI),
    fetchOutages(futureOutagesAPI)
  ]).then(([currentOutages, futureOutages]) => {
    const outages = currentOutages.concat(futureOutages);

    return outages.sort((a, b) => {
      return new Date(a['OutageStart']) - new Date(b['OutageStart']);
    });
  });
}

function fetchOutages(url) {
  return fetch(url)
            .then(response => response.ok ? Promise.resolve(response) : Promise.reject(new Error(response)))
            .then(response => { return response.json() })
            .then(data => data['results'] || [])
            .catch((err) => {
              // TODO: put error in HTML div
              console.log('Cannot get NSF Access outage details due to error:');
              console.log(err);
              return [];
            });
}

function outageToElement(outage) {
  const element = document.createElement('div');
  element.classList.add('accordion-item');

  element.appendChild(outageHeader(outage));
  element.appendChild(outageBody(outage));

  return element;
}

function outageHeader(outage) {
  const header = document.createElement('div');
  header.classList.add('h5', 'accordion-header');
  header.id = outageHeaderId(outage);

  const button = document.createElement('button');
  button.classList.add('accordion-button', 'collapsed');
  button.role = 'button';
  button.dataset.bsToggle = 'collapse';
  button.dataset.bsTarget = `#${outageBodyId(outage)}`;

  const date = new Date(outage['OutageStart']).toDateString();
  button.textContent = `${outage['Subject']} (${outage['OutageType']}) - ${date}`;

  button.setAttribute('aria-expanded', false);
  button.setAttribute('aria-controls', outageBodyId(outage));

  header.appendChild(button);

  return header;
}

function outageBody(outage) {
  const wrapper = document.createElement('div');
  wrapper.classList.add('accordion-collapse', 'collapse');
  wrapper.id = outageBodyId(outage);
  wrapper.setAttribute('aria-labelledby', outageHeaderId(outage));
  wrapper.dataset.bsParent = `${outagesWidgetId()}`;
  
  const body = document.createElement('div');
  body.classList.add('accordion-body');
  // TODO: sanitize this so there's no potentially malicious tags.
  body.innerHTML = outage['Content'];

  wrapper.appendChild(body);
  wrapper.appendChild(affectedResourcesElement(outage));

  return wrapper;
}

function affectedResourcesElement(outage) {
  const resources = outage['AffectedResources'] || [];
  const p = document.createElement('p');
  p.classList.add('ps-4');

  if(resources.length > 0) {
    const resourceIds = resources.map((resource) => resource['ResourceID']).join(', ');
    p.textContent = `Affected Resources: ${resourceIds}`;
  }

  return p;
}

function outagesWidgetId() {
  return 'nsf_access_outages_container';
}

function outageId(outage) {
  // URN format: urn:ogf.org:glue2:operations.access-ci.org:news:1011
  return outage['URN'].split(':').pop();
}

function outageBodyId(outage) {
  return `nsf_access_outage_body_${outageId(outage)}`;
}

function outageHeaderId(outage) {
  return `nsf_access_outage_header_${outageId(outage)}`;
}
