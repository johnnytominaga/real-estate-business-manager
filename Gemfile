source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

gem 'rails', '~> 5.2.2'
gem 'grape', '>= 0.10.0'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'duktape'
gem 'coffee-rails', '~> 4.2'
gem 'jbuilder', '~> 2.5'

gem 'redis'
gem 'resque', '~> 1.25'
gem 'resque-heroku-signals', '~> 1.27'
gem 'resque-scheduler', '~> 4.3'
gem 'resque_mailer', '~> 2.4'

gem 'bootstrap-sass', '~> 3.3.7'
gem 'jquery-rails', '~> 4.3', '>= 4.3.1'
gem 'devise', '~> 4.2'
gem 'rails-ujs', '~> 0.1.0'
gem 'mini_magick', '~> 4.8'
gem 'bootsnap', '>= 1.1.0', require: false

gem 'rails_admin', '~> 1.3'
gem 'rails_admin_rollincode', '~> 1.0'
gem 'cancancan', '~> 2.0'
gem 'barista'


gem 'toastr-rails', '~> 1.0'
gem 'image_processing', '~> 1.2'
gem "ImageResize", '~> 0.0.5'
gem 'geocoder', '~> 1.4'
gem 'gmaps4rails', '~> 2.1'
gem 'jquery-ui-rails', '~>6.0.1'

gem 'ransack', '~> 2.1', '>= 2.1.1'
gem 'polyamorous', '~> 1.3', '>= 1.3.3'
# gem 'ransack', github: 'activerecord-hackery/ransack'
# gem 'polyamorous', github: 'activerecord-hackery/polyamorous'
gem 'travis', '~> 1.8', '>= 1.8.9'
gem 'json', '~> 1.8', platform: :mri_19
gem 'mailgun-ruby', require: 'mailgun'
gem 'figaro', '~> 1.1.1'
gem 'superfish-rails', '~> 1.6.0'
gem 'font-awesome-rails', '~> 4.7.0'
gem 'ionicons-rails', '~> 2.0.0'
gem 'animate-rails', '~> 1.0.10'
gem 'jquery-easing-rails', '~> 0.0.2'
gem 'wow-rails', '~> 0.0.1'
gem 'jquery-waypoints-rails', '~> 2.0', '>= 2.0.5'
gem 'countupjs-rails'
gem 'isotope-rails', '~> 2.2.2'
gem 'lightbox2-rails', '~> 2.8'


#gem 'swipe-rails'
gem 'rails-jquery-autocomplete', '~> 1.0.5'
gem 'owlcarousel-rails'
gem 'will_paginate', '~> 3.1.0'
gem 'will_paginate-bootstrap'
gem "aws-sdk-s3", require: false
gem 'countries', '~> 2.1', require: 'countries/global'
gem 'country_select', '~> 3.1'
gem 'activerecord-import', '~> 0.27.0'
gem 'smarter_csv', '~> 1.2.6'
gem 'activesupport', '~> 5.2', :require => "active_support/all"
gem 'browser', '~> 2.5', '>= 2.5.3'
gem 'clipboard-rails', '~> 1.7', '>= 1.7.1'
gem "barnes"
gem 'rubyzip', '>= 1.0.0'
gem 'zip-zip'
gem 'exception_handler', '~> 0.8.0.0'

# Mobile
gem 'rack-cors', require: 'rack/cors'
gem 'active_model_serializers', '~> 0.10.0', require: true
gem 'api-pagination', '~> 4.8'
gem 'simple_token_authentication', '~> 1.15'
gem 'omniauth'

#---Phase 2---
gem 'fullcalendar-rails', '~> 3.4.0'
gem 'momentjs-rails', '~> 2.17.1'
gem 'chartkick', '~> 2.2.4'
gem 'bootstrap-tagsinput-rails', '~> 0.4.2.1'
gem 'activity_notification', '~> 1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper', '1.2.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
