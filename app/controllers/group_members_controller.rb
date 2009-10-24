class GroupMembersController < ApplicationController
  before_filter :require_user
  verify :method => :post, :only => [:create], :redirect_to => :home_path
  verify :method => :delete, :only => [:destroy ], :redirect_to => :home_path
  
  def create
    @group = Group.find(params[:id])
    @group_member = GroupMember.create!(:user => current_user, :group => @group, :member_type => MEMBER)
    flash[:notice] = t('group.join', :group => @group.name)
    redirect_to groups_path
  end

  def destroy
    @group = Group.find(params[:id])
    @group_member = GroupMember.find_by_user_id_and_group_id(current_user.try(:id), params[:id])
    @group.group_members.delete(@group_member)
    flash[:notice] = t('group.left', :group => @group.name)
    redirect_to groups_path
  end
end