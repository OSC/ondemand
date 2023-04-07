'use strict';

const pollers = [];

class Timer {
  constructor(callback, delay){
    this.delay = delay;
    this.remaining = delay;
    this.active = true;
    this.callback = callback;

    this.resume();
  }

  resume() {
    if(!this.active) { return; }

    this.start = new Date();
    this.clearTO();
    this.timerId = setTimeout(this.callback, this.remaining);
  }

  restart() {
    if(!this.active) { return; }

    this.remaining = this.delay;
    resume();
  }

  pause() {
    if(!this.active) { return; }

    this.clearTO();
    this.remaining -= new Date() - this.start;
  }

  stop(){
    if(!this.active) { return; }
    this.clearTO();
    this.active = false;
  }

  clearTO(){
    if(this.timerId !== undefined) {
      clearTimeout(this.timerId);
    }
  }

}

class Poller {
  constructor(url, delay) {
    this.url = url;
    this.delay = delay;
    this.poll();
  }

  poll(){
    this.timer = new Timer(this.request.bind(this), this.delay);
  }

  pause() {
    this.timer.pause();
  }

  resume() {
    this.timer.resume();
  }

  request(){
    const that = this;
    $.getScript(this.url)
        .done((_script, _textStatus, _jqxhr) => {
          return;
        }).fail((_jqxhr, textStatus, errorThrown) => {
      if(textStatus) { console.log(`Failed to get session data. Server returned '${textStatus}'`); }
      if(errorThrown) {
        console.log("Failed to get session data because of error.");
        console.log(errorThrown);
      }
      return;
    }).always(() => {
      that.poll();
      return;
    });
  }
}

function makePollers(){
  const obj = $('#batch_connect_sessions');
  if(!obj) return;

  const url = obj.data('url');
  const delay = obj.data('delay');
  if(url && delay) { pollers.push(new Poller(url, delay)); }

  $(document)
      .on('show.bs.modal', () => {
        pollers.forEach((poller) => {
          poller.pause();
        });
      }).on('hidden.bs.modal', () => {
    pollers.forEach((poller) => {
      poller.resume();
    });
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
  function showSpinner() {
    $('body').addClass('modal-open');
    $('#full-page-spinner').removeClass('d-none');
  }

  makePollers();

  $('button.relaunch').each((index, element) => {
    $(element).on('click', showSpinner);
  });
});
