# frozen_string_literal: true

require 'test_helper'

class ScriptTest < ActiveSupport::TestCase
  test 'creates script' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)
      target = Script.new({ project_dir: projects_path.to_s, id: 1234, title: 'Test Script' })

      assert target.save
      assert Dir.entries("#{projects_path}/.ondemand/scripts").include?('1234')
    end
  end

  test 'deletes script' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)
      target = Script.new({ project_dir: projects_path.to_s, id: 1234, title: 'Test Script' })

      assert target.save
      assert Dir.entries("#{projects_path}/.ondemand/scripts").include?('1234')

      assert target.destroy
      assert_not Dir.entries("#{projects_path}/.ondemand/scripts").include?('1234')
    end
  end

  test 'deletes script should succeed when directory does not exists' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)
      script = Script.new({ project_dir: projects_path.to_s, id: 1234, title: 'Test Script' })
      assert script.save
      assert Dir.entries("#{projects_path}/.ondemand/scripts").include?('1234')

      target = Script.new({ project_dir: projects_path.to_s, id: 33, title: 'Not saved' })
      assert_not Dir.entries("#{projects_path}/.ondemand/scripts").include?('33')

      assert target.destroy
      assert Dir.entries("#{projects_path}/.ondemand/scripts").include?('1234')
      assert_not Dir.entries("#{projects_path}/.ondemand/scripts").include?('33')
    end
  end
end
