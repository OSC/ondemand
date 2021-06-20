module BuildUtils
  def ood_image_tag
    tag? ? numeric_tag : "#{numeric_tag}-#{git_hash}"
  end

  def ood_version
    tag? ? git_tag : "#{git_tag}-#{git_hash}"
  end

  def git_hash
    @git_hash ||= `git rev-parse HEAD`.strip[0..6]
  end

  def git_tag
    @git_tag ||= `git describe --tags --abbrev=0`.chomp
  end

  def numeric_tag
    @numeric_tag ||= git_tag.delete_prefix('v')
  end

  def tag?
    @tag ||= `git describe --exact-match --tags HEAD 2>/dev/null`.to_s != ""
  end

  def podman_runtime?
    @podman_runtime ||= ENV['CONTAINER_RT'] == "podman"
  end

  def container_runtime
    podman_runtime? ? "podman" : "docker"
  end

  def test_image_name
    "ood-test"
  end

  def dev_image_name
    "ood-dev"
  end

  def image_name
    "ood"
  end

  def current_user
    @current_user ||= begin
      username = Etc.getlogin
      pwnam = Etc.getpwnam(username)
      "#{pwnam.uid}:#{pwnam.gid}"
    end
  end

  def image_names
    @image_names ||=
    {
      build_box: "ood-buildbox",
      ood: "ood",
      test: "ood-test",
      dev: "ood-dev"
    }.freeze
  end

  def build_dir(platform, version)
    "#{PROJ_DIR}/build/#{platform}/#{version}"
  end

  def image_exists?(image_name)
    `#{container_runtime} inspect --type image --format exists #{image_name} || true`.chomp.eql?('exists')
  end

  def buildah_build_cmd(docker_file, image_name, image_tag: ood_image_tag, extra_args: [])
    args = ["bud", "--build-arg", "VERSION=#{ood_version}"]
    args.concat ["-t", "#{image_name}:#{image_tag}", "-f", docker_file]
    args.concat extra_args

    "buildah #{args.join(' ')}"
  end

  def docker_build_cmd(docker_file, image_name, image_tag: ood_image_tag, extra_args: [])
    args = ["build", "--build-arg", "VERSION=#{ood_version}"]
    args.concat ["-t", "#{image_name}:#{image_tag}", "-f", docker_file, "."]
    args.concat extra_args

    "docker #{args.join(' ')}"
  end

  def build_cmd(file, image_name, image_tag: nil, extra_args: [])
    if podman_runtime?
      buildah_build_cmd(file, image_name, image_tag: image_tag, extra_args: extra_args)
    else
      docker_build_cmd(file, image_name, image_tag: image_tag, extra_args: extra_args)
    end
  end

  def tag_latest_container_cmd(image_name)
    "#{container_runtime} tag #{image_name}:#{image_tag} #{image_name}:latest"
  end

  def template_file(filename)
    cwd = "#{File.expand_path(__dir__)}"
    "#{cwd}/templates/#{filename}"
  end
end
