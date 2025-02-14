require "pathname"
require "time"

PROJ_DIR          = Pathname.new(__dir__)
TASK_DIR          = "#{PROJ_DIR}/lib/tasks"
APPS_DIR          = PROJ_DIR.join('apps')
GEMFILE           = PROJ_DIR.join('Gemfile')
DESTDIR           = Pathname.new(ENV['DESTDIR'].to_s)
INSTALL_ROOT      = Pathname.new(ENV["PREFIX"] || "#{DESTDIR}/opt/ood")
VENDOR_BUNDLE     = (ENV['VENDOR_BUNDLE'] == "yes" || ENV['VENDOR_BUNDLE'] == "true")
PASSENGER_APP_ENV = ENV["PASSENGER_APP_ENV"] || "production"

require "#{TASK_DIR}/rake_helper"
require "#{TASK_DIR}/build"
require "#{TASK_DIR}/packaging"
require "#{TASK_DIR}/test"
require "#{TASK_DIR}/lint"
require "#{TASK_DIR}/development"
require "#{TASK_DIR}/install"
require "#{TASK_DIR}/demo"

include RakeHelper

desc "Clean up build"
task :clean do
  sh "git clean -Xdf"
end

desc "Update Ondemand"
task :update do
  ruby_apps.each do |app|
    chdir app.path
    Bundler.with_unbundled_env do
      sh "bundle update"
    end
  end

  yarn_apps.each do |app|
    chdir app.path
    sh "npm install --production --prefix tmp yarn"
    sh "tmp/node_modules/yarn/bin/yarn  upgrade"
  end
end


task default: %w[test]
