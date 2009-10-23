class Group < ActiveRecord::Base
  has_friendly_id :name
  validates_presence_of :name
  validates_uniqueness_of :name
end
