# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ood_auth_map/version'

Gem::Specification.new do |spec|
  spec.name          = "ood_auth_map"
  spec.version       = OodAuthMap::VERSION
  spec.authors       = ["Jeremy Nicklas"]
  spec.email         = ["jnicklas@osc.edu"]
  spec.summary       = %q{Executable scripts used to map an authenticated user to a local user account.}
  spec.description   = %q{A hodge podge grouping of scripts that can be used to map an authenticated user name to a local user account using a variety of techniques.}
  spec.homepage      = "https://github.com/OSC/ood_auth_map"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 13.0.1"
end
