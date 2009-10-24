class GroupMembersController < ApplicationController
  before_filter :require_user
  verify :method => :post, :only => [:create], :redirect_to => :home_path
  verify :method => :delete, :only => [:destroy ], :redirect_to => :home_path
  
  def create
    @group = Group.find(params[:id])
    @group_member = GroupMember.create!(:user => current_user, :group => @group, :member_type => MEMBER)
    flash[:notice] = t('group.added_membership', :group => @group.name)
    redirect_to groups_path
  end

  def destroy
  end

end
