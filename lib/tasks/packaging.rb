desc "Package OnDemand"
namespace :package do

  require_relative 'build_utils'
  include BuildUtils

  def rpm_build_cmd(packaging_dir, work_dir, output_dir, dist, version, extra_args)
    args = ["-w", work_dir, "-o", output_dir]
    args.concat ["-d", dist, "-V", "v#{version}", "-C"]

    "#{File.join(packaging_dir, 'build.sh')} #{args.join(' ')} #{extra_args} #{File.join(Dir.pwd, 'packaging', 'rpm')}"
  end

  def deb_build_cmd(packaging_dir, work_dir, output_dir, dist, version, extra_args)
    args = ["-w", work_dir, "-o", output_dir]
    args.concat ["-D", dist, "-V", version, "-C"]

    "#{File.join(packaging_dir, 'build.sh')} #{args.join(' ')} #{extra_args} #{Dir.pwd}"
  end

  desc 'Git clone packaging repo'
  task :packaging_repo, [:branch, :dir] do |t, args|
    branch = ENV['PACKAGING_REPO_BRANCH'] || args[:branch] || 'master'
    if args[:dir]
      dir = args[:dir]
    else
      tmp_dir = File.join(Dir.pwd, 'tmp').tap { |d| "mkdir -p #{d}" }
      dir = File.join(tmp_dir, 'ondemand-packaging')
    end
    cmd = ['git', 'clone', '--single-branch']
    cmd.concat ["--branch", branch]
    cmd.concat ["https://github.com/OSC/ondemand-packaging.git", dir]

    sh cmd.join(' ') unless Dir.exist?(dir)
  end

  desc "Tar and zip OnDemand into packaging dir"
  task :tar, [:dist] do |task, args|
    dist = args[:dist] || 'el8'
    cmd = ['git', 'ls-files', '|', tar, '-c']
    if dist =~ /^el/
      version = rpm_version
      tar_file = "packaging/rpm/v#{version}.tar.gz"
    else
      dir = File.join(Dir.pwd, 'build').tap { |p| sh "mkdir -p #{p}" }
      version = deb_version
      tar_file = "#{dir}/#{ood_package_name}-#{version}.tar.gz"
      cmd.concat ["--transform 'flags=r;s,packaging/deb,debian,'"]
    end
    cmd.concat ["--transform 's,^,#{ood_package_name}-#{version}/,'"]
    cmd.concat ['-T', '-', '|', "gzip > #{tar_file}"]

    sh "rm #{tar_file}" if File.exist?(tar_file)
    sh cmd.join(' ')
  end

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

  desc "Build RPM"
  task :rpm, [:dist, :extra_args] => [:tar] do |t, args|
    version = rpm_version
    version_major, version_minor, version_patch = version.split('.', 3)
    dist = args[:dist]
    extra_args = args[:extra_args].nil? ? '' : args[:extra_args]
    tmp_dir = File.join(Dir.pwd, 'tmp')
    dist_dir = File.join(Dir.pwd, "dist")
    packaging_dir = File.join(tmp_dir, "ondemand-packaging")

    Dir.mkdir(tmp_dir) unless Dir.exist?(tmp_dir)
    Dir.mkdir(dist_dir) unless Dir.exist?(dist_dir)
    Rake::Task['package:packaging_repo'].invoke("#{version_major}.#{version_minor}", packaging_dir)
    sh rpm_build_cmd(packaging_dir, File.join(tmp_dir, "work"), dist_dir, dist, version, extra_args)
  end

  namespace :rpm do
    desc "Build nightly RPM"
    task :nightly, [:dist, :extra_args] do |t, args|
      ENV['VERSION'] = rpm_nightly_version
      Rake::Task['package:rpm'].invoke(args[:dist], args[:extra_args])
    end
  end

  desc "Build deb package"
  task :deb, [:dist, :extra_args] => [:tar] do |t, args|
    version = deb_version
    version_major, version_minor, version_patch = version.split('.', 3)
    dist = args[:dist]
    extra_args = args[:extra_args].nil? ? '' : args[:extra_args]
    tmp_dir = File.join(Dir.pwd, 'tmp')
    dist_dir = File.join(Dir.pwd, "dist")
    packaging_dir = File.join(tmp_dir, "ondemand-packaging")

    Dir.mkdir(tmp_dir) unless Dir.exist?(tmp_dir)
    Dir.mkdir(dist_dir) unless Dir.exist?(dist_dir)
    Rake::Task['package:packaging_repo'].invoke("#{version_major}.#{version_minor}", packaging_dir)
    sh deb_build_cmd(packaging_dir, File.join(tmp_dir, "work"), dist_dir, dist, version, extra_args)
  end

  namespace :deb do
    desc "Build nightly deb package"
    task :nightly, [:dist, :extra_args] do |t, args|
      ENV['VERSION'] = deb_nightly_version
      Rake::Task['package:deb'].invoke(args[:dist], args[:extra_args])
    end
  end
end
