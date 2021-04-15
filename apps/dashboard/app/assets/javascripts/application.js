// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require data-confirm-modal
//= require handlebars.js/4.4.2/handlebars.min
//= require lodash/4.17.15/lodash.min
//= require uppy/dist/uppy.min
//= require_tree .
//= stub editor

//FIXME: move to coffescript
$(function(){
  $('li.vdi').popover({
    trigger: "hover",
    content: "A VDI (Virtual Desktop Interface) gives you desktop access to a shared node. This is the graphical version of a login node. Use this for lightweight tasks like accessing & viewing files, submitting jobs, and for visualizations.",
    title: function(){ return $(this).text() }
  });

  $('li.ihpc').popover({
    trigger: "hover",
    content: "An Interactive HPC session gives you dedicated access to one or more nodes on the cluster. This is similar to an interactive batch session with an accessible desktop on the primary node. Use this for heavyweight jobs such as long-running compute tasks or where you need dedicated resources.",
    title: function(){ return $(this).text() }
  });
});

$(document).ready(function(){
  $('[data-toggle="popover"]').popover();
});

$(document).ready(function(){
  $('[data-toggle="tooltip"]').tooltip();
});

/**
 * Support persisting noVNC quality settings in localStorage
 **/

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
  $(selector).change(storeSetting);
}


function promiseLoginToXDMoD(xdmodUrl){
  return new Promise(function(resolve, reject){

    var promise_to_receive_message_from_iframe = new Promise(function(resolve, reject){
      window.addEventListener("message", function(event){
        if (event.origin !== xdmodUrl){
          console.log('Received message from untrusted origin, discarding');
          return;
        }
        else if(event.data.application == 'xdmod'){
          if(event.data.action == 'loginComplete'){
            resolve();
          }
            else if(event.data.action == 'error'){
              console.log('ERROR: ' + event.data.info);
              let iframe = document.querySelector("#xdmod_login_iframe");
              reject(new Error(`XDMoD Login iFrame at URL ${iframe && iframe.src} posted error message with info ${event.data.info}`));
          }
        }
      }, false);
    });

    fetch(xdmodUrl + '/rest/auth/idpredirect?returnTo=%2Fgui%2Fgeneral%2Flogin.php')
      .then(response => response.ok ? Promise.resolve(response) : Promise.reject())
      .then(response => response.json())
      .then(function(data){
        return new Promise(function(resolve, reject){
          var xdmodLogin = document.createElement('iframe');
          xdmodLogin.style = 'visibility: hidden; position: absolute;left: -1000px';
          xdmodLogin.id = 'xdmod_login_iframe'
          xdmodLogin.src = data;
          document.body.appendChild(xdmodLogin);
          xdmodLogin.onload = function(){
            resolve();
          }
          xdmodLogin.onerror = function(){
            reject(new Error('Login failed: Failed to load XDMoD login page'));
          }
        });
      })
      .then(() => {
        return Promise.race([promise_to_receive_message_from_iframe, new Promise(function(resolve, reject){
          setTimeout(reject, 5000, new Error('Login failed: Timeout waiting for login to complete'));
        })]);
      })
      .then(() => {
        resolve();
      })
      .catch((e)=> {
        reject(e);
      });
  });
}

var promiseLoggedIntoXDMoD = (function(){
  return _.memoize(function(xdmodUrl){
    return fetch(xdmodUrl + '/rest/v1/users/current', { credentials: 'include' })
      .then((response) => {
        if(response.ok){
          return Promise.resolve(response.json());
        }
        else{
          return promiseLoginToXDMoD(xdmodUrl)
                .then(() => fetch(xdmodUrl + '/rest/v1/users/current', { credentials: 'include' }))
                .then(response => response.json());
        }
      })
      .then((user_data) => {
        if(user_data && user_data.success && user_data.results && user_data.results.person_id){
          return Promise.resolve(user_data);
        }
        else{
          return Promise.reject(new Error('Attempting to fetch current user info from Open XDMoD failed'));
        }
      });
  });
})();
