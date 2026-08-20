# frozen_string_literal: true

require 'test_helper'

class HpcModuleTest < ActiveSupport::TestCase
  # owens.json and oakley.json in this directory are from real clusters
  # (oakley is actually pitzer) from the time this was written.
  def fixture_dir
    "#{Rails.root}/test/fixtures/modules/"
  end

  test 'all safely reads from inaccessabile directories' do
    with_modified_env({ OOD_MODULE_FILE_DIR: '/dev/null' }) do
      assert_equal [], HpcModule.all(cluster: 'owens')
    end
  end

  test 'all safely reads invalid json' do
    Dir.mktmpdir do |dir|
      with_modified_env({ OOD_MODULE_FILE_DIR: dir }) do
        `echo '{this is bad json}' > #{dir}/owens.json`
        assert_equal [], HpcModule.all(cluster: 'owens')
      end
    end
  end

  test 'all_versions is correct, sorted and unique' do
    stub_sys_apps
    with_modified_env({ OOD_MODULE_FILE_DIR: fixture_dir }) do
      # "app_jupyter/1.2.21" in oakley.json is hidden
      expected = [
        'app_jupyter/3.1.18', 'app_jupyter/3.0.17', 'app_jupyter/2.3.2', 'app_jupyter/2.2.10',
        'app_jupyter/1.2.21', 'app_jupyter/0.35.6'
      ]
      assert_equal(expected, HpcModule.all_versions('app_jupyter').map(&:to_s))
    end
  end

  test 'all versions returns empty array when it cannot find' do
    stub_sys_apps
    with_modified_env({ OOD_MODULE_FILE_DIR: fixture_dir }) do
      assert_equal([], HpcModule.all_versions('wont_find').map(&:to_s))
      assert_equal([], HpcModule.all_versions(nil).map(&:to_s))
    end
  end

  test 'on_cluster? can find modules' do
    stub_sys_apps
    with_modified_env({ OOD_MODULE_FILE_DIR: fixture_dir }) do
      assert HpcModule.new('app_jupyter', version: '0.35.6').on_cluster?('oakley')
      assert !HpcModule.new('app_jupyter', version: '0.35.6').on_cluster?('owens')
    end
  end

  test 'default version' do
    m = HpcModule.new('test')
    assert m.default?
    assert m.version.nil?
  end

  test 'module with version version' do
    m = HpcModule.new('test', version: 9001)
    assert !m.default?
    assert_equal m.version, '9001' # we gave an int, got back a string
  end

  test 'hidden modules are filtered' do
    stub_sys_apps
    with_modified_env({ OOD_MODULE_FILE_DIR: fixture_dir }) do
      # "mkl/.2019.0.5" in oakley.json is hidden
      expected = [
        'mkl/2019.0.5', 'mkl/2019.0.3', 'mkl/2018.0.3', 'mkl/2017.0.7',
        'mkl/2017.0.4', 'mkl/2017.0.2', 'mkl/11.3.3'
      ]
      assert_equal(expected, HpcModule.all_versions('mkl').map(&:to_s))
    end
  end

  test 'modules with same name and version with different dependency sets' do
    stub_sys_apps
    Dir.mktmpdir do |tmpdir|
      # Only look at Owens LAMMPS modules
      FileUtils.cp("#{fixture_dir}/owens.json", "#{tmpdir}/owens.json")
      with_modified_env({ OOD_MODULE_FILE_DIR: tmpdir }) do
        expected = [
          'lammps/5Jun19', 'lammps/3Mar20', 'lammps/29Oct20', 'lammps/22Aug18', 'lammps/16Mar18'
        ]
        assert_equal(expected, HpcModule.all_versions('lammps').map(&:to_s))
        lammps_3mar20_entries = HpcModule.all(cluster: 'owens').select { |m| m.name == 'lammps' && m.version == '3Mar20' }
        merged_dependencies = lammps_3mar20_entries.flat_map { |m| Array(m.dependencies) }.uniq
        expected = [['intel/19.0.3', 'openmpi/4.0.3-hpcx'], ['intel/19.0.5', 'openmpi/4.0.3-hpcx'], 
                    ['intel/19.0.3', 'openmpi/4.0.3'], ['intel/19.0.5', 'openmpi/4.0.3'],
                    ['intel/19.0.3', 'intelmpi/2019.7'], ['intel/19.0.5', 'intelmpi/2019.7'],
                    ['intel/19.0.3', 'intelmpi/2019.3'], ['intel/19.0.5', 'intelmpi/2019.3'],
                    ['intel/19.0.3', 'intelmpi/.2019.5'], ['intel/19.0.5', 'intelmpi/.2019.5'],
                    ['intel/19.0.3', 'mvapich2-gdr/2.3.4'], ['intel/19.0.5', 'mvapich2-gdr/2.3.4'],
                    ['intel/19.0.3', 'mvapich2-gdr/2.3.5'], ['intel/19.0.5',  'mvapich2-gdr/2.3.5'],
                    ['intel/19.0.3', 'mvapich2/2.3.2'], ['intel/19.0.5', 'mvapich2/2.3.2'],
                    ['intel/19.0.3', 'mvapich2/2.3.1'], ['intel/19.0.5', 'mvapich2/2.3.1'],
                    ['intel/19.0.3', 'mvapich2/2.3.6'], ['intel/19.0.5', 'mvapich2/2.3.6'],
                    ['intel/19.0.3', 'mvapich2/2.3.5'], ['intel/19.0.5', 'mvapich2/2.3.5'],
                    ['intel/19.0.3', 'mvapich2/2.3.4'], ['intel/19.0.5', 'mvapich2/2.3.4'],
                    ['intel/19.0.3', 'mvapich2/2.3.3'], ['intel/19.0.5', 'mvapich2/2.3.3']
        ]
        assert_equal(expected, merged_dependencies)
      end
    end
  end

end
