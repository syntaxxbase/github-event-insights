source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.4"

gem "rails", "~> 7.1"
gem "pg"
gem "sidekiq"
gem "redis"
gem "puma"
gem "bootsnap", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "rspec-rails"
  gem "webmock"
  gem "vcr"
end

group :development do
  gem "listen", "~> 3.3"
end

gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
