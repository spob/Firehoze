# Settings specified here will take precedence over those in config/environment.rb

# Required for gmail
require "smtp_tls"

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false # Set to true to enable full error reports
config.action_controller.perform_caching             = true
config.action_view.debug_rjs                         = false # Set to true to enable full error reports

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
config.action_controller.asset_host                  = "http://amazonassets.lg1.simplecdn.net/public"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

config.action_mailer.raise_delivery_errors = true
config.action_mailer.delivery_method = :smtp
#config.action_mailer.delivery_method = :sendmail
config.action_mailer.perform_deliveries = true
config.action_mailer.default_charset = "utf-8"
config.action_mailer.default_content_type = "text/html"
ActionMailer::Base.smtp_settings = {
        :address                => "smtp.mymailserver.com",
        :authentication        => :login,
        :user_name                => "me",
        :password                => "password"
}

# ActiveMerchant configuration
config.after_initialize do
  ActiveMerchant::Billing::Base.mode = :test
  ::GATEWAY = ActiveMerchant::Billing::PaypalGateway.new(
          :login => "seller_1245091905_biz_api1.firehoze.com",
          :password => "1245091911",
          :signature => "ANWT4eqvfe9CDpkyiOnsmpFaGBiSALD1SnzflEmQNt7ccAFqMc9Pj0.K"
  )
end