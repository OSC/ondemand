# frozen_string_literal: true

require_relative 'build_utils'
require 'erb'

namespace :install do
  include BuildUtils

  def nginx_root
    "#{INSTALL_ROOT}/nginx".tap { |d| sh "mkdir -p #{d}" }
  end

  def nginx_conf
    "#{nginx_root}/conf".tap { |d| sh "mkdir -p #{d}" }
  end

  def nginx_bin_dir
    "#{nginx_root}/bin".tap { |d| sh "mkdir -p #{d}" }
  end

  def passenger_root
    "#{INSTALL_ROOT}/passenger".tap { |d| sh "mkdir -p #{d}" }
  end

  def passenger_lib_dir
    "#{passenger_root}/lib".tap { |d| sh "mkdir -p #{d}" }
  end

  def passenger_src_dir
    "#{passenger_root}/src"
  end

  def passenger_bin_dir
    "#{passenger_root}/bin"
  end

  def passenger_ini_dir
    # easier to use default then to try another path
    "#{INSTALL_ROOT}/ondemand/root/usr/share/ruby/vendor_ruby/phusion_passenger".tap { |d| sh "mkdir -p #{d}" }
  end

  task :install_root do
    sh "mkdir -p #{INSTALL_ROOT}"
  end

  task nginx: [:install_root] do
    tar_file = "#{vendor_src_dir}/#{nginx_tar}"
    sh "#{tar} -xzf #{tar_file} -C #{nginx_bin_dir}"
    sh "install -m 755 #{nginx_bin_dir}/nginx-#{nginx_version} #{nginx_bin_dir}/nginx"
    sh "install -m 644 #{task_file('mime.types')} #{nginx_conf}/mime.types"
  end

  task passenger: [:install_root] do
    # best way to find the ruby system lib dir?
    lib_dir = $LOAD_PATH.select do |p|
      p.start_with?('/usr/lib')
    end.first.tap do |p|
      sh "mkdir -p #{DESTDIR}/#{p}"
    end

    # mv probably not right here. install? didn't work at first
    sh "mv #{vendor_build_dir}/passenger/passenger_native_support.so #{DESTDIR}/#{lib_dir}"
    sh "mv #{vendor_build_dir}/passenger #{INSTALL_ROOT}"
    sh "#{tar} -xzf #{vendor_src_dir}/#{passenger_agent_tar} -C #{passenger_lib_dir}"

    File.open("#{passenger_ini_dir}/locations.ini", 'w') do |f|
      content = File.read(template_file('locations.ini.erb'))
      f.write(ERB.new(content, nil, '-').result(binding))
    end
  end
end
