export function notificationsEnabled() {
  return localStorage.getItem('ood_notifications_enabled') === 'true' || false;
}

export function storeNotificationsEnabled(enabled) {
  localStorage.setItem('ood_notifications_enabled', enabled ? 'true' : 'false');
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
    notifToggleBtn.checked = notificationsEnabled();
  }

  notifToggleBtn.addEventListener('change', async (event) => {
    if (Notification.permission !== 'granted') {
      const permission = await Notification.requestPermission();
      if (permission !== 'granted') {
        event.currentTarget.checked = false;
      }
    }
    storeNotificationsEnabled(event.currentTarget.checked);
  });
}
