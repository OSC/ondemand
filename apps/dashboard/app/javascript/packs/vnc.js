'use strict;'

import RFB from '@novnc/novnc';


function connect() {

}

function disconnect() {

}

function credentialsAreRequired() {

}

function updateDesktopName() {

}

function connectData() {
  return $("#novnc_info").data();
}

function connectURL(origin, port) {
  
  const scheme = window.location.protocol === "https:" ? 'wss' : 'ws';
  const host = window.location.port == "" ? window.location.hostname : `${window.location.hostname}:${window.location.port}`;

  return `${scheme}://${host}/rnode/${origin}/${port}/websockify`;
}

function makeNewRFB(){
  // Creating a new RFB object will start a new connection
  const data = connectData();

  const rfb = new RFB(
          document.getElementById('novnc_screen'), 
          connectURL(data['host'], data['websocket']),
          { credentials: { password: data['password'] } }
        );

  // Add listeners to important events from the RFB module
  rfb.addEventListener("connect",  connect);
  rfb.addEventListener("disconnect", disconnect);
  rfb.addEventListener("credentialsrequired", credentialsAreRequired);
  rfb.addEventListener("desktopname", updateDesktopName);
}

jQuery(function() {
  makeNewRFB();
});


