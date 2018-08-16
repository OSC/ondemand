module BatchConnect::SessionContextsHelper
  def create_widget(form, attrib, format: nil)
    return "" if attrib.fixed?

    widget = attrib.widget

    field_options = attrib.opts.reject { |k,v|
      %i(widget options html_options checked_value unchecked_value).include?(k)
    }.merge({
      label: attrib.label(fmt: format),
      help:  OodAppkit.markdown.render(attrib.help(fmt: format)).html_safe,
      required: attrib.required
    })
    html_options = attrib.opts.fetch(:html_options, {})
    all_options = field_options.merge(html_options)

    checked_value = attrib.opts.fetch(:checked_value, "1")
    unchecked_value = attrib.opts.fetch(:unchecked_value, "0")

    case widget
    when "select"
      form.select attrib.id, attrib.opts.fetch(:options, []), field_options, html_options
    when "resolution_field"
      resolution_field(form, attrib.id, all_options)
    when "check_box"
      form.form_group attrib.id, help: field_options[:help] do
        form.check_box attrib.id, all_options, checked_value, unchecked_value
      end
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
      concat button_tag("Reset Resolution", id: "#{id}_reset", type: "button", class: "btn btn-default")
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
