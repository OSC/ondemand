'use strict;'

import RFB from '@novnc/novnc';

function connect() {
  console.log('connected');
}

function disconnect() {
  console.log('disconnected');
}

function credentialsAreRequired() {
  console.log('credentials are required');
}

function updateDesktopName() {

}

function connectData() {
  const ele = document.getElementById('novnc_info');
  return ele.dataset;
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

makeNewRFB();