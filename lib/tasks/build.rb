require_relative 'build_utils'
include BuildUtils

namespace :build do

  desc "Create buildbox for Open OnDemand"
  task :build_box, [:platform, :version] do |task, args|
    platform = "#{args[:platform] || "ubuntu"}"
    image_tag = "#{platform}-#{args[:version] || '20.04-1'}"
    cmd = build_cmd(
      template_file("Dockerfile.#{platform}.erb"), 
      image_names[:build_box],
      image_tag: image_tag
    )

    sh cmd unless image_exists?("#{image_names[:build_box]}:#{image_tag}")
  end

  task :build_in_image, [:platform, :version] do |task, args|
    platform = "#{args[:platform] || "ubuntu"}"
    version = "#{args[:version] || '20.04-1'}"
    image_tag = "#{platform}-#{version}"
    image = "#{image_names[:build_box]}:#{image_tag}"

    work_dir = "/build"
    bundle_host = "#{PROJ_DIR}/build/#{platform}/#{version}".tap { |p| sh "mkdir -p #{p}" }
    bundle_ctr = "/vendor/bundle"
    args = ["--rm", "-v", "#{bundle_host}:#{bundle_ctr}"]
    args.concat [ "-e", "VENDOR_BUNDLE_PATH=#{bundle_ctr}", "-e", "VENDOR_BUNDLE=true"]
    args.concat ["-v", "#{PROJ_DIR}:#{work_dir}", "-w", "#{work_dir}"]
    args.concat ["-v", "#{PROJ_DIR}:#{work_dir}", "-w", "#{work_dir}"]

    args.concat [ image, "rake", "build" ]
    sh "#{container_runtime} run #{args.join(' ')}"
  end
end
