class GiftCertificate < ActiveRecord::Base
  validates_presence_of :code, :credit_quantity, :user, :gift_certificate_sku, :line_item
  validates_length_of :code, :is=> 16, :allow_nil => true
  belongs_to :user
  belongs_to :gift_certificate_sku
  belongs_to :line_item
  validates_numericality_of :credit_quantity, :greater_than => 0, :only_integer => true, :allow_nil => true

  before_validation_on_create :populate_code

  def formatted_code
    code[0, 4] + "-" + code[4, 4] + "-" + code[8, 4] + "-" + code[12, 4]
  end

  private

  def populate_code
    while true
      # Loop to make sure the generated code is unique
      self.code = generate_activation_code
      break unless GiftCertificate.find_by_code(self.code)
    end
  end

  def generate_activation_code(size = 16)
    charset = %w{ 2 3 4 6 7 9 A C D E F G H J K L M N P Q R T V W X Y Z}
    (0...size).map{ charset.to_a[rand(charset.size)] }.join
  end
end
