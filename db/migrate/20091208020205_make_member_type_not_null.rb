class MakeMemberTypeNotNull < ActiveRecord::Migration
  def self.up
    GroupMember.delete_all( :group_id => nil  )
    change_column(:group_members, :member_type, :string, :null => false)
    change_column(:group_members, :group_id, :integer, :null => false)
    change_column(:group_members, :user_id, :integer, :null => false)
  end

  def self.down
    change_column(:group_members, :member_type, :string, :null => true)
    change_column(:group_members, :group_id, :integer, :null => true)
    change_column(:group_members, :user_id, :integer, :null => true)
  end
end
