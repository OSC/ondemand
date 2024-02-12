'use strict;'

const CONFIG_ID = 'ood_config'

export function configData() {
  return document.getElementById(CONFIG_ID).dataset;
}

export function maxFileSize () {
  const cfgData = configData();

  // Check if cfgData['maxFileSize'] is just empty string, 
  // if so set default of maxFileUpload=10737420000 bytes.
  if (cfgData['maxFileSize'].length == 0) {
    return parseInt(10737420000, 10);
  }
  else {
    const maxFileSize = cfgData['maxFileSize'];
    return parseInt(maxFileSize, 10);
  }
}

export function transfersPath() {
  const cfgData = configData();
  const transfersPath = cfgData['transfersPath'];

  return transfersPath;
}

export function jobsInfoPath(){
  const cfgData = configData();
  return cfgData['jobsInfoPath'];
}

export function csrfToken() {
  const csrf_token = document.querySelector('meta[name="csrf-token"]').content;

  return csrf_token;
}

export function uppyLocale() {
  const cfgData = configData();
  return JSON.parse(cfgData['uppyLocale']);
}

export function isBCDynamicJSEnabled() {
  const cfgData = configData();
  return cfgData['bcDynamicJs'] == 'true'
}

/*
  Will return null if xdmod integration is not enabled.
*/
export function xdmodUrl(){
  const cfgData = configData();
  const url = cfgData['xdmodUrl'];
  return url == "" ? null : url;
}

export function analyticsPath(type){
  const cfgData = configData();
  const basePath = cfgData['baseAnalyticsPath']
  return `${basePath}/${type}`;
}
