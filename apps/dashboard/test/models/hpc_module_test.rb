# frozen_string_literal: true

require 'test_helper'

class HpcModuleTest < ActiveSupport::TestCase
  test 'all safely reads from inaccessabile directories' do
    with_modified_env({ OOD_MODULE_FILE_DIR: '/dev/null' }) do
      assert_equal [], HpcModule.all('owens')
    end
  end

  test 'all safely reads invalid json' do
    Dir.mktmpdir do |dir|
      with_modified_env({ OOD_MODULE_FILE_DIR: dir }) do
        `echo '{this is bad json}' > #{dir}/owens.json`
        assert_equal [], HpcModule.all('owens')
      end
    end
  end

  test 'reads a simple file' do
    with_modified_env({ OOD_MODULE_FILE_DIR: "#{Rails.root}/test/fixtures/modules/" }) do
      # NOTE: that there are no duplicates and rstudio has no version
      assert_equal(['jupyter/1', 'jupyter/2', 'rstudio'], HpcModule.all('simple').map(&:to_s))
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

  test 'module equivalence' do
    m1 = HpcModule.new('test', version: 9001)
    m2 = HpcModule.new('test', version: 9001)

    assert m1 == m2
    assert m1.eql?(m2)
    assert m1 == "test/9001" && m2 == "test/9001"
    assert m1.eql?("test/9001") && m2.eql?("test/9001")
  end
end
