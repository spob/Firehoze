class Payment < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user, :amount
  validates_numericality_of :amount, :greater_than => 0, :allow_nil => true
end
