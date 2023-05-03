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

  def bc_num_hours_template
    attrib = SmartAttributes::AttributeFactory.build_bc_num_hours({})
    create_editable_widget(script_form_double, attrib)
  end

  def auto_queues_template
    attrib = SmartAttributes::AttributeFactory.build_auto_queues
    create_editable_widget(script_form_double, attrib)
  end

  def bc_num_slots_template
    attrib = SmartAttributes::AttributeFactory.build_bc_num_slots
    create_editable_widget(script_form_double, attrib)
  end

  # We need a form builder to build the template divs. These are
  # templates so that they are not a part of the _actual_ form (yet).
  # Otherwise you'd have required fields that you cannot actually edit
  # because they're hidden.
  def script_form_double
    BootstrapForm::FormBuilder.new('script', nil, self, {})
  end
end
