class CreditSku < Sku
  validates_presence_of     :price,  :num_credits
  validates_numericality_of :price, :greater_than_or_equal_to => 0, :allow_nil => true
  validates_numericality_of :num_credits, :greater_than => 0, :only_integer => true, :allow_nil => true

  # These credits were purchased based upon this sku
  has_many :credits, :foreign_key => 'sku_id'


  def can_delete? user
    user.is_sysadmin? and credits.empty?
  end
end