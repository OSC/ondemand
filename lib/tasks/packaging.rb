desc "Package OnDemand"
namespace :package do

  require_relative 'build_utils'
  include BuildUtils

  def image_exists?(image_name)
    cmd = "#{container_runtime} images #{image_name} --format '{{.ID}}'"
    !`#{cmd}`.empty?
  end

  def buildah_build_cmd(docker_file, image_name)
    args = ["bud", "--build-arg", "VERSION=#{ood_version}"]
    args.concat ["-t", "#{image_name}:#{image_tag}", "-f", docker_file]

    "buildah #{args.join(' ')}"
  end

  def docker_build_cmd(docker_file, image_name)
    args = ["build", "--build-arg", "VERSION=#{ood_version}"]
    args.concat ["-t", "#{image_name}:#{image_tag}", "-f", docker_file, "."]

    "docker #{args.join(' ')}"
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
    file = "lib/tasks/container_files/Dockerfile.base"
    cmd = podman_runtime? ? buildah_build_cmd(file, image_name) : docker_build_cmd(file, image_name)
    sh cmd unless image_exists?("ood:#{image_tag}")
  end

  task latest_container: [:container] do
    sh tag_latest_container_cmd("ood")
  end

  task test_container: [:latest_container] do
    file = "lib/tasks/container_files/Dockerfile.test"
    build_cmd = podman_runtime? ? buildah_build_cmd(file, test_image_name) : docker_build_cmd(file, test_image_name)
    sh build_cmd unless image_exists?("#{test_image_name}:#{image_tag}")
    sh tag_latest_container_cmd(test_image_name)
  end
end