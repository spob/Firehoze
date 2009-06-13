# This class provides a volume discount. If the volume is met the user is entitled to the discount.
class DiscountByVolume < Discount
  validates_presence_of :minimum_quantity, :percent_discount
  validates_numericality_of :percent_discount, :greater_than => 0, :less_than_or_equal_to => 1, :allow_nil => true
  validates_numericality_of :minimum_quantity, :greater_than => 0, :only_integer => true, :allow_nil => true

  attr_accessible :minimum_quantity, :percent_discount

  # Return the first discount greater than or equal to the order quantity in order to calculate the discount
  # to provide
  named_scope :max_discount_by_volume,
          lambda{|qty| {:conditions => ["minimum_quantity <= ? and active = ?", qty, true],
                  :order => "minimum_quantity desc", :limit => 1}
          }
end