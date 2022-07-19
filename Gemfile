# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem "rake"
gem "bcrypt"
gem 'dotenv', '~> 2.1'

group :package do
  gem 'ood_packaging', '0.0.1.r2.0'
end

group :test do
  gem "rspec"
  gem "watir"
  gem "rubocop"

  gem "beaker"
  gem "beaker-rspec"
  # Use fork until merged and released
  # https://github.com/voxpupuli/beaker-docker/pull/53
  # https://github.com/voxpupuli/beaker-docker/pull/54
  gem "beaker-docker", git: 'https://github.com/treydock/beaker-docker.git', branch: 'osc'
end
