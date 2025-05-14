# frozen_string_literal: true

# ScriptsHelper is the helper module for scripts pages.
module LaunchersHelper
  def create_editable_widget(form, attrib, format: nil)
    widget = attrib.widget
    attrib.html_options = { class: 'real-field', autocomplete: 'off' }
    # For editable script elements, we want the standard render form even when they are fixed.
    # We need to reset the fixed attribute to avoid being render as a read only text field.
    fixed_attribute = attrib.fixed?
    attrib.opts[:fixed] = false
    locals = { form: form, attrib: attrib, format: format, fixed: fixed_attribute }

    case widget
    when 'number_field'
      render(partial: editable_partial('editable_number'), locals: locals)
    when 'select'
      render(partial: editable_partial('editable_select'), locals: locals)
    when 'text_field'
      render(partial: editable_partial('editable_text_field'), locals: locals)
    else
      render(partial: editable_partial('generic'), locals: locals)
    end
  end

  def editable_partial(partial)
    "launchers/editable_form_fields/#{partial}"
  end

  def parse_select_data(select_data)
    if select_data.is_a?(Array)
      select_data.first
    else
      select_data
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

  def bc_num_nodes_template
    attrib = SmartAttributes::AttributeFactory.build_bc_num_nodes
    create_editable_widget(script_form_double, attrib)
  end

  def auto_accounts_template
    attrib = SmartAttributes::AttributeFactory.build_auto_accounts
    create_editable_widget(script_form_double, attrib)
  end

  def auto_job_name_template
    attrib = SmartAttributes::AttributeFactory.build_auto_job_name
    create_editable_widget(script_form_double, attrib)
  end

  def auto_environment_variable_template
    attrib = SmartAttributes::AttributeFactory.build_auto_environment_variable
    create_editable_widget(script_form_double, attrib)
  end

  def auto_cores_template
    attrib = SmartAttributes::AttributeFactory.build_auto_cores
    create_editable_widget(script_form_double, attrib)
  end

  def auto_log_location_template
    attrib = SmartAttributes::AttributeFactory.build_auto_log_location
    create_editable_widget(script_form_double, attrib)
  end
  # We need a form builder to build the template divs. These are
  # templates so that they are not a part of the _actual_ form (yet).
  # Otherwise you'd have required fields that you cannot actually edit
  # because they're hidden.
  def script_form_double
    BootstrapForm::FormBuilder.new('launcher', nil, self, {})
  end

  def script_removable_field?(id)
    ['launcher_auto_scripts', 'launcher_auto_batch_clusters'].exclude?(id.to_s)
  end
end
