namespace :install do



  task :bin_dir do
    sh "mkdir -p #{ood_bin_dir}"
  end

  task nginx: [:bin_dir] do
    tar = "#{vendor_src_dir}/#{nginx_tar}"
    sh "tar -xzf #{tar} -C #{INSTALL_ROOT}/bin"
    sh "mv #{INSTALL_ROOT}/bin/nginx-#{nginx_version} #{INSTALL_ROOT}/bin/nginx"
    sh "chmod 755 #{INSTALL_ROOT}/bin/nginx"
  end

end