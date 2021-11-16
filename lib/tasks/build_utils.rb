# frozen_string_literal: true

module BuildUtils
  def proj_root
    File.expand_path(File.join(File.dirname(__FILE__), '../..'))
  end

  def ood_image_tag
    tag? ? numeric_tag : "#{numeric_tag}-#{git_hash}"
  end

  def ood_version
    tag? ? git_tag : "#{git_tag}-#{git_hash}"
  end

  def ood_package_version
    @ood_package_version ||= begin
      if ENV['VERSION']
        ENV['VERSION'].to_s
      elsif ENV['CI_COMMIT_TAG']
        ENV['CI_COMMIT_TAG'].to_s
      else
        tag? ? git_tag : "#{git_tag}.#{build_timestamp}-#{git_hash}"
      end
    end
    @ood_package_version.gsub(/^v/, '')
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

  def nightly_version
    version_major, version_minor, version_patch = git_tag.gsub(/^v/, '').split('.', 3)
    date = Time.now.strftime("%Y%m%d")
    id = ENV['CI_PIPELINE_ID'] || Time.now.strftime("%H%M%S")
    "#{version_major}.#{version_minor}.#{date}-#{id}.#{git_hash}.nightly"
  end

  def rpm_nightly_version
    nightly_version
  end

  def deb_nightly_version
    nightly_version.gsub('-', '.')
  end

  def rpm_version
    ood_package_version
  end

  def deb_version
    ood_package_version.gsub('-', '.')
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

  def user
    @user ||= Etc.getpwnam(Etc.getlogin)
  end

  def image_names
    @image_names ||=
    {
      ood: "ood",
      test: "ood-test",
      dev: "ood-dev"
    }.freeze
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

  def package_file(filename)
    File.join(proj_root, 'packaging/files', filename)
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

  def container_userns_flag
    return ["--userns", "keep-id"] if container_runtime == "podman"
    []
  end

  def os_release
    @os_release ||= begin
      if File.exist?('/etc/os-release')
        Dotenv.parse('/etc/os-release')
      else
        {}
      end
    end
  end

  def scl_apache?
    return true if (el? && os_release['VERSION_ID'] =~ /^7/)
    false
  end

  def el?
    return true if "#{os_release['ID']} #{os_release['ID_LIKE']}" =~ /(rhel|fedora)/
    false
  end

  def debian?
    return true if (os_release['ID'] =~ /(ubuntu|debian)/ or os_release['ID_LIKE'] == 'debian')
    false
  end

  def apache_daemon
    return '/opt/rh/httpd24/root/usr/sbin/httpd-scl-wrapper' if scl_apache?
    "/usr/sbin/#{apache_service}"
  end

  def apache_reload
    return '/usr/sbin/apachectl graceful' if debian?
    "#{apache_daemon} $OPTIONS -k graceful"
  end

  def apache_user
    return 'www-data' if debian?
    'apache'
  end

  def apache_service
    return 'apache2' if debian?
    return 'httpd24-httpd' if scl_apache?
    'httpd'
  end
end
