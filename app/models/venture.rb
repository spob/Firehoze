class Venture < ActiveRecord::Base
  has_friendly_id :name, :use_slug => true
end
