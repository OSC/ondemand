desc "Package OnDemand"
namespace :package do

  require_relative 'rake_helper'
  include RakeHelper

  task :version do
    puts ood_package_version
  end

  task container: [:clean] do
    sh build_cmd("Dockerfile", image_names[:ood]) unless image_exists?("#{image_names[:ood]}:#{ood_image_tag}")
  end

  desc "Build docker container and create image"
  task latest_container: [:container] do
    sh tag_latest_container_cmd(image_names[:ood])
  end

  desc "Build container with Dockerfile.test"
  task test_container: [:latest_container] do
    sh build_cmd("Dockerfile.test", test_image_name) unless image_exists?("#{test_image_name}:#{ood_image_tag}")
    sh tag_latest_container_cmd(test_image_name)
  end

  desc "Build container with Dockerfile.dev"
  task dev_container: [:latest_container] do
    extra = ["--build-arg", "USER=#{user.name}"]
    extra.concat ["--build-arg", "UID=#{user.uid}"]
    extra.concat ["--build-arg", "GID=#{user.gid}"]

    sh build_cmd("Dockerfile.dev", dev_image_name, extra_args: extra) unless image_exists?("#{dev_image_name}:#{ood_image_tag}")
    sh tag_latest_container_cmd(dev_image_name)
  end

  begin
    require 'ood_packaging/rake_task'
    desc 'Create OnDemand tar archive'
    OodPackaging::RakeTask.new(:tar) do |t, _args|
      t.package = proj_root
      t.version =  ood_package_version
      t.tar_only = true
    end
    desc 'Build OnDemand package'
    OodPackaging::RakeTask.new(:build, [:dist, :nightly]) do |t, args|
      t.package = proj_root
      t.dist = args[:dist]
      t.version = args[:nightly].to_s == 'true' ? nightly_version : ood_package_version
      t.tar = true
      t.work_dir = File.join(proj_root, 'tmp/work')
      t.output_dir = File.join(proj_root, 'dist')
      t.skip_download = true
      t.clean_output_dir = false
    end
  rescue LoadError, NameError
  end
end
