# An order, as its name implies, represents a purchase of a product by a user.
class Order < ActiveRecord::Base
  belongs_to :cart
  belongs_to :user

  # Order tranactions provide detailed information about the interactions with the credit card gateway,
  # including the specific parameters passed and the return results and authorization codes. 
  has_many :transactions, :class_name => "OrderTransaction"

  # These non-persisted attributes are passed to ActiveMechant. They're not persisted because we won't
  # want to store these bad boys in firehoze and risk security issues
  attr_accessor :card_number, :card_verification

  # Most attributes (first/last name, card number, expiration date) are validated
  # in the logic to validate the credit card
  validates_presence_of :cart, :ip_address, :user, :address1,
                        :city, :state, :country, :zip, :billing_name
  validates_length_of       :first_name, :maximum => 50, :allow_nil => true
  validates_length_of       :last_name, :maximum => 50, :allow_nil => true
  validates_length_of       :billing_name, :maximum => 100, :allow_nil => true
  validates_length_of       :address1, :maximum => 150, :allow_nil => true
  validates_length_of       :address2, :maximum => 150, :allow_nil => true
  validates_length_of       :city, :maximum => 50, :allow_nil => true
  validates_length_of       :state, :maximum => 50, :allow_nil => true
  validates_length_of       :country, :maximum => 50, :allow_nil => true
  validates_length_of       :zip, :maximum => 25, :allow_nil => true

  validate_on_create :validate_card

  # Execute the purchase transaction to the credit card gateway using the ActiveMerchant api
  def purchase
    response = GATEWAY.purchase(price_in_cents,
                                credit_card,
                                :ip => ip_address,
                                :billing_address => {
                                        :name => billing_name,
                                        :address1 => address1,
                                        :address2 => address2,
                                        :city => city,
                                        :state => state,
                                        :country => country,
                                        :zip => zip })

    # log the result
    transactions.create!(:action => "purchase", :amount => price_in_cents, :response => response)

    cart.execute_order user if response.success?
    cart.save!
    
    # Return true iff the credit card was processed successfully
    response.success?
  end

  private

  # The credit card gateway expects monetary amounts expressed in cents
  def price_in_cents
    (cart.total_discounted_price*100).round
  end

  # The credit card gateway will validate the card. This method will put the errors in the
  # errors structure for this record so they will appear as would any other ActiveRecord validation
  # failure
  def validate_card
    unless credit_card.valid?
      credit_card.errors.full_messages.each do |message|
        errors.add_to_base message
      end
    end
  end

  # The credit card is the object expected by the ActiveMerchant credit card gateway. This method
  # builds it from the attributes on the order record.
  def credit_card
    @credit_card ||= ActiveMerchant::Billing::CreditCard.new(
            :type => card_type,
            :number => card_number,
            :verification_value => card_verification,
            :month => card_expires_on.month,
            :year => card_expires_on.year,
            :first_name => first_name,
            :last_name => last_name
    )
  end
end
