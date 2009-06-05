class LineItem < ActiveRecord::Base
  before_validation :assign_discount
  belongs_to :cart
  belongs_to :sku
  belongs_to :discount

  validates_presence_of     :unit_price, :discounted_unit_price, :sku, :cart, :quantity
  validates_numericality_of :unit_price, :greater_than => 0, :allow_nil => true
  validates_numericality_of :discounted_unit_price, :greater_than => 0, :allow_nil => true
  validates_numericality_of :quantity, :greater_than => 0, :only_integer => true, :allow_nil => true

  named_scope :by_cart,
          lambda{|cart_id|{:conditions => { :cart_id => cart_id }}
          }
  named_scope :by_sku,
          lambda{|sku_id|{:conditions => { :sku_id => sku_id }}
          }

  def total_full_price
    unit_price * quantity
  end

  def total_discounted_price
    discounted_unit_price * quantity
  end

  private

  def assign_discount
    self.discounted_unit_price = self.unit_price
    unless sku.nil? # sku can only be null if the user entered a bad value
      self.discount = self.sku.discounts.max_discount_by_volume(self.quantity).first unless self.sku.discounts.nil?
      self.discounted_unit_price = self.unit_price *  (1 - self.discount.percent_discount) if self.discount
    end
  end
end