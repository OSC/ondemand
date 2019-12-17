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
      render partial: "batch_connect/sessions/connections/resolution_field", locals: {form: form, id: attrib.id, opts: all_options}
    when "check_box"
      form.form_group attrib.id, help: field_options[:help] do
        form.check_box attrib.id, all_options, attrib.checked_value, attrib.unchecked_value
      end
    when "radio", "radio_button"
      form.collection_radio_buttons attrib.id,   attrib.select_choices, :second, :first, checked: (attrib.value.presence || attrib.field_options[:checked])
    else
      form.send widget, attrib.id, all_options
    end
  end
end
