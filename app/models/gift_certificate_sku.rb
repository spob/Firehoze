class GiftCertificateSku < CreditSku
  has_many :gift_certificates
  # When the order is completed, this method will be invoked to finish the transaction -- in this case,
  # to grant the user the credits they purchased
  def execute_order_line user, line_item
    user.gift_certificates.create!(:credit_quantity => line_item.quantity,
                                  :gift_certificate_sku => self,
                                  :line_item => line_item, 
                                  :price => self.price)
  end
end