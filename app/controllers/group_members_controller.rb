class GroupMembersController < ApplicationController
  before_filter :require_user
  before_filter :find_group_member, :only => [ :remove, :promote, :demote ]
  verify :method => :post, :only => [:create, :promote, :demote ], :redirect_to => :home_path
  verify :method => :delete, :only => [:destroy, :remove ], :redirect_to => :home_path

  def create
    @group = Group.find(params[:id])
    @group_member = GroupMember.create!(:user => current_user, :group => @group, :member_type => MEMBER)
    flash[:notice] = t('group.join', :group => @group.name)
    redirect_to group_path(@group)
  end

  def promote
    if @group_member.group.owned_by?(current_user) and @group_member.member_type == MEMBER
      @group_member.update_attribute(:member_type, MODERATOR)
      flash[:notice] = t('group.promote_success', :user => @group_member.user.login)
    else
    flash[:error] = t('group.no_permissions')
    end
    redirect_to group_path(@group_member.group)
  end

  def demote
    if @group_member.group.owned_by?(current_user) and @group_member.member_type == MODERATOR
      @group_member.update_attribute(:member_type, MEMBER)
      flash[:notice] = t('group.demote_success', :user => @group_member.user.login)
    else
    flash[:error] = t('group.no_permissions')
    end
    redirect_to group_path(@group_member.group)
  end

  def remove
    @user = @group_member.user
    @group = @group_member.group
    if check_permissions(@group_member, current_user)
      @group_member.destroy
      flash[:notice] = t('group.remove_success', :user => @user.login)
    end
    redirect_to group_path(@group)
  end

  def destroy
    @group = Group.find(params[:id])
    @group_member = GroupMember.find_by_user_id_and_group_id(current_user.try(:id), params[:id])
    @group.group_members.delete(@group_member)
    flash[:notice] = t('group.left', :group => @group.name)
    redirect_to group_path(@group)
  end

  private

  def check_permissions(member, user)
    if @group_member.can_edit?(user)
      return true
    end
    flash[:error] = t('group.no_permissions')
    false
  end

  def find_group_member
    @group_member = GroupMember.find(params[:id])
  end
end