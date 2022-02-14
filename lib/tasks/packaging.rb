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

  desc "Build container with Dockerfile.dev"
  task dev_container: [:latest_container] do
    image = image_names[:dev]
    tag = ENV['_OOD_PKG_NIGHTLY'].nil? ? ood_image_tag : nightly_version_simple


    extra = ["--build-arg", "USER=#{user.name}"]
    extra.concat ["--build-arg", "UID=#{user.uid}"]
    extra.concat ["--build-arg", "GID=#{user.gid}"]

    sh build_cmd("Dockerfile.dev", image, extra_args: extra) unless image_exists?("#{image}:#{ood_image_tag}")
    sh tag_latest_container_cmd(image)
  end

  desc "Build a container with last night's package"
  task :nightly_container do
    image = image_names[:ood] # making a real ood image
    tag = nightly_version_simple

    sh build_cmd("Dockerfile.nightly", image, image_tag: tag) unless image_exists?("#{image}:#{tag}")
    sh tag_latest_container_cmd(image, image_tag: tag)

    # FIXME: this really the best way to pass args to this task?
    ENV['_OOD_PKG_NIGHTLY'] = 'true'
    Rake::Task['package:dev_container'].invoke
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
