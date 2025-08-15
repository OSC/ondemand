'use strict';

import { bcIndexUrl, bcPollDelay } from './config';
import { bindFullPageSpinnerEvent, ariaNotify, pushNotify } from './utils';
import { pollAndReplace } from './turbo_shim';
import { 
  notificationsEnabled, getNotifiedSessionIds, storeNotifiedSessionIds, 
  pruneNotifiedSessionIds, setupNotificationToggle,
} from './batch_connect/bc_notifications';

function withinWarnLimit(minutesRemaining, threshold) {
  return minutesRemaining <= threshold && minutesRemaining > 0;
}

function checkStatusChanges(sessions, notifiedSessionIds) {
  const sessionCards = document.querySelectorAll('[data-bc-card]');
  const notificationsOn = notificationsEnabled();

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
      if (notificationsOn) {
        pushNotify(`${sessionTitle} (${jobId}) is now ${currentStatus}.`, {
          tag: `session-${sessionId}`,
        });
      }
    }

    // TODO: Add config option
    const expWarnThreshold = 15;

    const minutesRemaining = parseInt(card.dataset.minutesRemaining, 10) || 0;
    if (notificationsOn && withinWarnLimit(minutesRemaining, expWarnThreshold) && !session.expNotified) {
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
  setupNotificationToggle('notification_toggle');
  const sessions = new Map();
  const notifiedSessionIds = new Set(getNotifiedSessionIds());

  if (document.getElementById('batch_connect_sessions')) {
    pollAndReplace(bcIndexUrl(), bcPollDelay(), "batch_connect_sessions", () => {
      bindFullPageSpinnerEvent();
      checkStatusChanges(sessions, notifiedSessionIds);
    });
  }

  pruneNotifiedSessionIds(sessions, notifiedSessionIds);
});
