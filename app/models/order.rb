class Order < ActiveRecord::Base
  belongs_to :cart
  belongs_to :user
  has_many :transactions, :class_name => "OrderTransaction"

  attr_accessor :card_number, :card_verification

  # Most attributes (first/last name, card number, expiration date) are validated
  # in the logic to validate the credit card
  validates_presence_of :cart, :ip_address, :user, :billing_name, :address1,
                        :city, :state, :country, :zip
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

  def purchase
    response = GATEWAY.purchase(price_in_cents,
                                credit_card,
                                :ip => ip_address,
                                :billing_address => {
                                        :name => self.billing_name,
                                        :address1 => address1,
                                        :address2 => address2,
                                        :city => city,
                                        :state => state,
                                        :country => country,
                                        :zip => zip })
    transactions.create!(:action => "purchase", :amount => price_in_cents, :response => response)
    cart.update_attribute(:purchased_at, Time.now) if response.success?
    response.success?
  end

  def price_in_cents
    (cart.total_discounted_price*100).round
  end

  private

  #      :city => "New York",
  #      :state => "NY",
  #      :country => "US",
  #      :zip => "10001"
  #    }
  #  }
  #end

  def validate_card
    unless credit_card.valid?
      credit_card.errors.full_messages.each do |message|
        errors.add_to_base message
      end
    end
  end

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
