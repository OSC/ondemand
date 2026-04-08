# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'rake'
gem 'dotenv', '~> 2.1'

group :package do
  gem 'ood_packaging', '~> 0.21.0'
end

group :test do
  gem 'rspec'
  gem 'rubocop'
  gem 'rubocop-rspec'
  gem 'watir'
end

group :e2e do
  gem 'beaker', '~> 7.4.0'
  gem 'beaker-docker', '~> 3.1.0'
  gem 'beaker-rspec'
end
