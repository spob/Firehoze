require "smtp_tls"

mailer_config = File.open("#{Rails.root.to_s}/config/mailer.yml")
mailer_options = YAML.load(mailer_config)
ActionMailer::Base.smtp_settings = mailer_options
