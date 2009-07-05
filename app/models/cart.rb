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


  # Trigger the execution of the order (e.g., actually grant the user
  # credits when the order purchase transaction has completed
  def execute_order_on_cart user
    # Purchased at should always be nil when we get here...otherwise raise an exception so we can
    # track it and fix it
    raise Exceptions::AssertionFailed unless self.purchased_at.nil?

    # Update the cart to indicate that its actually been purchased
    self.update_attribute(:purchased_at, Time.zone.now)

    # Go ahead and execute the order. For example, in the case of a credit sku, this would mean
    # granting the user credits
    for line in self.line_items
      line.sku.execute_order_line user, line
    end
  end
end