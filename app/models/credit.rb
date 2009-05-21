class Credit < ActiveRecord::Base
  validates_presence_of     :user, :sku, :acquired_at, :price
  validates_numericality_of :price, :greater_than_or_equal_to => 0, :allow_nil => true

  belongs_to :sku, :class_name => "CreditSku"
  belongs_to :user
  belongs_to :video

  before_save :set_dates

  def set_dates
    acquired_at = Time.zone.now
  end
end