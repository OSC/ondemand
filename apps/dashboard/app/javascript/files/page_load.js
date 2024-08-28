
export function setPageLoadState() {
  const configEle = document.getElementById('files_page_load_config');

  if(configEle === null) {
    return;
  }

  const data = configEle.dataset;

  history.replaceState({
    currentDirectory: data['currentDirectory'],
    currentDirectoryUrl: data['currentDirectoryUrl'],
    currentDirectoryUpdatedAt: data['currentDirectoryUpdatedAt'],
    currentFilesPath: data['currentFilesPath'],
    currentFilesUploadPath: data['currentFilesUploadPath'],
    currentFilesystem: data['currentFilesystem']
  }, null);
}
