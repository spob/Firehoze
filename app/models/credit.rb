class Credit < ActiveRecord::Base
  validates_presence_of     :user, :sku, :acquired_at, :expires_at, :price
  validates_numericality_of :price, :greater_than_or_equal_to => 0, :allow_nil => true

  belongs_to :sku, :class_name => "CreditSku"
  belongs_to :user
  belongs_to :video
end