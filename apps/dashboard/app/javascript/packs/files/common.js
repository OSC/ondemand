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
  
});

