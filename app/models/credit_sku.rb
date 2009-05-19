class CreditSku < Sku
  validates_presence_of     :price,  :credits
  validates_numericality_of :price, :greater_than_or_equal_to => 0, :allow_nil => true
  validates_numericality_of :credits, :greater_than => 0, :only_integer => true, :allow_nil => true

#  def validate
#    if !price.nil? and price < 0.0
#      errors.add(:price, "should be greater than or equal to zero")
#    end
#    if !credits.nil? and credits < 1
#      errors.add(:credits, "should be at least 1")
#    end
#  end
end