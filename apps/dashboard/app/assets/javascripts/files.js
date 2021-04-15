function alertError(error_title, error_message){
  Swal.fire(error_title, error_message, 'error');
}

function dataFromJsonResponse(response){
  return new Promise((resolve, reject) => {
    Promise.resolve(response)
    .then(response => response.ok ? Promise.resolve(response) : Promise.reject(new Error(response.statusText)))
    .then(response => response.json())
    .then(data => data.error_message ? Promise.reject(new Error(data.error_message)) : resolve(data))
    .catch((e) => reject(e))
  });
}

function newFile(filename){
  fetch(`${history.state.currentDirectoryUrl}/${encodeURI(filename)}?touch=true`, {method: 'put', headers: { 'X-CSRF-Token': csrf_token }})
  .then(response => dataFromJsonResponse(response))
  .then(() => reloadTable())
  .catch(e => alertError('Error occurred when attempting to create new file', e.message));
}

function newDirectory(filename){
  fetch(`${history.state.currentDirectoryUrl}/${encodeURI(filename)}?dir=true`, {method: 'put', headers: { 'X-CSRF-Token': csrf_token }})
  .then(response => dataFromJsonResponse(response))
  .then(() => reloadTable())
  .catch(e => alertError('Error occurred when attempting to create new directory', e.message));
}

function reloadTable(url){
  var request_url = url || history.state.currentDirectoryUrl;

  return fetch(request_url, {headers: {'Accept':'application/json'}})
    .then(response => dataFromJsonResponse(response))
    .then(function(data){
      table.clear();
      table.rows.add(data.files);
      table.draw();

      $('#open-in-terminal-btn').attr('href', data.shell_url);
      $('#open-in-terminal-btn').removeClass('disabled');

      return Promise.resolve(data);
    })
    .catch((e) => {
      Swal.fire(e.message, `Error occurred when attempting to access ${request_url}`, 'error');

      $('#open-in-terminal-btn').addClass('disabled');
      return Promise.reject(e);
    });
}

function goto(url, pushState = true, show_processing_indicator = true) {
  if(url == history.state.currentDirectoryUrl)
    pushState = false;

  reloadTable(url)
    .then((data) => {
      $('#path-breadcrumbs').html(data.breadcrumbs_html);

      if(pushState) {
        // Clear search query when moving to another directory.
        table.search('').draw();

        history.pushState({
          currentDirectory: data.path,
          currentDirectoryUrl: data.url
        }, data.name, data.url);
      }
    })
    .finally(() => {
      //TODO: after processing is available via ActiveJobs merge
      // if(show_processing_indicator)
      //   table.processing(false)
    });
}

function loading(title){
  Swal.fire({
    title: title,
    allowOutsideClick: false,
    showConfirmButton: false,
    willOpen: () => { Swal.showLoading()  }
  });
}

function doneLoading(){
  Swal.close();
}

