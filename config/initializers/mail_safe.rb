#if defined?(MailSafe::Config)
#  MailSafe::Config.internal_address_definition = lambda { |address|
#    address =~ /.*@sturim.org/i ||
#            address =~ /.*@firehoze.com/i
#  }
#    MailSafe::Config.replacement_address = 'me@my-domain.com'
#end