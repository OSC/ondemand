# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'rake'
gem 'dotenv', '~> 2.1'

gem 'ood_packaging', git: 'https://github.com/OSC/ondemand-packaging', branch: 'feature/rake-task-gem'

group :test do
  gem 'rspec'
  gem 'rubocop'
  gem 'watir'

  gem 'beaker'
  gem 'beaker-docker', '~> 1.0.1'
  gem 'beaker-rspec'
end
