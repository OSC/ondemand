desc "Package OnDemand"
namespace :package do

  require_relative 'build_utils'
  include BuildUtils

  task :tar, [:output_dir] do |task, args|
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

  task latest_container: [:container] do
    sh tag_latest_container_cmd(image_names[:ood])
  end

  task test_container: [:latest_container] do
    sh build_cmd("Dockerfile.test", test_image_name) unless image_exists?("#{test_image_name}:#{ood_image_tag}")
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

    sh build_cmd("Dockerfile.dev", dev_image_name, extra_args: extra) unless image_exists?("#{dev_image_name}:#{ood_image_tag}")
    sh tag_latest_container_cmd(dev_image_name)
  end
end
