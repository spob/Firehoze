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

config.action_mailer.smtp_settings = {
        :address        => "smtp.gmail.com",
        :port           => 587,
        :domain         => "mindmeld@sturim.org",
        :authentication => :plain,
        :user_name      => "mindmeld@sturim.org",
        :password       => "mindmeld"
}