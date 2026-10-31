import { nsfAccessCurrentOutagesUrl, nsfAccessFutureOutagesUrl } from './config';
import { fetchNsfAccessJson, mountNsfAccessAccordion } from './nsf_access_widget';

document.addEventListener('DOMContentLoaded', () => {
  listOutages();
});

function listOutages() {
  getOutages()
    .then(outages => {
      mountNsfAccessAccordion({
        elementId: 'nsf_access_outages',
        getContainerId: () => 'nsf_access_outages_container',
        items: outages,
        getIdPrefix: () => 'nsf_access_outage',
        getItemId: (outage) => outageId(outage),
        getTitle: (outage) => `${outage['Subject']} (${outage['OutageType']})`,
        getDate: (outage) => outage['OutageStart'],
        getBodyHtml: (outage) => outageBodyHtml(outage),
        getLink: () => null,
      });
    });
}

function getOutages() {
  return Promise.all([
    fetchOutages(nsfAccessCurrentOutagesUrl()),
    fetchOutages(nsfAccessFutureOutagesUrl())
  ]).then(([currentOutages, futureOutages]) => {
    const outages = currentOutages.concat(futureOutages);

    return outages.sort((a, b) => {
      return new Date(a['OutageStart']) - new Date(b['OutageStart']);
    });
  });
}

function fetchOutages(url) {
  if (!url) {
    return Promise.resolve([]);
  }

  return fetchNsfAccessJson(url, { cacheControl: false })
    .then(data => (data && data['results']) || []);
}

function outageId(outage) {
  return outage['URN'].split(':').pop();
}

function outageBodyHtml(outage) {
  let html = outage['Content'] || '';
  const resources = outage['AffectedResources'] || [];

  if(resources.length > 0) {
    const resourceIds = resources.map((resource) => resource['ResourceID']).join(', ');
    html += `<p class="ps-4">Affected Resources: ${resourceIds}</p>`;
  }

  return html;
}
