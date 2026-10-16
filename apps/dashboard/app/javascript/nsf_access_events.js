import { nsfAccessEventsUrl } from './config';
import { fetchNsfAccessJson, mountNsfAccessAccordion } from './nsf_access_widget';

document.addEventListener('DOMContentLoaded', () => {
  listEvents();
});

function listEvents() {
  fetchNsfAccessJson(nsfAccessEventsUrl())
    .then(events => {
      mountNsfAccessAccordion({
        elementId: 'nsf_access_events',
        containerId: 'nsf_access_events_container',
        items: filterEvents(events),
        idPrefix: 'nsf_access_event',
        getItemId: (event) => event['id'],
        getTitle: (event) => event['title'],
        getDate: (event) => event['date'],
        getBodyHtml: (event) => event['description'],
        getLink: (event) => {
          const registration = event['registration'];
          if(registration !== undefined && registration !== "") {
            return { href: registration, text: 'Register for this event' };
          }

          return null;
        },
      });
    });
}

function filterEvents(events) {
  if (!events) {
    return [];
  }

  const now = new Date();
  const futureLimit = new Date();
  futureLimit.setMonth(futureLimit.getMonth() + 1);

  return events.filter((event) => {
    const eventDate = new Date(event['date']);
    return eventDate > now && eventDate < futureLimit;
  })
}
