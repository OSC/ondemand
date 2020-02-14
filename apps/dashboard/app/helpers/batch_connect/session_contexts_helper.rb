module BatchConnect::SessionContextsHelper
  def create_widget(form, attrib, format: nil)
    return "" if attrib.fixed?

    widget = attrib.widget
    field_options = attrib.field_options(fmt: format)
    all_options = attrib.all_options(fmt: format)

    case widget
    when "select"
      form.select attrib.id, attrib.select_choices, field_options, attrib.html_options
    when "resolution_field"
      resolution_field(form, attrib.id, all_options)
    when "check_box"
      form.form_group attrib.id, help: field_options[:help] do
        form.check_box attrib.id, all_options, attrib.checked_value, attrib.unchecked_value
      end
    when "radio", "radio_button"
      form.collection_radio_buttons attrib.id,   attrib.select_choices, :second, :first, checked: [attrib.value] + Array.wrap(attrib.field_options[:checked])
    else
      form.send widget, attrib.id, all_options
    end
  end

  def resolution_field(form, id, opts = {})
    content_tag(:div, id: "#{id}_group", class: "form-group") do
      concat form.label(id, opts[:label])
      concat form.hidden_field(id, id: "#{id}_field")
      concat(
        content_tag(:div, class: "row") do
          concat (
            content_tag(:div, class: "col-sm-6") do
              concat (
                content_tag(:div, class: "input-group") do
                  concat content_tag(:div, "width", class: "input-group-addon", style: "width: 70px")
                  concat number_field_tag("#{id}_x_field", nil, class: "form-control", min: 100, required: opts[:required])
                  concat content_tag(:div, "px", class: "input-group-addon")
                end
              )
            end
          )
          concat (
            content_tag(:div, class: "col-sm-6") do
              concat (
                content_tag(:div, class: "input-group") do
                  concat content_tag(:div, "height", class: "input-group-addon", style: "width: 70px")
                  concat number_field_tag("#{id}_y_field", nil, class: "form-control", min: 100, required: opts[:required])
                  concat content_tag(:div, "px", class: "input-group-addon")
                end
              )
            end
          )
        end
      )
      concat content_tag(:span, opts[:help], class: "help-block") if opts[:help]
      concat button_tag(t('dashboard.batch_connect_form_reset_resolution'), id: "#{id}_reset", type: "button", class: "btn btn-default")
      concat(
        content_tag(:script) do
          <<-EOT.html_safe
            (function() {
              // Target elements
              var $target  = $('##{id}_field');
              var $targetX = $('##{id}_x_field');
              var $targetY = $('##{id}_y_field');
              var $targetR = $('##{id}_reset');

              // Helper methods
              var setX = function(x) {
                y = getY();
                $target.val(x + 'x' + y);
                $targetX.val(x);
              };
              var setY = function(y) {
                x = getX();
                $target.val(x + 'x' + y);
                $targetY.val(y);
              };
              var getX = function() {
                return $target.val().split('x')[0];
              };
              var getY = function() {
                return $target.val().split('x')[1];
              };
              var resetXY = function() {
                setX(window.screen.width  * 0.8 | 0);
                setY(window.screen.height * 0.8 | 0);
              };

              // Set defaults if not already set
              if ( !$target.val() ) {
                resetXY();
              } else {
                setX(getX());
                setY(getY());
              }

              // Event listeners
              $targetX.change(function() {
                setX($(this).val());
              });
              $targetY.change(function() {
                setY($(this).val());
              });
              $targetR.click(function() {
                resetXY();
              });
            })();
          EOT
        end
      )
    end
  end
end
