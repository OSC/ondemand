'use strict';

import { bcIndexUrl, bcPollDelay } from './config';
import { bindFullPageSpinnerEvent, ariaNotify, pushNotify, show, hide } from './utils';
import { pollAndReplace } from './turbo_shim';

function getNotifiedSessionIds() {
  return JSON.parse(localStorage.getItem('expiration_notified')) || [];
}

function storeNotifiedSessionIds(sessions) {
  localStorage.setItem('expiration_notified', JSON.stringify(sessions));
}

function pruneNotifiedSessionIds(sessions, notifiedSessionIds) {
  const currentNotifiedIds = []

  notifiedSessionIds.forEach((sessionId) => {
    if (sessions.has(sessionId)) {
      currentNotifiedIds.push(sessionId);
    }
  });

  storeNotifiedSessionIds(currentNotifiedIds);
}

function notificationsEnabled() {
  return localStorage.getItem(settingKey('notification_toggle')) === 'true';
}

function withinWarnLimit(minutesRemaining, threshold) {
  return minutesRemaining <= threshold && minutesRemaining > 0;
}

function checkStatusChanges(sessions, notifiedSessionIds, notificationsEnabled) {
  const sessionCards = document.querySelectorAll('[data-bc-card]');
  
  sessionCards.forEach((card) => {
    const sessionTitle = card.dataset.title;
    const sessionId = card.dataset.id;
    const jobId = card.dataset.jobId;
    const currentStatus = card.dataset.status;

    if (!sessions.has(sessionId)) {
      sessions.set(sessionId, {
        status: currentStatus, 
        expNotified: notifiedSessionIds.has(sessionId)
      });
    }

    const session = sessions.get(sessionId);

    if (session.status !== currentStatus) {
      session.status = currentStatus;
      ariaNotify(`${sessionTitle} is now ${currentStatus}.`);
      if (notificationsEnabled) {
        pushNotify(`${sessionTitle} (${jobId}) is now ${currentStatus}.`, {
          tag: `session-${sessionId}`,
        });
      }
    }

    // TODO: Add config option
    const expWarnThreshold = 15;

    const minutesRemaining = parseInt(card.dataset.minutesRemaining, 10) || 0;
    if (notificationsEnabled && withinWarnLimit(minutesRemaining, expWarnThreshold) && !session.expNotified) {
      pushNotify(`Warning: ${sessionTitle} (${jobId}) expires in ~${minutesRemaining} minutes!`, {
        tag: `session-${sessionId}`,
      });
      session.expNotified = true;
      notifiedSessionIds.add(sessionId);
      storeNotifiedSessionIds([...notifiedSessionIds]);
    }
  });
}

function settingKey(id) {
  return id + '_value';
}

function storeSetting(event) {
  var key = settingKey(event.currentTarget.id);
  var value = event.currentTarget.value;

  if (event.currentTarget.type === 'checkbox') {
    value = event.currentTarget.checked;
  }

  localStorage.setItem(key, value);
}

function tryUpdateSetting(name) {
  var saved_value = localStorage.getItem(settingKey(name));

  if(saved_value) {
    var selector = 'input[type="range"][name="' + name + '"]';
    $(selector).val(saved_value);
  }
}

function installSettingHandlers(name) {
  var selector = 'input[type="range"][name="' + name + '"]';
  $(selector).on('change', function(event){
    storeSetting(event);
  });
}

window.installSettingHandlers = installSettingHandlers;
window.tryUpdateSetting = tryUpdateSetting;

document.addEventListener('DOMContentLoaded', function () {
  const notifToggleBtn = document.getElementById('notification_toggle');
  notifToggleBtn.checked = notificationsEnabled();

  if (!('Notification' in window) || Notification.permission !== 'granted') {
    notifToggleBtn.checked = false;
  }

  notifToggleBtn.addEventListener('click', (event) => {
    if (Notification.permission === 'default') {
      event.preventDefault();
      Notification.requestPermission().then((permission) => {
        if (permission === 'granted') {
          notifToggleBtn.checked = true;
          pushNotify('Notifications enabled for interactive sessions', {
            tag: 'notification-toggle',
          });
        } 
      });
    } else if (Notification.permission === 'denied') {
      event.preventDefault();
      notifToggleBtn.checked = false;
    }
  });

  notifToggleBtn.addEventListener('change', (event) => {
    storeSetting(event);
  });

  const sessions = new Map();
  const notifiedSessionIds = new Set(getNotifiedSessionIds());

  if (document.getElementById('batch_connect_sessions')) {
    pollAndReplace(bcIndexUrl(), bcPollDelay(), "batch_connect_sessions", () => {
      bindFullPageSpinnerEvent();
      checkStatusChanges(sessions, notifiedSessionIds, notifToggleBtn.checked);
    });
  }

  pruneNotifiedSessionIds(sessions, notifiedSessionIds);
});
