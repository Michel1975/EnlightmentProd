#ActionMailer setup - skal lægges i en fil som ikke gemmes på github
ActionMailer::Base.smtp_settings = {
    :address              => ENV["MAIL_ADDRESS"],
    :port                 => ENV["MAIL_PORT"],
    :domain               => ENV["MAIL_DOMAIN"],
    :user_name            => ENV["MAIL_USER_NAME"],
    :password             => ENV["MAIL_PASSWORD"],
    :authentication       => "plain",
    :enable_starttls_auto => true
}
ActionMailer::Base.default_url_options[:host] = ENV["DOMAIN"]


=begin
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
=end