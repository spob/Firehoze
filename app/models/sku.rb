class Sku < ActiveRecord::Base
  validates_presence_of     :sku,         :type, :description
  validates_uniqueness_of   :sku,         :case_sensitive => false
  validates_length_of       :sku,         :maximum => 30, :allow_nil => true
  validates_length_of       :type,        :maximum => 50
  validates_length_of       :description, :maximum => 150, :allow_nil => true
end
