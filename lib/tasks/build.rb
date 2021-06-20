require_relative 'build_utils'
include BuildUtils

namespace :build do

  task :verify_build_args, [:platform, :version] do |task, args|
    raise "Need to specify platform and version" if args[:platform].nil? || args[:version].nil?
  end

  desc "Create buildbox for Open OnDemand"
  task :build_box, [:platform, :version] => [:verify_build_args] do |task, args|
    platform = args[:platform].to_s
    image_tag = "#{platform}-#{args[:version]}"
    cmd = build_cmd(
      template_file("Dockerfile.#{platform}.erb"), 
      image_names[:build_box],
      image_tag: build_box_tag(args)
    )

    sh cmd unless image_exists?(build_box_image(args))
  end

  task :build_in_image, [:platform, :version] => [:build_box] do |task, args|
    platform = args[:platform].to_s
    version = args[:version].to_s

    work_dir = "/build"
    bundle_host = "#{build_dir(args)}/vendor/bundle".tap { |p| sh "mkdir -p #{p}" }
    node_host = "#{build_dir(args)}/node_modules".tap { |p| sh "mkdir -p #{p}" }
    bundle_ctr = "/vendor/bundle"
    node_ctr = "#{work_dir}/apps/dashboard/node_modules"
    build_args = ["--rm", "-v", "#{bundle_host}:#{bundle_ctr}"]
    build_args.concat [ "-e", "VENDOR_BUNDLE_PATH=#{bundle_ctr}", "-e", "VENDOR_BUNDLE=true"]
    build_args.concat ["-v", "#{node_host}:#{node_ctr}"]
    build_args.concat ["-v", "#{PROJ_DIR}:#{work_dir}", "-w", "#{work_dir}"]

    build_args.concat [ build_box_image(args), "rake", "build" ]
    sh "#{container_runtime} run #{build_args.join(' ')}"
  end
end
