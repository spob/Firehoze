class GroupMember < ActiveRecord::Base
  belongs_to :user, :counter_cache => true
  belongs_to :group, :counter_cache => true
  has_many :activities, :as => :trackable, :dependent => :destroy
  delegate :login, :to => :user, :prefix => true 

  validates_presence_of :member_type

  named_scope :active, :conditions => {:member_type => [OWNER, MODERATOR, MEMBER] }

  def can_edit?(user)
    self.group.owned_by?(user) or
            (self.group.moderated_by?(user) and
                    (self.member_type == MEMBER or self.member_type == PENDING))
  end

  def compile_activity
    self.activities.create!(:actor_user => self.user,
                            :actee_user => self.group.owner,
                            :acted_upon_at => self.created_at,
                            :group => self.group,
                            :activity_string => "group_member.activity",
                            :activity_object_id => self.group.id,
                            :activity_object_human_identifier => self.group.name,
                            :activity_object_class => self.group.class.to_s,
                            :secondary_activity_object_id => nil,
                            :secondary_activity_object_human_identifier => nil,
                            :secondary_activity_object_class => nil)
    self.update_attribute(:activity_compiled_at, Time.now)
  end
end