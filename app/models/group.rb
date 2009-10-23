class Group < ActiveRecord::Base
  has_friendly_id :name

  belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"
  validates_presence_of :name, :owner
  validates_uniqueness_of :name

  def owned_by?(user)
    self.owner == user
  end
end
