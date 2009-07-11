# A credit sku extends the generic sku base class, and is a sku intended to purchase credits.
#
# a credit sku includes the number of credits that this sku represents. This will generally (but perhaps
# not always) be 1.
class CreditSku < Sku
  validates_presence_of     :price,  :num_credits
  validates_numericality_of :price, :greater_than_or_equal_to => 0, :allow_nil => true
  validates_numericality_of :num_credits, :greater_than => 0, :only_integer => true, :allow_nil => true

  # These credits were purchased based upon this sku
  has_many :credits, :foreign_key => 'sku_id'

  # This sku may be associated to discounts which allow users to purchase it at a discount
  has_many :discounts, :class_name => 'DiscountByVolume', :foreign_key => 'sku_id'

  #named_scope :biggest_credits_first, :order => "num_credits desc"

  # This lists the discount types that can be associated with this SKU. This is used to populate a select
  # list in the SKU creation screen.
  @@_discount_types = [
          ["By Volume", 'DiscountByVolume']
  ]

  def discount_types
    @@_discount_types
  end

  # Only an admin can delete a credit sku, and only if the SKU hasn't been used to purchase credits
  def can_delete? user
    user.is_admin? and credits.empty?
  end

  # When the order is completed, this method will be invoked to finish the transaction -- in this case,
  # to grant the user the credits they purchased
  def execute_order_line user, line_item
    line_item.quantity.times do
      Credit.create!(:sku => self,
                     :price => price/num_credits,
                     :user => user,
                     :acquired_at => Time.zone.now,
                     :line_item => line_item)
    end
  end

  def to_s
    "num_credits: #{num_credits}, price: #{price}, desc: #{description}"
  end
end                                                      