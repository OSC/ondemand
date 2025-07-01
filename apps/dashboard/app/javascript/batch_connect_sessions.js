'use strict';

import { bcIndexUrl, bcPollDelay } from './config';
import { bindFullPageSpinnerEvent, ariaNotify, pushNotify, show, hide } from './utils';
import { pollAndReplace } from './turbo_shim';

const EXPIRATION_NOTIFIED_KEY = "expiration_notified";
const sessions = new Map();
const notifiedSessionIds = new Set(getNotifiedSessionIds());

function getNotifiedSessionIds() {
  return JSON.parse(localStorage.getItem(EXPIRATION_NOTIFIED_KEY)) || [];
}

function setNotifiedSessionIds(sessions) {
  localStorage.setItem(EXPIRATION_NOTIFIED_KEY, JSON.stringify(sessions));
}

function pruneNotifiedSessionIds() {
  const currentNotifiedIds = []

  notifiedSessionIds.forEach((sessionId) => {
    if (sessions.has(sessionId)) {
      currentNotifiedIds.push(sessionId);
    }
  });

  setNotifiedSessionIds(currentNotifiedIds);
}

function checkStatusChanges() {
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
      pushNotify(`${sessionTitle} (${jobId}) is now ${currentStatus}.`, {
        tag: `session-${sessionId}`,
      });
    }

    // TODO: Add config option
    const expWarnThreshold = 15;

    const minutesRemaining = parseInt(card.dataset.minutesRemaining) || 0;
    if (minutesRemaining <= expWarnThreshold && minutesRemaining > 0 && !session.expNotified) {
      pushNotify(`Warning: ${sessionTitle} (${jobId}) expires in ~${minutesRemaining} minutes!`, {
        tag: `session-${sessionId}`,
      });
      session.expNotified = true;
      notifiedSessionIds.add(sessionId);
      setNotifiedSessionIds([...notifiedSessionIds]);
    }
  });
}

function settingKey(id) {
  return id + '_value';
}

function storeSetting(event) {
  var key = settingKey(event.currentTarget.id);
  var value = event.currentTarget.value;

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
  if ('Notification' in window && Notification.permission === 'default') {
    show('notification_banner');
  }

  const enableNotifsBtn = document.getElementById('enable_notifications');
  if (enableNotifsBtn) {
    enableNotifsBtn.addEventListener('click', function () {
      Notification.requestPermission().then((permission) => {
        if (permission === 'granted') {
          hide('notification_banner');
          pushNotify('Notifications enabled for interactive sessions.');
        }
      });
    });
  }

  if (document.getElementById('batch_connect_sessions')) {
    pollAndReplace(bcIndexUrl(), bcPollDelay(), "batch_connect_sessions", () => {
      bindFullPageSpinnerEvent();
      checkStatusChanges();
    });
  }

  pruneNotifiedSessionIds();
});
