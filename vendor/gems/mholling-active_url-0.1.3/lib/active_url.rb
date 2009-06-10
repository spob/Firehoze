require 'rubygems'
require 'active_record'
ActiveRecord::Base # hack to get ActiveRecord::Validations to load..?

require 'active_url/errors'
require 'active_url/configuration'
require 'active_url/crypto'
require 'active_url/belongs_to'
require 'active_url/validations'
require 'active_url/callbacks'
require 'active_url/base'

# module ActiveUrl
#   autoload :Base,          'active_url/base'
#   autoload :Configuration, 'active_url/configuration'
#   autoload :Crypto,        'active_url/crypto'
#   autoload :BelongsTo,     'active_url/belongs_to'
#   autoload :Validations,   'active_url/validations'
#   autoload :Callbacks,     'active_url/callbacks'
# end