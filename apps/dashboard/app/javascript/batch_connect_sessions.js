'use strict';

import { bcIndexUrl, bcPollDelay } from './config';
import { bindFullPageSpinnerEvent, ariaNotify, pushNotify, show, hide } from './utils';
import { pollAndReplace } from './turbo_shim';

const EXPIRATION_NOTIFIED_KEY = "expiration_notified";
const sessionStats = new Map();

function getNotifiedSessions() {
  return JSON.parse(localStorage.getItem(EXPIRATION_NOTIFIED_KEY)) || [];
}

function setNotifiedSessions(sessions) {
  localStorage.setItem(EXPIRATION_NOTIFIED_KEY, JSON.stringify(sessions));
}

function pruneNotifiedSessions() {
  const sessionCards = document.querySelectorAll('[data-bc-card]');
  const activeIds = new Set();
  sessionCards.forEach(card => activeIds.add(card.dataset.id));

  const notifiedSessions = getNotifiedSessions();
  const filtered = notifiedSessions.filter(id => activeIds.has(id));
  if (filtered.length !== notifiedSessions.length) {
    setNotifiedSessions(filtered);
  }
}

function checkStatusChanges() {
  const sessionCards = document.querySelectorAll('[data-bc-card]');
  
  sessionCards.forEach((card) => {
    const sessionTitle = card.dataset.title;
    const sessionId = card.dataset.id;
    const jobId = card.dataset.jobId;
    const currentStatus = card.dataset.status;

    if (!sessionStats.has(sessionId)) {
      sessionStats.set(sessionId, currentStatus);
    }

    if (sessionStats.get(sessionId) !== currentStatus) {
      sessionStats.set(sessionId, currentStatus);
      ariaNotify(`${sessionTitle} is now ${currentStatus}.`);
      pushNotify(`${sessionTitle} (${jobId}) is now ${currentStatus}.`, {
        tag: `session-${sessionId}`,
      });
    }

    // TODO: Add config option?
    const expWarnThreshold = 15;

    const minutesRemaining = parseInt(card.dataset.minutesRemaining) || 0;
    if (minutesRemaining <= expWarnThreshold && minutesRemaining > 0) {
      const notifiedSessions = getNotifiedSessions();
      if (!notifiedSessions.includes(sessionId)) {
        pushNotify(`Warning: ${sessionTitle} (${jobId}) expires in ~${minutesRemaining} minutes!`, {
          tag: `session-${sessionId}`,
        });
        notifiedSessions.push(sessionId);
        setNotifiedSessions(notifiedSessions);
      }
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

  const enableBtn = document.getElementById('enable_notifications');
  if (enableBtn) {
    enableBtn.addEventListener('click', function () {
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

  pruneNotifiedSessions();
});
