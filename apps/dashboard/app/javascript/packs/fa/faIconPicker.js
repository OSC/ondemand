import 'fa/faIconInfo';

jQuery(function() {

  function faClassToURI(classname) {
    var re = /^(fa[bsrl]?) fa-(.*)/;
    var result = re.exec(classname);
    if (result) {
      return result[1] + "://" + result[2];
    } else {
      return classname;
    }
  };

  var stdConfig = {placement: "inline", templates: {iconpickerItem: '<div role="button" class="iconpicker-item"><i></i></div>'}};
  var usesOld = $('#product-icon').hasClass("fa");
  var iconSetting = usesOld ? $.extend({icons: FA4iconinfo}, stdConfig) : $.extend({icons: FA5iconinfo, placement: "inline"}, stdConfig);
  $('#icp').iconpicker(iconSetting);
  $('#alias').prop('checked', usesOld);

  $('#icp').on('iconpickerSelected', function(event) {
    classname = event.iconpickerInstance.options.fullClassFormatter(event.iconpickerValue);
    $('#product-icon').get(0).className = 'app-icon fa-fw ' + classname;
    $('#uri-box').val(faClassToURI(classname));
  });

  $('#uri-box').on('change', function(event) {
    if ($('#uri-box').val() === "") {
      $('#product-icon').get(0).className = 'app-icon fa-fw fas fa-cog';
    }
  });

  $('#alias').on('change', function() {
    $('#icp').data('iconpicker').destroy();
    if ($('#alias').is(":checked")) {
      $('#icp').iconpicker($.extend({icons: FA4iconinfo, placement: "inline"}, stdConfig));
    } else {
      $('#icp').iconpicker($.extend({icons: FA5iconinfo, placement: "inline"}, stdConfig));
    }
  })
});
