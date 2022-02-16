window.clickEventIsSignificant = clickEventIsSignificant;

window.actionsBtnTemplate = (function(){
  let template_str  = $('#actions-btn-template').html();
  return Handlebars.compile(template_str);
})();

$(document).ready(function(){
  
  $('#show-dotfiles').on('change', () => {
    let visible = $('#show-dotfiles').is(':checked');
  
    setShowDotFiles(visible);
    updateDotFileVisibility();
  });
  
  $('#show-owner-mode').on('change', () => {
    let visible = $('#show-owner-mode').is(':checked');
  
    setShowOwnerMode(visible);
    updateShowOwnerModeVisibility();
  });
  
  window.onpopstate = function(event){
    // FIXME: handle edge case if state ! exist
    setTimeout(() => {
      goto(event.state.currentDirectoryUrl, false);
    }, 0);
  };

  // this would be perfect for stimulus FYI
  $('#directory-contents tbody').on('click', '.view-file', function(e){
    e.preventDefault();

    window.open(this.href, 'ViewFile', "location=yes,resizable=yes,scrollbars=yes,status=yes");
  });


  $('#path-breadcrumbs').on('click', '#goto-btn', function(){
    Swal.fire({
      title: 'Change Directory',
      input: 'text',
      inputLabel: 'Path',
      inputValue: history.state.currentDirectory,
      inputAttributes: {
        spellcheck: 'false',
      },
      showCancelButton: true,
      inputValidator: (value) => {
        if (! value || ! value.startsWith('/')) {
          // TODO: validate filenames against listing
          return 'Provide an absolute pathname'
        }
      }
    })
    .then((result) => result.isConfirmed ? Promise.resolve(result.value) : Promise.reject('cancelled'))
    .then((pathname) => goto(filesPath + pathname))
  });
  
});


// borrowed from Turbolinks
// event: MouseEvent
function clickEventIsSignificant(event) {
  return !(
    // (event.target && (event.target as any).isContentEditable)
       event.defaultPrevented
    || event.which > 1
    || event.altKey
    || event.ctrlKey
    || event.metaKey
    || event.shiftKey
  )
}
