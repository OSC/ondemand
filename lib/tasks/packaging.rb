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

  task :tar do
    `which gtar 1>/dev/null 2>&1`
    if $?.success?
      tar = 'gtar'
    else
      tar = 'tar'
    end

    version = ENV['VERSION']

    if ! version
      latest_commit = `git rev-list --tags --max-count=1`.strip[0..6]
      latest_tag = `git describe --tags #{latest_commit}`.strip[1..-1]
      datetime = Time.now.strftime("%Y%m%d-%H%M")
      version = "#{latest_tag}-#{datetime}-#{latest_commit}"
    end

    sh "git ls-files | #{tar} -c --transform 's,^,ondemand-#{version}/,' -T - | gzip > packaging/v#{version}.tar.gz"
  end

  task container: [:clean] do
    sh build_cmd("Dockerfile", image_name) unless image_exists?("#{image_name}:#{image_tag}")
  end

  task latest_container: [:container] do
    sh tag_latest_container_cmd(image_name)
  end

  task test_container: [:latest_container] do
    sh build_cmd("Dockerfile.test", test_image_name) unless image_exists?("#{test_image_name}:#{image_tag}")
    sh tag_latest_container_cmd(test_image_name)
  end

  task dev_container: [:latest_container] do
    if ENV['OOD_KEEP_USERNS'].to_s.empty?
      extra = []
    else
      username = Etc.getlogin
      extra = ["--build-arg", "USER=#{username}"]
      extra.concat ["--build-arg", "UID=#{Etc.getpwnam(username).uid}"]
      extra.concat ["--build-arg", "GID=#{Etc.getpwnam(username).uid}"]
    end

    sh build_cmd("Dockerfile.dev", dev_image_name, extra_args: extra) unless image_exists?("#{dev_image_name}:#{image_tag}")
    sh tag_latest_container_cmd(dev_image_name)
  end
end