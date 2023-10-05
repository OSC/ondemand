'use strict;'

const CONFIG_ID = 'ood_config'

function configData() {
  return document.getElementById(CONFIG_ID).dataset;
}

function maxFileSize () {
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

function transfersPath() {
  const cfgData = configData();
  const transfersPath = cfgData['transfersPath'];

  return transfersPath;
}

function jobsInfoPath(){
  const cfgData = configData();
  return cfgData['jobsInfoPath'];
}

function csrfToken() {
  const csrf_token = document.querySelector('meta[name="csrf-token"]').content;

  return csrf_token;
}

function uppyLocale() {
  const cfgData = configData();
  return JSON.parse(cfgData['uppyLocale']);
}

function isBCDynamicJSEnabled() {
  const cfgData = configData();
  return cfgData['bcDynamicJs'] == 'true'
}

export {
  isBCDynamicJSEnabled,
  maxFileSize,
  transfersPath,
  jobsInfoPath,
  csrfToken,
  uppyLocale
};
