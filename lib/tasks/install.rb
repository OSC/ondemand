require_relative 'build_utils'

namespace :install do

  include BuildUtils

  def nginx_root
    "#{INSTALL_ROOT}/nginx"
  end

  def nginx_conf
    "#{nginx_root}/conf"
  end

  def nginx_bin_dir
    "#{nginx_root}/bin"
  end

  task :install_root do
    sh "mkdir -p #{INSTALL_ROOT}"
  end

  task nginx: [:install_root] do
    tar_file = "#{vendor_src_dir}/#{nginx_tar}"
    sh "mkdir -p #{nginx_bin_dir}"
    sh "#{tar} -xzf #{tar_file} -C #{nginx_bin_dir}"
    sh "install -m 755 #{nginx_bin_dir}/nginx-#{nginx_version} #{nginx_bin_dir}/nginx"

    sh "mkdir -p #{nginx_conf}"
    sh "install -m 644 #{task_file('mime.types')} #{nginx_conf}/mime.types"
  end

  task passenger: [:install_root] do
    # best way the ruby system lib dir?
    lib_dir = $:.select do |p|
      p.start_with?('/usr/lib')
    end.first.tap do |p|
      sh "mkdir -p #{DESTDIR}/#{p}"
    end

    sh "mv #{vendor_build_dir}/passenger #{INSTALL_ROOT}"
    sh "mv #{INSTALL_ROOT}/passenger/passenger_native_support.so #{DESTDIR}/#{lib_dir}"
  end
end
