#ActionMailer setup - skal lægges i en fil som ikke gemmes på github
ActionMailer::Base.smtp_settings = {
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :domain               => "clubnovus.dk",
    :user_name            => "michelhansen75@gmail.com",
    :password             => "xheroM178?",
    :authentication       => "plain",
    :enable_starttls_auto => true
}
ActionMailer::Base.default_url_options[:host] = "localhost:3000"