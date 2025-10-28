document.addEventListener('DOMContentLoaded', () => {
  listEvents();
});

// TODO: make this configurable
const eventsAPI = "https://support.access-ci.org/api/2.1/events";

function listEvents() {
  getEvents()
    .then(events => {
      const filteredEvents = filterEvents(events);
      const container = eventsContainer();

      fillContainer(container, filteredEvents);
      const ele = document.getElementById('nsf_access_events');

      // reset the element
      ele.innerHTML = null;
      ele.classList.remove('spinner-border');
      ele.role = null;

      ele.appendChild(widgetHeader());
      ele.appendChild(container);
    });
}

function fillContainer(container, events) {
  for (const event of events) {
    const listItem = eventToElement(event);
    container.appendChild(listItem);
  }
}

function eventsContainer() {
  const container = document.createElement('div');
  container.classList.add('accordion');
  container.id = widgetId();

  return container;
}

function widgetHeader(){ 
  const header = document.createElement('div');
  header.textContent = 'NSF ACCESS Events';
  header.classList.add('justify-text-center', 'h2', 'd-flex', 'justify-content-start');

  return header;
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
  const now = new Date();
  const futureLimit = new Date();
  futureLimit.setMonth(futureLimit.getMonth() + 1);

  return events.filter((event) => {
    const eventDate = new Date(event['date']);
    return eventDate > now && eventDate < futureLimit;
  })
}

function eventToElement(event) {
  const element = document.createElement('div');
  element.classList.add('accordion-item');

  element.appendChild(eventHeader(event));
  element.appendChild(eventBody(event));

  return element;
}

function eventHeader(event) {
  const header = document.createElement('div');
  header.classList.add('h5', 'accordion-header');
  header.id = eventHeaderId(event);

  const button = document.createElement('button');
  button.classList.add('accordion-button', 'collapsed');
  button.role = 'button';
  button.dataset.bsToggle = 'collapse';
  button.dataset.bsTarget = `#${eventBodyId(event)}`;

  const date = new Date(event['date']).toDateString();
  button.textContent = `${event['title']} - ${date}`;

  button.setAttribute('aria-expanded', false);
  button.setAttribute('aria-controls', eventBodyId(event));

  header.appendChild(button);

  return header;
}

function eventBody(event) {
  const wrapper = document.createElement('div');
  wrapper.classList.add('accordion-collapse', 'collapse');
  wrapper.id = eventBodyId(event);
  wrapper.setAttribute('aria-labelledby', eventHeaderId(event));
  wrapper.dataset.bsParent = `${widgetId()}`;

  const body = document.createElement('div');
  body.classList.add('accordion-body');
  // TODO: sanitize this so there's no potentially malicious tags.
  body.innerHTML = event['description'];

  wrapper.appendChild(body);
  wrapper.appendChild(registerElement(event));

  return wrapper;
}

function widgetId() {
  return 'nsf_access_events_container';
}

function eventBodyId(event) {
  return `nsf_access_event_body_${event['id']}`;
}

function eventHeaderId(event) {
  return `nsf_access_event_header_${event['id']}`;
}

function registerElement(event) {
  const registration = event['registration'];
  const p = document.createElement('p');
  p.classList.add('ps-4');

  if(registration !== undefined && registration !== "") {
    const a = document.createElement('a');

    a.href = registration;
    a.innerText = 'Register for this event';
    p.appendChild(a);
  }

  return p;
}
