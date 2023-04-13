# frozen_string_literal: true

# ScriptsHelper is the helper module for scripts pages.
module ScriptsHelper
  def create_editable_widget(form, attrib, format: nil)
    widget = attrib.widget
    attrib.html_options = { class: 'real-field' }
    locals = { form: form, attrib: attrib, format: format }

    case widget
    when 'number_field'
      render(partial: 'scripts/editable_form_fields/editable_number', locals: locals)
    else
      render(partial: 'scripts/editable_form_fields/generic', locals: locals)
    end
  end

end
