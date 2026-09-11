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

  test 'can filter modules when given a string' do
    with_modified_env({ OOD_MODULE_FILE_DIR: fixture_dir }) do
      attribute = SmartAttributes::AttributeFactory.build('auto_modules_R', { filter: 'Eliminate' })
      versions = [['R-KeepThisModule', 'R-KeepThisModule'],
                  ['R-AlsoKeep', 'R-AlsoKeep'],
                  ['R-EliminateModule', 'R-EliminateModule']]
      attribute.expects(:hpc_versions).returns(versions)

      refute attribute.select_choices.include?(['R-EliminateModule', 'R-EliminateModule'])
    end
  end

  test 'can filter modules when given a Ruby regex' do
    with_modified_env({ OOD_MODULE_FILE_DIR: fixture_dir }) do
      attribute = SmartAttributes::AttributeFactory.build('auto_modules_R', { filter: /Eliminate/ })
      versions = [['R-KeepThisModule', 'R-KeepThisModule'],
                  ['R-AlsoKeep', 'R-AlsoKeep'],
                  ['R-EliminateModule', 'R-EliminateModule']]
      attribute.expects(:hpc_versions).returns(versions)

      refute attribute.select_choices.include?(['R-EliminateModule', 'R-EliminateModule'])
    end
  end

  test 'data-option-for-cluster uses hyphens for cluster ids with underscores' do
    with_modified_env({ OOD_MODULE_FILE_DIR: fixture_dir }) do
      attribute = SmartAttributes::AttributeFactory.build('auto_modules_R', {})
      Configuration.stubs(:job_clusters).returns([stub(id: 'x-nextgen_ascend')])
      HpcModule.stubs(:all_versions).returns([stub(on_cluster?: false, version: '1.0', to_s: 'R/1.0')])

      data = attribute.send(:hpc_versions).first[2]
      assert data.key?('data-option-for-cluster-x-nextgen-ascend')
      refute data.key?('data-option-for-cluster-x-nextgen_ascend')
    end
  end

  test 'can filter modules when given an array' do
    with_modified_env({ OOD_MODULE_FILE_DIR: fixture_dir }) do
      attribute = SmartAttributes::AttributeFactory.build('auto_modules_R', { filter: [/Eliminate/, /GetRidOfMeToo/] })
      versions = [['R-KeepThisModule', 'R-KeepThisModule'],
                  ['R-AlsoKeep', 'R-AlsoKeep'],
                  ['R-EliminateModule', 'R-EliminateModule'],
                  ['R-GetRidOfMeToo', 'R-GetRidOfMeToo']]
      attribute.expects(:hpc_versions).returns(versions)

      choices = attribute.select_choices

      refute choices.include?(['R-GetRidOfMeToo', 'R-GetRidOfMeToo'])
      refute choices.include?(['R-EliminateModule', 'R-EliminateModule'])
    end
  end
end