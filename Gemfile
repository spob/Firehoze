# Edit this Gemfile to bundle your application's dependencies.
# This preamble is the current preamble for Rails 3 apps; edit as needed.
source 'http://rubygems.org'
source 'http://gemcutter.org'
source 'http://gems.github.com'

gem 'rails', '3.0.0'

gem 'rdoc'

gem 'surveyor'
gem 'aws-sdk'
gem 'activemerchant'
gem 'spob_browser_detector', '1.1.1'
#gem 'jviney-acts_as_taggable_on_steroids', '~>1.1', :require => 'acts_as_taggable'
gem 'acts_as_taggable_on_steroids'
gem 'authlogic', :git => 'git://github.com/odorcicd/authlogic.git', :branch => 'rails3'
gem 'builder', '~>2.1.2'
gem 'hpoydar-chronic_duration', :require => 'chronic_duration'
gem 'daemons'
gem 'facebooker', :git => 'https://github.com/joren/facebooker.git', :branch => 'rails3'
gem 'hoptoad_notifier', '2.3.2'
gem 'fastercsv'
gem "comma", "~> 3.0"
gem 'hpricot'
gem 'jrails', '0.6'
gem 'less'
gem 'active_url'
gem 'will_paginate'
gem 'newrelic_rpm', '=3.0.0'
gem 'paperclip', '=3.0.1'
gem 'aws-s3'
#gem 'right_aws', '3.0.0'
gem 'twitter', '>=0.7.0'
gem 'gravtastic', '=3.0.0'
# After googling for: Uncaught exception: undefined method `merge_joins' for class `Class'
#gem 'rd_searchlogic', :require => 'searchlogic', :git => 'git://github.com/railsdog/searchlogic.git'
# I believe after I get upgraded to past rails 3.0.0 I can use searchlogic gem again.  Uncomment below and delete above.
#gem 'searchlogic'
#gem 'rd_searchlogic', :require => 'searchlogic', :git => 'git://github.com/railsdog/searchlogic.git'
# I couldn't get above searchlogic rails port to work so I cut over to meta_search and changed <%= order to <%= sort_link
gem 'meta_search'
gem 'spob-flix_cloud-gem'
gem 'mysql'
gem 'thoughtbot-shoulda', :require => 'shoulda'
gem 'zencoder', '~> 2.1.15'
gem 'thinking-sphinx', '2.0.0', :require => 'thinking_sphinx'
gem 'ambethia-smtp-tls'
gem 'mail_safe'

# brought these gems over from being a plugin
gem 'high_voltage'

# was acts_as_state_machine plugin
gem 'aasm'

# was acts_as_tree plugin
gem 'acts_as_tree_rails3'

# was ajaxful_rating plugin
#gem 'ajaxful_rating', :git => 'git://github.com/edgarjs/ajaxful-rating.git', :branch => 'rails3'
#gem 'ajaxful_rating_jquery', :require => 'ajaxful_rating', :git => 'git://github.com/mrbrdo/ajaxful_rating_jquery.git'
gem 'ajaxful_rating'

# was friendly_id plugin
gem 'friendly_id', :git => 'git://github.com/norman/friendly_id.git', :branch => '3.x'

# tried to use gem instead of plugin, but it didn't work
# gem 'localized_country_select'

# was rails-dev-boost plugin
gem 'rails-dev-boost'

# was recaptcha plugin
gem 'recaptcha', :require => 'recaptcha/rails'

# was scrooge plugin
gem 'methodmissing-scrooge'

gem 'crack'

gem 'query_trace', :git => 'git://github.com/dolzenko/query_trace.git'

# TODO ssl_requirement plugin obsoleted.  Installing this for now.  Should change code.
# http://stackoverflow.com/questions/3913162/alternative-for-ssl-requirement-plugin-for-rails-3
# http://stackoverflow.com/questions/3634100/rails-3-ssl-deprecation
gem 'bartt-ssl_requirement', '~>1.4.0', :require => 'ssl_requirement'

group :development do
  gem 'bullet'
end