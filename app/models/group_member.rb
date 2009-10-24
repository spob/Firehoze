class GroupMember < ActiveRecord::Base
  belongs_to :user, :counter_cache => true
  belongs_to :group, :counter_cache => true
  validates_presence_of :member_type
end