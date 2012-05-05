class GiftCertificate < ActiveRecord::Base
  validates_presence_of :code, :credit_quantity, :user, :gift_certificate_sku
  validates_length_of :code, :is=> 16, :allow_nil => true
  belongs_to :user
  belongs_to :gift_certificate_sku
  belongs_to :line_item
  belongs_to :redeemed_by_user, :class_name => 'User', :foreign_key => "redeemed_by_user_id"
  validates_numericality_of :credit_quantity, :greater_than => 0, :only_integer => true, :allow_nil => true
  validates_numericality_of :price, :greater_than_or_equal_to => 0, :allow_nil => true

  before_validation(:on => :create) do
    populate_code
  end
  before_create :populate_expires_at

  # Used when gifting a gift certificate
  attr_accessor :to_user, :to_user_email, :give_comments, :quantity_to_grant

  scope :active, :conditions => [ "redeemed_at is null and expires_at > ?", Time.now ]

  # Basic paginated listing finder
  # If the user is specified and is an admin, then all active gift certificates will be retrieved.
  # Otherwise, just those belonging to the user
  def self.list(page, user)
    conditions = { :redeemed_at => nil }
    conditions = conditions.merge({ :user_id => user}) unless user.try(:is_admin?)
    paginate :page => page,
             :conditions => conditions,
             :order => 'id desc',
             :per_page => per_page
  end

  def formatted_code
    code[0, 4] + "-" + code[4, 4] + "-" + code[8, 4] + "-" + code[12, 4]
  end

  def redeem the_user
    self.credit_quantity.times do
      Credit.create!(:sku => self.line_item.try(:sku),
                     :price => self.price,
                     :user => the_user,
                     :acquired_at => Time.zone.now,
                     :line_item => self.line_item)
    end
    self.update_attributes(:redeemed_at => Time.now, :redeemed_by_user => the_user )
  end

  def give to_user, comments
    self.update_attributes!(:user => to_user, :comments => comments)
  end

  def self.notify_of_gift(gift_certificate_id, from_user_id)  
    gift_certificate = GiftCertificate.find(gift_certificate_id)
    from_user = User.find(from_user_id)
    Notifier.deliver_gift_certificate_received(gift_certificate, from_user)
  end

  private

  def populate_expires_at
    self.expires_at = APP_CONFIG[CONFIG_GIFT_CERTIFICATE_EXPIRES_DAYS].to_i.days.since
  end

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
