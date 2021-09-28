module BuildUtils
  def ood_image_tag
    tag? ? numeric_tag : "#{numeric_tag}-#{git_hash}"
  end

  def ood_version
    tag? ? git_tag : "#{git_tag}-#{git_hash}"
  end

  def ood_package_version
    @ood_package_version ||= begin
      if ! ENV['VERSION']
        tag? ? git_tag : "#{git_tag}-#{build_timestamp}-#{git_hash}"
      else
        ENV['VERSION'].to_s
      end
    end
  end

  def build_timestamp
    @build_timestamp ||= Time.now.strftime("%s")
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

  def tar
    `which gtar 1>/dev/null 2>&1`
    $?.success? ? 'gtar' : 'tar'
  end

  def ood_package_name
    "ondemand"
  end

  def versioned_ood_package
    "#{ood_package_name}-#{ood_package_version}"
  end

  def ood_package_tar
    "#{versioned_ood_package}.tar.gz"
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

  def build_dir(args)
    "#{PROJ_DIR}/build/#{build_box_tag(args)}"
  end

  # TODO: continue vendor/ convention? Seems as good as any other name.
  def vendor_src_dir
    "vendor/ood/src".tap { |p| sh "mkdir -p #{p}" }
  end

  def vendor_build_dir
    "vendor/ood/build".tap { |p| sh "mkdir -p #{p}" }
  end

  def build_box_tag(args)
    base_name = "#{args[:platform]}-#{args[:version]}"
    @version_lookup ||= {
      'ubuntu-20.04': "1"
    }.freeze

    "#{base_name}-#{@version_lookup[base_name.to_sym]}"
  end

  def build_box_image(args)
    "#{image_names[:build_box]}:#{build_box_tag(args)}"
  end

  def image_exists?(image_name)
    `#{container_runtime} inspect --type image --format exists #{image_name} || true`.chomp.eql?('exists')
  end

  def nginx_version
    "1.18.0"
  end

  def passenger_version
    "6.0.7"
  end

  def nginx_tar
    "nginx-#{nginx_version}-x86_64-linux.tar.gz"
  end

  def nginx_tar_url
    "#{passenger_release_url}/#{nginx_tar}"
  end

  def passenger_base_url
    "https://github.com/phusion/passenger/releases/download"
  end

  def passenger_release_url
    "#{passenger_base_url}/release-#{passenger_version}"
  end

  def passenger_tar
    "passenger-#{passenger_version}.tar.gz"
  end

  def passenger_tar_url
    "#{passenger_release_url}/#{passenger_tar}"
  end

  def passenger_agent_tar_url
    "#{passenger_release_url}/agent-x86_64-linux.tar.gz"
  end

  def passenger_agent_tar
    "passenger-agent-#{passenger_version}.tar.gz"
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

  def build_cmd(file, image_name, image_tag: ood_image_tag, extra_args: [])
    if podman_runtime?
      buildah_build_cmd(file, image_name, image_tag: image_tag, extra_args: extra_args)
    else
      docker_build_cmd(file, image_name, image_tag: image_tag, extra_args: extra_args)
    end
  end

  def tag_latest_container_cmd(image_name, image_tag: ood_image_tag)
    "#{container_runtime} tag #{image_name}:#{image_tag} #{image_name}:latest"
  end

  def template_file(filename)
    cwd = "#{File.expand_path(__dir__)}"
    "#{cwd}/templates/#{filename}"
  end

  def task_file(filename)
    cwd = "#{File.expand_path(__dir__)}"
    "#{cwd}/files/#{filename}"
  end

  def ood_bin_dir
    "#{INSTALL_ROOT}/bin"
  end

  def rt_specific_flags
    if podman_runtime?
      ['--security-opt', 'label=disable'] # SELinux doesn't like it if you're mounting from $HOME
    else
      []
    end
  end
end
