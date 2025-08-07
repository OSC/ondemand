import { getBoolean, storeBoolean } from '../utils';
import { OODAlert }from '../alert';

export function notificationsEnabled() {
  return getBoolean('ood_notifications_enabled');
}

export function getNotifiedSessionIds() {
  return JSON.parse(localStorage.getItem('expiration_notified')) || [];
}

export function storeNotifiedSessionIds(sessions) {
  localStorage.setItem('expiration_notified', JSON.stringify(sessions));
}

export function pruneNotifiedSessionIds(sessions, notifiedSessionIds) {
  const currentNotifiedIds = []

  notifiedSessionIds.forEach((sessionId) => {
    if (sessions.has(sessionId)) {
      currentNotifiedIds.push(sessionId);
    }
  });

  storeNotifiedSessionIds(currentNotifiedIds);
}

export function setupNotificationToggle(toggleElementId) {
  const notifToggleBtn = document.getElementById(toggleElementId);
  if (!notifToggleBtn) return;

  if (!('Notification' in window) || Notification.permission !== 'granted') {
    notifToggleBtn.checked = false;
  } else {
    notifToggleBtn.checked = getBoolean('ood_notifications_enabled');
  }
  storeBoolean('ood_notifications_enabled', notifToggleBtn.checked);

  notifToggleBtn.addEventListener('change', async (event) => {
    if (Notification.permission !== 'granted') {
      try {
        const permission = await Notification.requestPermission();
        if (permission !== 'granted') {
          event.target.checked = false;
          OODAlert('Please allow notification permissions in your browser to enable session alerts.');
        }
      } catch (error) {
        OODAlert('Error requesting notification permission:', error);
      }
    }
    storeBoolean('ood_notifications_enabled', event.target.checked);
  });
}
