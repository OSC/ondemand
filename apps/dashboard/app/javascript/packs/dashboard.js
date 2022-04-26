'use strict';

import _ from 'lodash';
window._ = _;

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

window.promiseLoginToXDMoD = promiseLoginToXDMoD;
window.promiseLoggedIntoXDMoD = promiseLoggedIntoXDMoD;

// FIXME: move the javascript that requires this (app/views/widgets/_xdmod_widget*) to packs
import Handlebars from 'handlebars';
window.Handlebars = Handlebars;

jQuery(function(){
  $("a[target=_blank]").on("click", function(event) {
    // open url using javascript, instead of following directly
    event.preventDefault();

    if(window.open($(this).attr("href")) == null){
      // link was not opened in new window, so display error msg to user
      const html = $("#js-alert-danger-template").html();
      const msg = "This link is configured to open in a new window, but it doesn't seem to have opened. " +
            "Please disable your popup blocker for this page and try again.";

      // replace message in alert and add to main div of layout
      $("div[role=main]").prepend(html.split("ALERT_MSG").join(msg));
    }
  });
});
