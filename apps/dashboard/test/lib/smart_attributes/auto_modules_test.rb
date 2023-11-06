# frozen_string_literal: true

require 'test_helper'

class SmartAttributes::AutoModulesTest < ActiveSupport::TestCase

  def fixture_dir
    "#{Rails.root}/test/fixtures/modules/"
  end

  test 'can correctly set the label' do
    with_modified_env({ OOD_MODULE_FILE_DIR: fixture_dir }) do
      label = 'my cool label'
      attribute = SmartAttributes::AttributeFactory.build('auto_modules_R', { label: label })

      assert_equal(label, attribute.label)
    end
  end
end