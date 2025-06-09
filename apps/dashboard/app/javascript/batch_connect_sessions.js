'use strict';

import { bcIndexUrl, bcPollDelay } from './config';
import { bindFullPageSpinnerEvent, ariaNotify, pushNotify } from './utils';
import { pollAndReplace } from './turbo_shim';

const sessionStats = new Map();

function checkStatusChanges() {
  const sessionCards = document.querySelectorAll('[data-bc-card]');
  
  sessionCards.forEach((card) => {
    const sessionTitle = card.dataset.title;
    const sessionId = card.dataset.id;
    const jobId = card.dataset.jobId;
    const currentStatus = card.dataset.status;

    if(!sessionStats.has(sessionId)) {
      sessionStats.set(sessionId, {
        status: currentStatus,
        notified15: false,
      });
    }

    const session = sessionStats.get(sessionId);

    if (session.status !== currentStatus) {
      session.status = currentStatus;
      ariaNotify(`${sessionTitle} is now ${currentStatus}.`);
      pushNotify(`${sessionTitle} (${jobId}) is now ${currentStatus}.`, {
        tag: `session-${sessionId}`,
      });
    }

    const minutesRemaining = parseInt(card.dataset.minutesRemaining);
    if (minutesRemaining <= 15 && !session.notified15) {
      pushNotify(`Warning: ${sessionTitle} (${jobId}) expires in ~${minutesRemaining} minutes!`, {
        tag: 'session-${sessionId}',
      });
      session.notified15 = true;
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

jQuery(function (){
  if ('Notification' in window && Notification.permission === 'default') {
    Notification.requestPermission();
  }
  if ($('#batch_connect_sessions').length) {
    pollAndReplace(bcIndexUrl(), bcPollDelay(), "batch_connect_sessions", () => {
      bindFullPageSpinnerEvent();
      checkStatusChanges();
    });
  }
});
