'use strict';

import { bcIndexUrl, bcPollDelay } from './config';
import { bindFullPageSpinnerEvent, setInnerHTML } from './utils';
import { pollAndReplace } from './turbo_shim';

const sessionStatusMap = new Map();

function checkStatusChanges() {
  const sessionCards = document.querySelectorAll('.card.session-panel');
  
  sessionCards.forEach((card) => {
    const sessionId = card.querySelector('[id^="id_link"]')?.textContent;
    const newStatus = card.querySelector('.status')?.textContent;
    if(!sessionId || !newStatus) return;

    if(sessionStatusMap.has(sessionId)) {
      const oldStatus = sessionStatusMap.get(sessionId);
      if(oldStatus !== newStatus) {
        sessionStatusMap.set(sessionId, newStatus);
        const sessionTitle = card.querySelector('.card_title').textContent
        const liveRegion = document.getElementById("sr-live-region");
        if(liveRegion) {
          setInnerHTML(liveRegion, `${sessionTitle} is now ${newStatus}`);
        }
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

jQuery(function (){
  if ($('#batch_connect_sessions').length) {
    pollAndReplace(bcIndexUrl(), bcPollDelay(), "batch_connect_sessions", () => {
      bindFullPageSpinnerEvent();
      checkStatusChanges();
    });
  }
});
