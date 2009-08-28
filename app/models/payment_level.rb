class PaymentLevel < ActiveRecord::Base
  before_save :unset_default_payment_level
  validates_presence_of :name, :rate, :code
  validates_uniqueness_of :name, :code
  validates_numericality_of :rate, :greater_than => 0, :less_than => 1, :allow_nil => true

  has_many :users

  private

  def unset_default_payment_level
    # if this link set is set to true, then unset the previous default link sets
    if self.default_payment_level
      PaymentLevel.find_all_by_default_payment_level(true).each do |payment_level|
        payment_level.update_attribute(:default_payment_level, false) unless payment_level.id == self.id
      end
    end
  end
end
