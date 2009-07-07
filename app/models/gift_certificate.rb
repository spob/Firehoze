class GiftCertificate < ActiveRecord::Base
  validates_presence_of :code, :credit_quantity, :user, :gift_certificate_sku, :line_item
  validates_length_of :code, :is=> 16, :allow_nil => true
  belongs_to :user
  belongs_to :gift_certificate_sku
  belongs_to :line_item
  belongs_to :redeemed_by_user, :class_name => 'User', :foreign_key => "redeemed_by_user_id"
  validates_numericality_of :credit_quantity, :greater_than => 0, :only_integer => true, :allow_nil => true

  before_validation_on_create :populate_code
  before_create :populate_expires_at

  named_scope :active, :conditions => [ "redeemed_at is null and expires_at > ?", Time.now ]

  # Basic paginated listing finder
  # If the user is specified and is a sysadmin, then all active gift certificates will be retrieved.
  # Otherwise, just those belonging to the user
  def self.list(page, user)
    conditions = { :redeemed_at => nil }
    conditions = conditions.merge({ :user_id => user}) unless user.try(:is_sysadmin?)
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
      Credit.create!(:sku => self.line_item.sku,
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
