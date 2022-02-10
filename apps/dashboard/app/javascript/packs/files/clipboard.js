import ClipboardJS from 'clipboard'


window.ClipboardJS = ClipboardJS

$(document).ready(function(){
  clipboardjs.on('success', function(e) {
    $(e.trigger).tooltip({title: 'Copied path to clipboard!', trigger: 'manual', placement: 'bottom'}).tooltip('show');
    setTimeout(() => $(e.trigger).tooltip('hide'), 2000);
    e.clearSelection();
  });
  clipboardjs.on('error', function(e) {
    e.clearSelection();
  });


  
});