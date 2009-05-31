class DiscountByVolume < Discount
  validates_presence_of :minimum_quantity, :percent_discount
  validates_numericality_of :percent_discount, :greater_than => 0, :allow_nil => true
  validates_numericality_of :minimum_quantity, :greater_than => 0, :only_integer => true, :allow_nil => true
end
