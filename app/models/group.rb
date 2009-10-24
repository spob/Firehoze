class Group < ActiveRecord::Base
  has_friendly_id :name

  belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"
  has_many :group_members
  has_many :users, :through => :group_members
  validates_presence_of :name, :owner
  validates_uniqueness_of :name

  def owned_by?(user)
    self.owner == user
  end

  def includes_member?(user)
    if user
      self.group_members.find(:first, :conditions => {:user_id => user.id})
    end
  end
end