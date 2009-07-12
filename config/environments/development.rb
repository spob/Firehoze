# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# The following gem is required to support gmail as the smtp server. We can comment this
# out if we don't use gmail
# See http://www.iterasi.net/openviewer.aspx?sqrlitid=3aldcskoqekerxaw4xbz7g
config.gem "ambethia-smtp-tls", :lib => "smtp-tls", :source => "http://gems.github.com/"

# Yes, raise errors if can't send email
config.action_mailer.raise_delivery_errors = true
config.action_mailer.default_content_type = "text/html"

config.action_mailer.smtp_settings = {
        :address        => "smtp.gmail.com",
        :port           => 587,
        :domain         => "firehoze.com",
        :authentication => :plain,
        :user_name      => "mailer@firehoze.com",
        :password       => "F1reh0ze"
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