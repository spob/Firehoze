class Group < ActiveRecord::Base
  has_friendly_id :name

  belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"
  has_many :group_members
  has_many :users, :through => :group_members
  validates_presence_of :name, :owner
  validates_uniqueness_of :name

  named_scope :public, :conditions => { :private => false }
  named_scope :not_a_member,
              lambda{ |user| return {} if user.nil?;
              { :conditions => ["groups.id not in (?)", user.groups.collect(&:id) + [-1]] }
              }

  def self.list user
    owned_groups = user.groups
    groups = Group.not_a_member(user).ascend_by_name(:include => :user) + owned_groups
    groups.sort_by{|g| g.name}    
  end
  
  def owned_by?(user)
    self.owner == user
  end

  def moderated_by?(user)
    group_member = includes_member?(user)
    group_member.try(:member_type) == MODERATOR
  end

  def includes_member?(user)
    if user
      self.group_members.find(:first, :conditions => {:user_id => user.id})
    end
  end
end