class Promotion < ActiveRecord::Base
  validates_presence_of :code, :promotion_type, :expires_at
  validates_uniqueness_of :code, :case_sensitive => false
  validates_length_of :code, :maximum => 15, :allow_nil => true
  validates_length_of :promotion_type, :maximum => 50, :allow_nil => true
#  validates_length_of :last_name, :maximum => 40, :allow_nil => true
#  validates_length_of :first_name, :maximum => 40, :allow_nil => true
#  validates_length_of :login, :maximum => 25, :allow_nil => true
end
