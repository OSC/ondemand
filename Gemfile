# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem "rake"
gem "bcrypt"
gem 'dotenv', '~> 2.1'

group :package do
  gem 'ood_packaging', '0.0.3.r2.0'
end

group :test do
  gem "minitest", '5.15.0'
  gem "rspec"
  gem "watir"
  gem "rubocop"

  gem "beaker"
  gem "beaker-rspec"
  gem "beaker-docker", '~> 1.1.1'
  gem "net-ssh", '< 7.0.0'
end
