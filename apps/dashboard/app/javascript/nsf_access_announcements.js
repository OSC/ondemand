import { nsfAccessAnnouncementsUrl } from './config';
import { fetchNsfAccessJson, mountNsfAccessAccordion } from './nsf_access_widget';

document.addEventListener('DOMContentLoaded', () => {
  listAnnouncements();
});

function listAnnouncements() {
  fetchNsfAccessJson(nsfAccessAnnouncementsUrl())
    .then(announcements => {
      mountNsfAccessAccordion({
        elementId: 'nsf_access_announcements',
        containerId: 'nsf_access_announcements_container',
        items: filterAnnouncements(announcements),
        idPrefix: 'nsf_access_announcement',
        getItemId: (announcement) => announcement['uuid'],
        getTitle: (announcement) => announcement['title'],
        getDate: (announcement) => announcement['published_date'],
        getBodyHtml: (announcement) => announcement['body'],
        getLink: (announcement) => {
          const url = announcement['url'];
          if(url !== undefined && url !== "") {
            return { href: url, text: 'Read more' };
          }

          return null;
        },
      });
    });
}

function filterAnnouncements(announcements) {
  if (!announcements) {
    return [];
  }

  const pastLimit = new Date();
  pastLimit.setMonth(pastLimit.getMonth() - 1);

  return announcements.filter((announcement) => {
    const publishedDate = new Date(announcement['published_date']);
    return publishedDate > pastLimit;
  })
}
