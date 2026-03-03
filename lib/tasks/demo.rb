desc 'Demonstrate OnDemand'
namespace :demo do

require_relative 'rake_helper'
  include RakeHelper

  def demo_run_cmd
    [ container_runtime, 'run', '--rm', '--detach',
      '--name', 'ood_demo', '-p 8080:8080',
      '-h', 'ood.demo',
      "#{image_names[:demo]}:latest"
    ].join(' ')
  end

  task :build do
    sh build_cmd('Dockerfile.demo', image_names[:demo], image_tag: 'latest')
  end

  task start: [:build] do
    sh demo_run_cmd
  end

  task :stop do
    sh "#{container_runtime} stop ood_demo"
  end

  task restart: [:stop, :start] do
    # nothing to do, taken care of in dependencies
  end
end