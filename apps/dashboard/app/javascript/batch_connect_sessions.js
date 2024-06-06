'use strict';

import { bcIndexUrl, bcPollDelay } from './config';
import { pollAndReplace } from './turbo_shim';

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
  function showSpinner() {
    $('body').addClass('modal-open');
    $('#full-page-spinner').removeClass('d-none');
  }

  pollAndReplace(bcIndexUrl(), bcPollDelay(), "batch_connect_sessions");

  $('button.relaunch').each((index, element) => {
    $(element).on('click', showSpinner);
  });
});
