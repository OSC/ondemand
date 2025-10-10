document.addEventListener('DOMContentLoaded', () => {
  listEvents();
});

// TODO: make this configurable
const eventsAPI = "https://support.access-ci.org/api/2.1/events";

function listEvents() {
  getEvents()
    .then(events => { 
      const container = eventsContainer();

      fillContainer(container, events);
      const ele = document.getElementById('nsf_access_events');
      ele.appendChild(container);
    });
}

function fillContainer(container, events) {
  const list = container.querySelector('ul');
  for (const event of events) {
    const listItem = eventToElement2(event);
    list.appendChild(listItem);
  }
}

function eventsContainer() {
  const container = document.createElement('div');
  container.classList.add('card');

  const header = document.createElement('div');
  header.classList.add('card-header');
  header.textContent = "NSF ACCESS Events";

  list = document.createElement('ul');
  list.classList.add('list-group');

  body = document.createElement('div');
  body.classList.add('card-body');
  body.appendChild(list);

  container.appendChild(header);
  container.appendChild(body);

  return container;
}

function getEvents() {
  return fetch(eventsAPI, {
            headers: {
              'Cache-Control': 'max-age=604800'
            }
          })
            .then(response => response.ok ? Promise.resolve(response) : Promise.reject(new Error(response)))
            .then(response => { return response.json() })
            .catch((err) => {
              // TODO: put error in HTML div
              console.log('Cannot not NSF Access event details due to error:');
              console.log(err);
            });
}

function filterEvents(events) {
  const now = Date.now();
  const timeFiltered = events.filter((event) => {
    const eventDate = new Date(event['date']);
    return eventDate > now;
  });

  // map them to keys to filter out unique events.
  const mapped = new Map(timeFiltered.map((item) => {
    key = `${item['date']}_${item['title']}`;
    return [key, item];
  }));

  return mapped.values();
}

function eventToElement(event) {
  const li = document.createElement('li');
  li.classList.add('list-group-item');
  li.innerHTML = event['description'];

  return li;
}

//   <a class="btn btn-primary" data-toggle="collapse" href="#collapseExample" role="button" aria-expanded="false" aria-controls="collapseExample">
// Link with href
// </a>
function eventToElement2(event) {
  const li = document.createElement('li');
  li.classList.add('list-group-item');

  const contentId = `nsf_access_event_${event['id']}`;

  const title = document.createElement('a');
  title.textContent = event['title'];
  title.dataset.bsToggle = 'collapse';
  title.href = `#${contentId}`;
  title.role = 'button';
  title.classList.add('btn', 'btn-primary');
  title.ariaExpanded = false;
  title.setAttribute('aria-expanded', false);
  title.setAttribute('aria-controls', contentId);

  const date = document.createElement('span');
  date.textContent = new Date(event['date']).toDateString();
  date.classList.add('mx-2', 'd-flex');

  const content = document.createElement('div');
  content.id = contentId;
  // TODO: sanitize this so there's no potentially malicous tags.
  content.innerHTML = event['description'];
  content.classList.add('collapse');

  li.appendChild(title);
  li.appendChild(date);
  li.appendChild(content);

  return li;
}