class PaymentLevel < ActiveRecord::Base
  validates_presence_of :name, :rate
  validates_numericality_of :rate, :greater_than => 0, :less_than => 1, :allow_nil => true
end
