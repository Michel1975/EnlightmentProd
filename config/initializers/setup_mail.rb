#ActionMailer setup - skal lægges i en fil som ikke gemmes på github
ActionMailer::Base.smtp_settings = {
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :domain               => ENV["DOMAIN"],
    :user_name            => ENV["GMAIL_USER_NAME"],
    :password             => ENV["GMAIL_PASSWORD"],
    :authentication       => "plain",
    :enable_starttls_auto => true
}
ActionMailer::Base.default_url_options[:host] = ENV["DOMAIN"]