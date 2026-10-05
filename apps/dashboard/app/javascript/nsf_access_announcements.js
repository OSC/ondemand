document.addEventListener('DOMContentLoaded', () => {
  listAnnouncements();
});

// TODO: make this configurable
const announcementsAPI = "https://support.access-ci.org/api/2.2/announcements";

function listAnnouncements() {
  getAnnouncements()
    .then(announcements => {
      const filteredAnnouncements = filterAnnouncements(announcements);
      const container = announcementsContainer();

      fillContainer(container, filteredAnnouncements);
      const ele = document.getElementById('nsf_access_announcements');

      // reset the element
      ele.innerHTML = null;
      ele.classList.remove('spinner-border');
      ele.role = null;

      ele.appendChild(container);
    });
}

function fillContainer(container, announcements) {
  for (const announcement of announcements) {
    const listItem = announcementToElement(announcement);
    container.appendChild(listItem);
  }
}

function announcementsContainer() {
  const container = document.createElement('div');
  container.classList.add('accordion');
  container.id = widgetId();

  return container;
}

function getAnnouncements() {
  return fetch(announcementsAPI, {
            headers: {
              'Cache-Control': 'max-age=604800'
            }
          })
            .then(response => response.ok ? Promise.resolve(response) : Promise.reject(new Error(response)))
            .then(response => { return response.json() })
            .catch((err) => {
              // TODO: put error in HTML div
              console.log('Cannot get NSF Access announcement details due to error:');
              console.log(err);
            });
}

function filterAnnouncements(announcements) {
  const pastLimit = new Date();
  pastLimit.setMonth(pastLimit.getMonth() - 1);

  return announcements.filter((announcement) => {
    const publishedDate = new Date(announcement['published_date']);
    return publishedDate > pastLimit;
  })
}

function announcementToElement(announcement) {
  const element = document.createElement('div');
  element.classList.add('accordion-item');

  element.appendChild(announcementHeader(announcement));
  element.appendChild(announcementBody(announcement));

  return element;
}

function announcementHeader(announcement) {
  const header = document.createElement('div');
  header.classList.add('h5', 'accordion-header');
  header.id = announcementHeaderId(announcement);

  const button = document.createElement('button');
  button.classList.add('accordion-button', 'collapsed');
  button.role = 'button';
  button.dataset.bsToggle = 'collapse';
  button.dataset.bsTarget = `#${announcementBodyId(announcement)}`;

  const date = new Date(announcement['published_date']).toDateString();
  button.textContent = `${announcement['title']} - ${date}`;

  button.setAttribute('aria-expanded', false);
  button.setAttribute('aria-controls', announcementBodyId(announcement));

  header.appendChild(button);

  return header;
}

function announcementBody(announcement) {
  const wrapper = document.createElement('div');
  wrapper.classList.add('accordion-collapse', 'collapse');
  wrapper.id = announcementBodyId(announcement);
  wrapper.setAttribute('aria-labelledby', announcementHeaderId(announcement));
  wrapper.dataset.bsParent = `${widgetId()}`;

  const body = document.createElement('div');
  body.classList.add('accordion-body');
  // TODO: sanitize this so there's no potentially malicious tags.
  body.innerHTML = announcement['body'];

  wrapper.appendChild(body);
  wrapper.appendChild(readMoreElement(announcement));

  return wrapper;
}

function widgetId() {
  return 'nsf_access_announcements_container';
}

function announcementBodyId(announcement) {
  return `nsf_access_announcement_body_${announcement['uuid']}`;
}

function announcementHeaderId(announcement) {
  return `nsf_access_announcement_header_${announcement['uuid']}`;
}

function readMoreElement(announcement) {
  const url = announcement['url'];
  const p = document.createElement('p');
  p.classList.add('ps-4');

  if(url !== undefined && url !== "") {
    const a = document.createElement('a');

    a.href = url;
    a.innerText = 'Read more';
    p.appendChild(a);
  }

  return p;
}
