class LineItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :sku

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

  def full_price
    unit_price * quantity
  end
end