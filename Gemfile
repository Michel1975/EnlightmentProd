# -*- encoding : utf-8 -*-
source 'https://rubygems.org'
ruby "1.9.3"
gem 'rails', '3.2.14' 
gem 'bootstrap-sass', '~> 2.3.2.1' # Twitter bootstrap 2.3 - stable
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'bcrypt-ruby', '3.0.1'
gem 'will_paginate', '3.0.3'
gem 'bootstrap-will_paginate', '0.0.6'
gem 'faker', '1.0.1'
gem "sorcery"
gem 'figaro'
gem 'savon', '~> 2.0'
gem 'htmlentities'
gem 'gmaps4rails' # Vi bruger dette til at vise kortet
gem 'geocoder' # vi bruger dette til at indkode adresser i raw-format
gem 'carrierwave' #Bruges sammen med clodinary på en mærkelig måde..via en uploader klasse
gem 'cloudinary'
gem 'rack-mini-profiler' #Se mere info i railscast episode 368
gem 'httparty' #Used for parsing status updates for sms campaigns
gem 'bitly' #Used to shorten various urls in 
gem 'delayed_job_active_record'# for delayed jobs such as sending e-mail and communicating with sms-gateway.
gem 'simple_captcha', :git => 'git://github.com/galetahub/simple-captcha.git'
gem 'rmagick', '2.13.2'
gem 'hirefire-resource' #to autoscale workers on heroku platform
gem 'feedzirra'
#gem 'crack' #used to parse the special output by httpparty in campaign status jobs
#gem 'railties' #for heroku deploy. Følg op på versionen ved næste deploy til heroku.


#gem 'rqrcode-rails3'

group :development, :test do
  #gem 'sqlite3', '1.3.5'
  gem 'pg'
  gem 'rspec-rails', '2.11.0'   
  gem 'annotate', '2.5.0' 
  gem 'better_errors'
  gem 'binding_of_caller'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '>= 3.2'
  gem 'coffee-rails', '3.2.2' 
  gem 'uglifier', '1.2.3'
end

group :test do
  gem 'capybara', '1.1.2'
  gem 'spork', '0.9.2'
  gem 'factory_girl_rails', '4.1.0'
end

group :production do
  gem 'rails_12factor' # for heroku deployment
  gem 'pg'
end
# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
