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
    base_args.concat ["-e", "VERSION=#{ENV['VERSION']}"] unless ENV['VERSION'].nil?
    base_args.concat rt_specific_flags
    base_args.concat [build_box_image(args)]
    sh "#{container_runtime} run #{base_args.join(' ')} debmake -b':ruby'"

    debuild_args = ["debuild", "--no-lintian"]
    sh "#{container_runtime} run #{base_args.join(' ')} #{debuild_args.join(' ')}"
  end

  task :nginx do
    tar_file = "#{vendor_src_dir}/#{nginx_tar}"
    sh "curl -L #{nginx_tar_url} -o #{tar_file}" unless File.exist?(tar_file)
  end

  task :passenger do
    passenger_tar_full = "#{vendor_src_dir}/#{passenger_tar}"
    agent_tar_full = "#{vendor_src_dir}/#{passenger_agent_tar}"
    sh "curl -L #{passenger_tar_url} -o #{passenger_tar_full}" unless File.exist?(passenger_tar_full)
    sh "curl -L #{passenger_agent_tar_url} -o #{agent_tar_full}" unless File.exist?(agent_tar_full)

    work_dir = "#{vendor_build_dir}/passenger".tap { |p| sh "mkdir -p #{p}" }
    sh "ls -lRta #{work_dir}"
    sh "#{tar} --strip-components=1 -xzf #{passenger_tar_full} -C #{work_dir}"

    chdir work_dir do
      sh "ruby src/ruby_native_extension/extconf.rb"
      sh "make"
    end
  end
end
