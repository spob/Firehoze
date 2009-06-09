class DiscountByVolume < Discount
  validates_presence_of :minimum_quantity, :percent_discount
  validates_numericality_of :percent_discount, :greater_than => 0, :less_than_or_equal_to => 1, :allow_nil => true
  validates_numericality_of :minimum_quantity, :greater_than => 0, :only_integer => true, :allow_nil => true

  attr_accessible :minimum_quantity, :percent_discount

  named_scope :max_discount_by_volume,
          lambda{|qty| {:conditions => ["minimum_quantity <= ? and active = ?", qty, true],
                  :order => "minimum_quantity desc", :limit => 1}
          }
end