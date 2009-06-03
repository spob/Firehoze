class Cart < ActiveRecord::Base
  has_many :line_items, :dependent => :destroy
  has_one :order

  def total_price
    # convert to array so it doesn't try to do sum on database directly
    line_items.to_a.sum(&:total_full_price)
  end

  def total_credits
    # convert to array so it doesn't try to do sum on database directly
    line_items.to_a.sum(&:quantity)
  end
end