desc "Package OnDemand"
namespace :package do

  require_relative 'build_utils'
  include BuildUtils

  def image_exists?(image_name)
    `#{container_runtime} inspect --type image --format exists #{image_name} || true`.chomp.eql?('exists')
  end

  def buildah_build_cmd(docker_file, image_name, extra_args: [])
    args = ["bud", "--build-arg", "VERSION=#{ood_version}"]
    args.concat ["-t", "#{image_name}:#{image_tag}", "-f", docker_file]
    args.concat extra_args

    "buildah #{args.join(' ')}"
  end

  def docker_build_cmd(docker_file, image_name, extra_args: [])
    args = ["build", "--build-arg", "VERSION=#{ood_version}"]
    args.concat ["-t", "#{image_name}:#{image_tag}", "-f", docker_file, "."]
    args.concat extra_args

    "docker #{args.join(' ')}"
  end

  def build_cmd(file, image_name, extra_args: [])
    if podman_runtime?
      buildah_build_cmd(file, image_name, extra_args: extra_args)
    else
      docker_build_cmd(file, image_name, extra_args: extra_args)
    end
  end

  def tag_latest_container_cmd(image_name)
    "#{container_runtime} tag #{image_name}:#{image_tag} #{image_name}:latest"
  end

  desc "Build the ood image"
  task :container do
    sh build_cmd("Dockerfile", image_name) unless image_exists?("#{image_name}:#{image_tag}")
  end

  desc "Build docker container and create image"
  task latest_container: [:container] do
    sh tag_latest_container_cmd(image_name)
  end

  desc "Build container with Dockerfile.test"
  task test_container: [:latest_container] do
    sh build_cmd("Dockerfile.test", test_image_name) unless image_exists?("#{test_image_name}:#{image_tag}")
    sh tag_latest_container_cmd(test_image_name)
  end

  desc "Build container with Dockerfile.dev"
  task dev_container: [:latest_container] do
    extra = ["--build-arg", "USER=#{user.name}"]
    extra.concat ["--build-arg", "UID=#{user.uid}"]
    extra.concat ["--build-arg", "GID=#{user.gid}"]

    sh build_cmd("Dockerfile.dev", dev_image_name, extra_args: extra) unless image_exists?("#{dev_image_name}:#{image_tag}")
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
    OodPackaging::RakeTask.new(:build, [:dist]) do |t, args|
      t.package = proj_root
      t.dist = args[:dist]
      t.version = ood_package_version
      t.tar = true
      t.work_dir = File.join(proj_root, 'tmp/work')
      t.output_dir = File.join(proj_root, 'dist')
      t.skip_download = true
      t.clean_output_dir = false
    end
  rescue LoadError, NameError
  end
end
