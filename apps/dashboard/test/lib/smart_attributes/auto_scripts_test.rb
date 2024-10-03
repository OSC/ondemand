# frozen_string_literal: true

require 'test_helper'

class SmartAttributes::AutoScriptsTest < ActiveSupport::TestCase

  def fixture_dir
    Pathname.new("#{Rails.root}/test/fixtures/attributes/auto_scripts")
  end

  test 'can correctly set the value when scripts directory is configured' do
    value = "#{fixture_dir}/script4.slurm"
    attribute = SmartAttributes::AttributeFactory.build('auto_scripts', { directory: fixture_dir, value: value })

    assert_instance_of SmartAttributes::Attributes::AutoScripts, attribute
    assert_equal(value, attribute.value)
  end

  test 'default value is the first script from the list of scripts in the configured directory' do
    attribute = SmartAttributes::AttributeFactory.build('auto_scripts', { directory: fixture_dir.to_s })

    assert_instance_of SmartAttributes::Attributes::AutoScripts, attribute
    assert_equal('script1.sh', File.basename(attribute.value))
  end

  test 'can correctly set the label' do
    attribute = SmartAttributes::AttributeFactory.build('auto_scripts', { label: 'My Local Script' })

    assert_instance_of SmartAttributes::Attributes::AutoScripts, attribute
    assert_equal('My Local Script', File.basename(attribute.label))
  end

  test 'default label is Script' do
    attribute = SmartAttributes::AttributeFactory.build('auto_scripts', { directory: fixture_dir.to_s })

    assert_instance_of SmartAttributes::Attributes::AutoScripts, attribute
    assert_equal('Script', File.basename(attribute.label))
  end

  test 'select_choices return the sorted list of supported scripts from the configured directory' do
    attribute = SmartAttributes::AttributeFactory.build('auto_scripts', { directory: fixture_dir.to_s })

    ['sh', 'csh', 'bash', 'slurm', 'sbatch', 'qsub']
    assert_instance_of SmartAttributes::Attributes::AutoScripts, attribute
    assert_equal(6, attribute.select_choices.length)
    assert_equal('script1.sh', attribute.select_choices[0].first)
    assert_equal('script2.bash', attribute.select_choices[1].first)
    assert_equal('script3.csh', attribute.select_choices[2].first)
    assert_equal('script4.slurm', attribute.select_choices[3].first)
    assert_equal('script5.sbatch', attribute.select_choices[4].first)
    assert_equal('script6.qsub', attribute.select_choices[5].first)
  end

  test 'widget is select' do
    attribute = SmartAttributes::AttributeFactory.build('auto_scripts')

    assert_instance_of SmartAttributes::Attributes::AutoScripts, attribute
    assert_equal('select', File.basename(attribute.widget))
  end

  test 'correctly sets value when previous value is invalid' do
    value = '/test/invalid/script.sh'
    attribute = SmartAttributes::AttributeFactory.build('auto_scripts', { directory: fixture_dir, value: value })

    assert_instance_of SmartAttributes::Attributes::AutoScripts, attribute
    assert_equal(attribute.select_choices[0].last, attribute.value)
  end
end
