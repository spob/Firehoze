class GroupMember < ActiveRecord::Base
  belongs_to :user, :counter_cache => true
  belongs_to :group, :counter_cache => true
  validates_presence_of :member_type
  attr_protected :member_type

  def can_edit?(user)
    self.group.owned_by?(user) or
            (self.group.moderated_by?(user) and
                    (self.member_type == MEMBER or self.member_type == PENDING))
  end
end