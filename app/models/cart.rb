# Cart is a shopping cart object. A cart can have multiple line items. When a cart is transacted
# (paid for), an order will be created and associated to the cart.
class Cart < ActiveRecord::Base
  has_many :line_items, :dependent => :destroy
  belongs_to :user
  has_one :order
  validates_presence_of :user

  # Calculate the total price of all line items
  def total_full_price
    # convert to array so it doesn't try to do sum on database directly
    line_items.to_a.sum(&:total_full_price)
  end

  # Calculate the total discounted price of all line items
  def total_discounted_price
    # convert to array so it doesn't try to do sum on database directly
    line_items.to_a.sum(&:total_discounted_price)
  end
end