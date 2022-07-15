# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem "rake"
gem "bcrypt"

group :test do
  gem "rspec"
  gem "watir"
  gem "rubocop"

  gem "beaker"
  gem "beaker-rspec"
  gem "beaker-docker", '~> 1.1.1'
end
