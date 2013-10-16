Bitly.configure do |config|
  config.api_version = 3
  config.login = ENV["BITLY_USER_NAME"]
  config.api_key = ENV["BITLY_PASSWORD"]
end