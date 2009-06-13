# A credit can be redeemed to allow a user to download a video.
#
# A credit is considered available if it has not yet been redeemed, or used to
# view a video.
# Once a credit is redeemed, the redeemed_at field will be populated with the date when it
# was redeemed, and it will be associated to a lesson.
# A credit also stores information about when it was purchased (acquired_at), and the price
# for which is was purchased.
# The user is the user to whom this credit belongs.
#
# Redeemed credits represents a history of which videos have been purchased by which users.
class Credit < ActiveRecord::Base
  validates_presence_of     :user, :acquired_at, :price
  validates_numericality_of :price, :greater_than_or_equal_to => 0, :allow_nil => true

  belongs_to :sku, :class_name => "CreditSku"
  belongs_to :user
  belongs_to :lesson
  
  named_scope :available, :conditions => "redeemed_at is null"
end