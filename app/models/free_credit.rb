# When a user creates a lesson, they may choose to offer the lesson for free to the first
# X viewers. Such a lesson will  have X free credit records reflecting the number of free
# credits, both available and consumed
class FreeCredit < ActiveRecord::Base
  belongs_to :user
  belongs_to :lesson, :counter_cache => true
  validates_presence_of     :lesson

  named_scope :available, :conditions => {:redeemed_at => nil}
end
