# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

require 'thread'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# Authorization plugin for role based access control
# You can override default authorization system constants here.

# Can be 'object roles' or 'hardwired'
AUTHORIZATION_MIXIN = "object roles"

# Define keys required for reCaptcha
ENV['RECAPTCHA_PUBLIC_KEY'] = '6LffJggAAAAAAAZDR-8NsAbRZwT4034wmADYPoK2'
ENV['RECAPTCHA_PRIVATE_KEY'] = '6LffJggAAAAAAJLVsi53vgHumqwttTkpAdfTruC6'

# NOTE : If you use modular controllers like '/admin/products' be sure
# to redirect to something like '/sessions' controller (with a leading slash)
# as shown in the example below or you will not get redirected properly
#
# This can be set to a hash or to an explicit path like '/login'
#
LOGIN_REQUIRED_REDIRECTION = { :controller => '/user_session', :action => 'new' }
PERMISSION_DENIED_REDIRECTION = { :controller => '/lessons', :action => 'index' }

# The method your auth scheme uses to store the location to redirect back to
STORE_LOCATION_METHOD = :store_location

# Remove bogus deprecation warning (see https://rails.lighthouseapp.com/projects/8994/tickets/4026-rubygems-136-warning-in-rails-235)
if Gem::VERSION >= "1.3.6"
    module Rails
        class GemDependency
            def requirement
                r = super
                (r == Gem::Requirement.default) ? nil : r
            end
        end
    end
end

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Specify gems that this application depends on.
  # They can then be installed with "rake gems:install" on new installations.
  # config.gem "bj"

  # config.gem "aws-s3", :lib => "aws/s3"

  # active merchant used for credit card processing
  config.gem "activemerchant", :lib => "active_merchant", :version => "1.4.2"

  # browser detection
  config.gem "spob_browser_detector", :version => '1.1.1', :source => 'http://gemcutter.org'

  # tagging
  config.gem 'jviney-acts_as_taggable_on_steroids', :lib => 'acts_as_taggable', :source => 'http://gems.github.com', :version => '~>1.1'

  # authologic provides authentication
  config.gem "authlogic", :version => '~>2.1.3'

  # For generating XML
  config.gem 'builder', :version => '~>2.1.2'

  # For outputing time duration in human readable form
  config.gem 'hpoydar-chronic_duration', :lib => 'chronic_duration'

  # For periodic job processing
  config.gem 'daemons'

  # For facebook integration
  config.gem 'facebooker'

  # Notifier for application errors
  config.gem 'hoptoad_notifier', :version => '2.3.2'

  # Gems requires for exporting to CSV
  config.gem 'fastercsv'
  config.gem 'crafterm-comma', :lib => "comma",  :source => "http://gems.github.com"

  # Not sure why this is required...but rake is failing without it. Some gems must require it -- RBS
  config.gem "hpricot", :source => "http://gemcutter.org"

  # Using jRails, you can get all of the same default Rails helpers for javascript functionality using the lighter jQuery library.
  config.gem 'jrails', :version => '0.6', :source => 'http://gemcutter.org'

  # The LESS Ruby gem compiles LESS code to CSS -- learn more at http://lesscss.org/
  config.gem 'less', :source => 'http://gemcutter.org'

  # Gem for secret url (for user signup requests)
  config.gem "active_url", :source => "http://gemcutter.org"

  # DSL for html
  # config.gem "markaby"

  # Gem for pagination functionality
  config.gem 'mislav-will_paginate', :version => '~> 2.3.8', :lib => 'will_paginate', :source => 'http://gems.github.com'

  # Gem performance monitoring
  config.gem 'newrelic_rpm', :version => '~>2.12.3'

  # For attaching files
<<<<<<< HEAD:config/environment.rb
  config.gem 'paperclip', :version => '2.3.1'
=======
  # config.gem 'thoughtbot-paperclip', :lib => 'paperclip', :source => 'http://gems.github.com', :version => '2.3.1'
  config.gem 'paperclip', :lib => 'paperclip', :source => 'http://gems.github.com', :version => '2.3.1'
>>>>>>> 851d432213eda70540d04ebce0bd82de4525b320:config/environment.rb
  config.gem 'aws-s3', :lib => 'aws/s3'

  # For interacting with AWS
  config.gem 'right_aws'

  # For retrieving tweets
  config.gem 'twitter', :version => '>=0.7.0'

  # Gravitar integration
  config.gem 'gravtastic', :version => '= 2.2.0'

  # Search Logic
  config.gem "searchlogic", :version => '~> 2.3.5'

  # Query optimization
  #config.gem 'methodmissing-scrooge', :source => "http://gems.github.com"

  config.gem "spob-flix_cloud-gem"

  config.gem "mysql"

  # Shoulda
  config.gem "thoughtbot-shoulda", :lib => "shoulda", :source => "http://gems.github.com"


  # The following gems are required for interacting with flix cloud. Yeah, Rich, I know you'd like
  # all the gems to be alphabetically ordered, but at least for now I'd like to keep these grouped
  # together
#  config.gem 'spob-flix_cloud-gem', :lib => 'flix_cloud', :version => '0.6.2'
#  config.gem 'sevenwire-http_client', :lib => 'http_client'
#  config.gem 'crack'
  config.gem "zencoder", :version => '~> 2.1.15'


  config.gem 'thinking-sphinx', :lib => 'thinking_sphinx', :version => '1.4.4', :source => "http://gemcutter.org"


  # Only load the plugins named here, in the order given. By default, all plugins
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
  #config.plugin_paths += ["#{RAILS_ROOT}/../../Libs"]
  #config.plugins = [:authlogic]

  # Add additional load paths for your own custom dirs
  config.load_paths += %W( #{RAILS_ROOT}/lib #{RAILS_ROOT}/app/sweepers)

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Comment line to use default local time.
  config.time_zone = 'UTC'

  #  Your secret key
  #  for verifying cookie session data integrity.
  #  If you change this key, all old sessions will become invalid!
  #  Make sure the secret is at least 30 characters and all random,
  #  no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
          :session_key => '_firehoze_session',
          :secret => 'j23jh4lkjhl536h3l45jhfdgh34563h6345h6l345jh63l45jhljkhlgdsfglwjrhl'

  }

  path = "#{RAILS_ROOT}/config/environment.yml"
  APP_CONFIG = YAML.load_file(path)

  # load and merge in the environment-specific application config info if present,
  # overriding base config parameters as specified
  path = "#{RAILS_ROOT}/config/environments/#{ENV['RAILS_ENV']}.yml"
  if File.exists?(path) && (env_config = YAML.load_file(path))
    APP_CONFIG.merge!(env_config)
  end
  # parse in the Amazon s3 parameters
  s3_path = "#{RAILS_ROOT}/config/s3.yml"
  APP_CONFIG.merge!(YAML.load_file(s3_path)[RAILS_ENV])

  # Facebooker doesn't play nicely with forgery protection, so set this to false.
  config.action_controller.allow_forgery_protection = false

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  config.active_record.observers = :payment_observer, :lesson_observer, :review_observer, :comment_observer,
          :group_observer, :group_lesson_observer, :group_member_observer, :user_observer, :credit_observer,
          :flag_observer, :topic_comment_observer
  #:cacher, :garbage_collector
  config.action_controller.page_cache_directory = "#{RAILS_ROOT}/tmp/cache/"
  config.cache_store = :file_store, "#{RAILS_ROOT}/tmp/cache/"
end
