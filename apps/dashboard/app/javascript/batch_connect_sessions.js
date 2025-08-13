'use strict';

import { bcIndexUrl, bcPollDelay } from './config';
import { bindFullPageSpinnerEvent } from './utils';
import { pollAndReplace } from './turbo_shim';
import { ariaNotify } from './aria_live_notify';

const sessionStatusMap = new Map();

function getPollDelay() {
  const bcSessionsContainer = document.getElementById('bc_sessions_content');
  if (!bcSessionsContainer) return bcPollDelay();

  const delayAttr = bcSessionsContainer.dataset.pollDelay;
  return delayAttr !== undefined ? parseInt(delayAttr, 10) : null;
}

function checkStatusChanges() {
  const sessionCards = document.querySelectorAll('[data-bc-card]');
  
  sessionCards.forEach((card) => {
    const sessionId = card.dataset.id;
    const newStatus = card.dataset.status;

    if(sessionStatusMap.has(sessionId)) {
      const oldStatus = sessionStatusMap.get(sessionId);
      if(oldStatus !== newStatus) {
        sessionStatusMap.set(sessionId, newStatus);
        const sessionTitle = card.dataset.title;
        ariaNotify(`${sessionTitle} is now ${newStatus}.`);
      }
    } else {
      sessionStatusMap.set(sessionId, newStatus);
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
  const bcSessionsContainer = document.getElementById('batch_connect_sessions');
  if (bcSessionsContainer) {
    pollAndReplace(bcIndexUrl(), getPollDelay, "batch_connect_sessions", () => {
      bindFullPageSpinnerEvent();
      checkStatusChanges();
    });
  }
});
