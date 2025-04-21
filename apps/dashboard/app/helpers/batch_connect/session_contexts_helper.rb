# Helper for creating new batch connect sessions.
module BatchConnect::SessionContextsHelper
  def create_widget(form, attrib, format: nil, hide_excludable: true, hide_fixed: true)
    return '' if hide_fixed && attrib.fixed?
    return '' if attrib.hide_when_empty? && attrib.value.blank?

    widget = attrib.widget
    field_options = attrib.field_options(fmt: format)
    all_options = attrib.all_options(fmt: format)

    if attrib.fixed?
      return render :partial => "batch_connect/session_contexts/fixed", :locals => { form: form, attrib: attrib, field_options: field_options, format: format }
    end

    rendered =  case widget
                when 'select'
                  form.select(attrib.id, attrib.select_choices(hide_excludable: hide_excludable), field_options, attrib.html_options)
                when 'resolution_field'
                  resolution_field(form, attrib.id, all_options)
                when 'check_box'
                  form.form_group attrib.id, help: field_options[:help] do
                    form.check_box attrib.id, all_options, attrib.checked_value, attrib.unchecked_value
                  end
                when 'radio', 'radio_button'
                  form.form_group attrib.id, help: field_options[:help] do
                    opts = {
                      label:   label_tag(attrib.id, attrib.label),
                      checked: (attrib.value.presence || attrib.field_options[:checked])
                    }
                    form.collection_radio_buttons(attrib.id, attrib.select_choices, :second, :first, **opts)
                  end
                when 'path_selector'
                  form.form_group(attrib.id) do
                    render(partial: 'path_selector', locals: { form: form, attrib: attrib, field_options: field_options })
                  end
                when 'file_attachments'
                  render :partial => "batch_connect/session_contexts/file_attachments", :locals => { form: form, attrib: attrib, field_options: field_options }
                else
                  form.send widget, attrib.id, all_options
                end
    header = sanitize(OodAppkit.markdown.render(attrib.header))
    "#{header}#{rendered}".html_safe

  end

  def resolution_field(form, id, opts = {})
    content_tag(:div, id: "#{id}_group", class: "mb3") do
      concat form.label(id, opts[:label])
      concat form.hidden_field(id, id: "#{id}_field")
      concat(
        content_tag(:div, class: "row mb-3") do
          concat (
            content_tag(:div, class: "col-sm-6") do
              concat (
                content_tag(:div, class: "input-group") do
                  concat (content_tag(:div, class: "input-group-prepend") do
                    content_tag(:div, "width", class: "input-group-text")
                  end)
                  concat number_field_tag("#{id}_x_field", nil, class: "form-control", min: 100, required: opts[:required])
                  concat (content_tag(:div, class: "input-group-append") do
                    content_tag(:div, "px", class: "input-group-text")
                  end)
                end
              )
            end
          )
          concat (
            content_tag(:div, class: "col-sm-6") do
              concat (
                content_tag(:div, class: "input-group") do
                  concat (content_tag(:div, class: "input-group-prepend") do
                    content_tag(:div, "height", class: "input-group-text")
                  end)
                  concat number_field_tag("#{id}_y_field", nil, class: "form-control", min: 100, required: opts[:required])
                  concat (content_tag(:div, class: "input-group-append") do
                    content_tag(:div, "px", class: "input-group-text")
                  end)
                end
              )
            end
          )
        end
      )
      concat content_tag(:span, opts[:help], class: "help-block") if opts[:help]
      concat button_tag(t('dashboard.batch_connect_form_reset_resolution'), id: "#{id}_reset", type: "button", class: "btn btn-light")
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

  def pathselector_favorites(favorites)
    # If favorites is false, return nil
    if favorites.nil?
      OodFilesApp.new.favorite_paths.reject(&:remote?)
    elsif favorites
      favorites.map { |f| FavoritePath.new(f) }
    end
  end
end
