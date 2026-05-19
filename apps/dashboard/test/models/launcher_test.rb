# frozen_string_literal: true

require 'test_helper'

class LauncherTest < ActiveSupport::TestCase
  def setup
    stub_sinfo
  end

  test 'supported field postfix' do
    target = Launcher.new({ project_dir: '/path/project', id: 1234, title: 'Test Script' })
    refute target.send('attribute_parameter?', nil)
    refute target.send('attribute_parameter?', '')
    refute target.send('attribute_parameter?', 'account_notsupported')
    assert target.send('attribute_parameter?', 'account_min')
    assert target.send('attribute_parameter?', 'account_max')
    assert target.send('attribute_parameter?', 'account_exclude')
    assert target.send('attribute_parameter?', 'account_fixed')
  end

  test 'creates script' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)
      target = Launcher.new({ project_dir: projects_path.to_s, id: '12345678', title: 'Test Script' })

      assert target.save
      assert Dir.entries("#{projects_path}/.ondemand/launchers").include?('12345678')
    end
  end

  test 'deletes script' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)
      target = Launcher.new({ project_dir: projects_path.to_s, id: '12345678', title: 'Test Script' })

      assert target.save
      assert Dir.entries("#{projects_path}/.ondemand/launchers").include?('12345678')

      assert target.destroy
      assert_not Dir.entries("#{projects_path}/.ondemand/launchers").include?('12345678')
    end
  end

  test 'clusters? return false when auto_batch_clusters returns no clusters' do
    Configuration.stubs(:job_clusters).returns([])

    assert_equal false, Launcher.clusters?
  end

  test 'clusters? return true when auto_batch_clusters returns clusters' do
    Configuration.stubs(:job_clusters).returns(OodCore::Clusters.load_file('test/fixtures/config/clusters.d'))

    assert_equal true, Launcher.clusters?
  end

  test 'deletes script should succeed when directory does not exists' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)
      script = Launcher.new({ project_dir: projects_path.to_s, id: '12345678', title: 'Test Script' })
      assert script.save
      assert Dir.entries("#{projects_path}/.ondemand/launchers").include?('12345678')

      target = Launcher.new({ project_dir: projects_path.to_s, id: '33333333', title: 'Not saved' })
      assert_not Dir.entries("#{projects_path}/.ondemand/launchers").include?('33333333')

      assert target.destroy
      assert Dir.entries("#{projects_path}/.ondemand/launchers").include?('12345678')
      assert_not Dir.entries("#{projects_path}/.ondemand/launchers").include?('33333333')
    end
  end

  test 'scripts? returns true when there are scripts in the project directory' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)

      script_content = <<~TEST_SCRIPT
        echo "Testing Scripts"
      TEST_SCRIPT
      File.open(File.join(projects_path, 'test_script.sh'), 'w+') { |file| file.write(script_content) }

      assert_equal true, Launcher.scripts?(projects_path)
    end
  end

  test 'scripts? returns false when there are no scripts in the project directory' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)

      assert_equal false, Launcher.scripts?(projects_path)
    end
  end

  test 'launchers will re-assign wrong id' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)
      bad_id = '1234'
      launcher = Launcher.new({ project_dir: projects_path.to_s, id: bad_id, title: 'Test Script' })

      assert(launcher.id.to_s.match?(Launcher::ID_REX))
      refute(bad_id.match?(Launcher::ID_REX))
      refute(bad_id.to_s == launcher.id)
    end
  end

  test 'create_default_script should create hello_world.sh script' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)

      target = Launcher.new({ project_dir: projects_path.to_s, id: 1234, title: 'Default Script' })
      created_script = target.create_default_script

      assert_equal true, created_script
      assert_equal true, Pathname(File.join(projects_path, 'hello_world.sh')).exist?
    end
  end

  test 'create_default_script should not create hello_world.sh script if there is an script already in the project' do
    Dir.mktmpdir do |tmp|
      projects_path = Pathname.new(tmp)
      OodAppkit.stubs(:dataroot).returns(projects_path)

      script_content = <<~TEST_SCRIPT
        echo "Testing Scripts"
      TEST_SCRIPT
      File.open(File.join(projects_path, 'test_script.sh'), 'w+') { |file| file.write(script_content) }

      target = Launcher.new({ project_dir: projects_path.to_s, id: 1234, title: 'With Script' })
      created_script = target.create_default_script

      assert_equal false, created_script
      assert_equal false, Pathname(File.join(projects_path, 'hello_world.sh')).exist?
    end
  end

  test 'will not save even if id is resest' do
    Dir.mktmpdir do |tmp|
      bad_id = '1234'
      launcher = Launcher.new({ project_dir: tmp.to_s, id: bad_id, title: 'Default Script' })

      # initializer reset the id, but we can reset it
      refute(launcher.id.to_s == bad_id.to_s)
      launcher.instance_variable_set('@id', bad_id)
      assert_equal(launcher.id, bad_id)
      assert(launcher.errors.size, 0)

      # now try to save it, and it fails
      refute(launcher.save)
      assert(launcher.errors.size, 1)
      assert_equal(launcher.errors.full_messages[0], "Id ID does not match #{Launcher::ID_REX.inspect}")
      refute(Dir.exist?(Launcher.launchers_dir(tmp).to_s))
    end
  end
end
