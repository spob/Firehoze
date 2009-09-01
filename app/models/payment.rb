class Payment < ActiveRecord::Base
  belongs_to :user
  has_many   :credits
  validates_presence_of :user, :amount
  validates_numericality_of :amount, :greater_than => 0, :allow_nil => true
end
