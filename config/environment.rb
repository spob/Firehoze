# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Firehoze::Application.initialize!

# TODO I don't know what this is or what to do with it
# Can be 'object roles' or 'hardwired'
AUTHORIZATION_MIXIN = "object roles"

# TODO these should be moved.  See http://stackoverflow.com/questions/3812647/where-do-the-rails-3-environmental-variables-belong
# Define keys required for reCaptcha
ENV['RECAPTCHA_PUBLIC_KEY'] = '6LelDs4SAAAAAHpvXSR4zXGgoPgajN2YUwks5f4Q'
ENV['RECAPTCHA_PRIVATE_KEY'] = '6LelDs4SAAAAAD4xsg8Zvf_SlzLHlapAZZefrXth'

# NOTE : If you use modular controllers like '/admin/products' be sure
# to redirect to something like '/sessions' controller (with a leading slash)
# as shown in the example below or you will not get redirected properly
#
# This can be set to a hash or to an explicit path like '/login'
#
# TODO I don't know why there are here or what to do with them
LOGIN_REQUIRED_REDIRECTION = { :controller => '/user_session', :action => 'new' }
PERMISSION_DENIED_REDIRECTION = { :controller => '/lessons', :action => 'index' }

# The method your auth scheme uses to store the location to redirect back to
STORE_LOCATION_METHOD = :store_location