require_relative 'build_utils'
include BuildUtils

namespace :build do

  desc "Create buildbox for Open OnDemand"
  task :build_box, [:platform, :version] do |task, args|
    platform = "#{args[:platform] || 'ubuntu' }"
    image_tag = "#{platform}-#{args[:version] || '20.04-1'}"
    cmd = build_cmd(
      template_file("Dockerfile.#{platform}.erb"), 
      image_names[:build_box],
      image_tag: image_tag
    )

    sh cmd unless image_exists?("#{image_names[:build_box]}:#{image_tag}")
  end

  task :build_in_image, [:platform, :version] do |task, args|
    platform = "#{args[:platform] || 'ubuntu' }"
    version = "#{args[:version] || '20.04-1'}"
    image_tag = "#{platform}-#{version}"
    image = "#{image_names[:build_box]}:#{image_tag}"

    work_dir = "/build"
    bundle_host = "#{build_dir(platform, version)}/vendor/bundle".tap { |p| sh "mkdir -p #{p}" }
    node_host = "#{build_dir(platform, version)}/node_modules".tap { |p| sh "mkdir -p #{p}" }
    bundle_ctr = "/vendor/bundle"
    node_ctr = "#{work_dir}/apps/dashboard/node_modules"
    args = ["--rm", "-v", "#{bundle_host}:#{bundle_ctr}"]
    args.concat [ "-e", "VENDOR_BUNDLE_PATH=#{bundle_ctr}", "-e", "VENDOR_BUNDLE=true"]
    args.concat ["-v", "#{node_host}:#{node_ctr}"]
    args.concat ["-v", "#{PROJ_DIR}:#{work_dir}", "-w", "#{work_dir}"]

    args.concat [ image, "rake", "build" ]
    sh "#{container_runtime} run #{args.join(' ')}"
  end
end
