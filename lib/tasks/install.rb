namespace :install do



  task :install_root do
    sh "mkdir -p #{INSTALL_ROOT}"
  end

  task nginx: [:install_root] do
    tar = "#{vendor_src_dir}/#{nginx_tar}"
    sh "#{tar} -xzf #{tar} -C #{INSTALL_ROOT}/bin"
    sh "mv #{INSTALL_ROOT}/bin/nginx-#{nginx_version} #{INSTALL_ROOT}/bin/nginx"
    sh "chmod 755 #{INSTALL_ROOT}/bin/nginx"
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
