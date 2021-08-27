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

  task :debuild, [:platform, :version] => [:build_box] do |task, args|
    dir = build_dir(args)
    Rake::Task['package:tar'].invoke(dir)
    sh "#{tar} -xzf #{dir}/#{ood_package_tar} -C #{dir}"

    work_dir = "/build/#{versioned_ood_package}"

    # FIXME - --userns is a podman flag
    base_args = ["--rm", "--user", "1000:1000", "--userns", "keep-id"]
    base_args.concat ["-v", "#{dir}:/build", "-w", "#{work_dir}"]
    base_args.concat ["-e", "DEBUILD_DPKG_BUILDPACKAGE_OPTS='-us -uc -I -i'"]
    base_args.concat ["-e", "HOME=/home/deb", "-e", "USER=deb"]
    base_args.concat [ build_box_image(args)]
    sh "#{container_runtime} run #{base_args.join(' ')} debmake -b':ruby'"

    debuild_args = ["debuild", "--no-lintian"]
    sh "#{container_runtime} run #{base_args.join(' ')} #{debuild_args.join(' ')}"
  end

  task :nginx, [:platform, :version] => [:build_box] do |task, args|
    tar = "#{build_src_dir}/#{nginx_tar}"
    sh "wget #{nginx_tar_url} -O #{tar}" unless File.exist?(tar)
  end

  task :passenger, [:platform, :version] => [:build_box] do |task, args|
    tar = "#{build_src_dir}/#{passenger_tar}"
    sh "wget #{passenger_tar_url} -O #{tar}" unless File.exist?(tar)

    # agent tar isn't versioned, so let's do that now.
    agent_tar = "#{build_src_dir}/passenger-agent-#{passenger_version}.tar.gz"
    sh "wget #{passenger_agent_tar_url} -O #{agent_tar}" unless File.exist?(agent_tar)

    work_dir = "/build"
    passenger_host = "#{build_dir(args)}/passenger".tap { |p| sh "mkdir -p #{p}" }
    sh "#{tar} --strip-components=1 -xzf #{tar} -C #{passenger_host}"

    base_args = ["--rm", "-v", "#{passenger_host}:#{work_dir}", "-w", "#{work_dir}"]
    base_args.concat [ build_box_image(args) ]
    makefile_args = base_args + [ "ruby", "#{work_dir}/src/ruby_native_extension/extconf.rb" ]

    sh "#{container_runtime} run #{makefile_args.join(' ')}"
    sh "#{container_runtime} run #{base_args.join(' ')} make"
  end
end
