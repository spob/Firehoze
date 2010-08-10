class Quiz < ActiveRecord::Base
  belongs_to :group, :counter_cache => true
  validates_presence_of :name, :group
  validates_uniqueness_of :name, :scope => :group_id
  validates_length_of :name, :maximum => 100, :allow_nil => true
end
