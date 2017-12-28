namespace :ood do
  desc "Display the environment created after boot"
  task :env  do
    puts ENV.map{ |k,v| "#{k}: #{v}" }.join("\n")
  end
end
