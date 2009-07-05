class GiftCertificateSku < CreditSku
  has_many :gift_certificates
  # When the order is completed, this method will be invoked to finish the transaction -- in this case,
  # to grant the user the credits they purchased
  def execute_order_line user, quantity
    user.gift_certificates.create! q(:credit_quantity => quantity,
                                  :gift_certificate_sku => self, 
                                  :price => self.price)
  end
end