# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'rake'
gem 'dotenv', '~> 2.1'

group :package do
  gem 'ood_packaging', '~> 0.7.0'
end

group :test do
  gem 'rspec'
  gem 'rubocop'
  gem 'rubocop-rspec'
  gem 'watir'

  gem 'beaker'
  gem 'beaker-docker', '~> 1.1.1'
  gem 'beaker-rspec'
end
