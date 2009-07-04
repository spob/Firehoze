class GiftCertificateSku < CreditSku

  # When the order is completed, this method will be invoked to finish the transaction -- in this case,
  # to grant the user the credits they purchased
  def execute_order_line user, quantity
    quantity.times do
      Credit.create!(:sku => self, :price => price/num_credits, :user => user, :acquired_at => Time.zone.now)
    end
  end
end