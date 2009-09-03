class Payment < ActiveRecord::Base
  belongs_to :user
  has_many   :credits
  validates_presence_of :user, :amount
  validates_numericality_of :amount, :greater_than => 0, :allow_nil => true

  def apply_unpaid_credits
    self.amount = 0
    self.user.unpaid_credits.each do |credit|
      self.credits << credit
      # round to the penny
      commission = ((credit.price * self.user.payment_level.rate * 100).floor) * 0.01
      credit.update_attribute(:commission_paid, commission)
      self.amount = self.amount + commission
    end
  end
end
