# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nginx_stage/version'

Gem::Specification.new do |spec|
  spec.name          = "nginx_stage"
  spec.version       = NginxStage::VERSION
  spec.authors       = ["Jeremy Nicklas"]
  spec.email         = ["jnicklas@osc.edu"]
  spec.summary       = %q{Stage and control per-user NGINX processes.}
  spec.description   = %q{Command line interface to generating per-user NGINX configurations as well as launching and controlling the nginx process.}
  spec.homepage      = "https://www.osc.edu"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "syslog", "~> 0.1.0"
  spec.add_dependency 'dotenv', '~> 2.1'

  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake", "~> 13.0.1"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "climate_control"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "mocha"
end
