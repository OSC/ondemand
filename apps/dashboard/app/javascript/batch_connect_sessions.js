'use strict';

import { Tab } from 'bootstrap';
import { bcIndexUrl, bcPollDelay } from './config';
import { bindFullPageSpinnerEvent, ariaNotify, pushNotify } from './utils';
import { pollAndReplace } from './turbo_shim';
import { 
  notificationsEnabled, getNotifiedSessionIds, storeNotifiedSessionIds, 
  pruneNotifiedSessionIds, setupNotificationToggle,
} from './batch_connect/bc_notifications';

const selectedConnectionTabs = new Map();

function trackConnectionTabSelection(container) {
  container.addEventListener('shown.bs.tab', (event) => {
    const tabLink = event.target.closest('.nav-tabs .nav-link');
    const card = tabLink?.closest('[data-bc-card]');
    const href = tabLink?.getAttribute('href');

    if (!tabLink || !card || !href?.startsWith('#')) {
      return;
    }

    if (tabLink.hasAttribute('data-default-tab')) {
      selectedConnectionTabs.delete(card.dataset.id);
      return;
    }

    selectedConnectionTabs.set(card.dataset.id, href);
  });
}

function restoreConnectionTabs() {
  if (!document.querySelector('[data-bc-card]')) {
    selectedConnectionTabs.clear();
    return;
  }
  
  selectedConnectionTabs.forEach((tabTarget, sessionId) => {
    const tabLink = document.querySelector(`#id_${CSS.escape(sessionId)} .nav-tabs .nav-link[href="${tabTarget}"]`);

    if (!tabLink) {
      selectedConnectionTabs.delete(sessionId);
      return;
    }

    if (tabLink.classList.contains('active')) {
      return;
    }

    Tab.getOrCreateInstance(tabLink).show();
  });
}

function continuePolling() {
  const bcSessionsContainer = document.getElementById('bc_sessions_content');
  const shouldPoll = bcSessionsContainer?.dataset.shouldPoll ?? 'true';
  return shouldPoll === 'true';
}

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
  
  const bcSessionsContainer = document.getElementById('batch_connect_sessions');
  if (bcSessionsContainer) {
    trackConnectionTabSelection(bcSessionsContainer);
    pollAndReplace(bcIndexUrl(), bcPollDelay(), "batch_connect_sessions", () => {
      restoreConnectionTabs();
      bindFullPageSpinnerEvent();
      checkStatusChanges(sessions, notifiedSessionIds);
    }, continuePolling);
  }

  pruneNotifiedSessionIds(sessions, notifiedSessionIds);
});
