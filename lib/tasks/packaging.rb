desc "Package OnDemand"
namespace :package do

  require_relative 'build_utils'
  include BuildUtils

  def git_clone_packaging(branch, dir)
    args = ["clone", "--single-branch"]
    args.concat ["--branch", branch]
    args.concat ["https://github.com/OSC/ondemand-packaging.git", dir]

    "git #{args.join(' ')}"
  end

  def rpm_build_cmd(packaging_dir, work_dir, output_dir, dist, version, extra_args)
    args = ["-w", work_dir, "-o", output_dir]
    args.concat ["-d", dist, "-V", "v#{version}", "-C"]

    "#{File.join(packaging_dir, 'build.sh')} #{args.join(' ')} #{extra_args} #{File.join(Dir.pwd, 'packaging', 'rpm')}"
  end

  desc "Tar and zip OnDemand into packaging dir with version name v#<version>"
  task :tar do
    version = ENV['VERSION'] || ENV['CI_COMMIT_TAG']
    version = version.gsub(/^v/, '') unless version.nil?

    if ! version
      latest_commit = `git rev-list --tags --max-count=1`.strip[0..6]
      latest_tag = `git describe --tags #{latest_commit}`.strip[1..-1]
      datetime = Time.now.strftime("%Y%m%d-%H%M")
      version = "#{latest_tag}-#{datetime}-#{latest_commit}"
    end

    sh "git ls-files | #{tar} -c --transform 's,^,ondemand-#{version}/,' -T - | gzip > packaging/rpm/v#{version}.tar.gz"
  end

  # TODO: refactor these 2 tar tasks. Debian and RHEL expect slightly different names and
  # what's worse is the whole v prefixing mess
  task :debian_tar, [:output_dir] do |task, args|
    dir = "#{args[:output_dir] || 'packaging'}".tap { |p| sh "mkdir -p #{p}" }
    tar_file = "#{dir}/#{ood_package_tar}"

    sh "rm #{tar_file}" if File.exist?(tar_file)
    sh "git ls-files | #{tar} -c --transform 's,^,#{versioned_ood_package}/,' -T - | gzip > #{tar_file}"
  end

  task :deb, [:platoform, :version] do |task, args|
    Rake::Task['build:debuild'].invoke('ubuntu', args[:version] || '20.04')
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
  task :rpm, [:dist, :extra_args] => :tar do |t, args|
    version = ENV['VERSION'] || ENV['CI_COMMIT_TAG']
    version = version.gsub(/^v/, '') unless version.nil?
    version_major, version_minor, version_patch = version.split('.', 3)
    dist = args[:dist]
    extra_args = args[:extra_args].nil? ? '' : args[:extra_args]
    tmp_dir = File.join(Dir.pwd, 'tmp')
    dist_dir = File.join(Dir.pwd, "dist")
    packaging_dir = File.join(tmp_dir, "ondemand-packaging")

    Dir.mkdir(tmp_dir) unless Dir.exist?(tmp_dir)
    Dir.mkdir(dist_dir) unless Dir.exist?(dist_dir)
    sh git_clone_packaging("#{version_major}.#{version_minor}", packaging_dir) unless Dir.exist?(packaging_dir)
    sh rpm_build_cmd(packaging_dir, File.join(tmp_dir, "work"), dist_dir, dist, version, extra_args)
  end

  namespace :rpm do
    desc "Build nightly RPM"
    task :nightly, [:dist, :extra_args] do |t, args|
      version_major, version_minor, version_patch = git_tag.gsub(/^v/, '').split('.', 3)
      date = Time.now.strftime("%Y%m%d")
      id = ENV['CI_PIPELINE_ID'] || Time.now.strftime("%H%M%S")
      ENV['VERSION'] = "#{version_major}.#{version_minor}.#{date}-#{id}.#{git_hash}.nightly"
      Rake::Task['package:rpm'].invoke(args[:dist], args[:extra_args])
    end
  end
end
