class GroupMembersController < ApplicationController
  before_filter :require_user
  before_filter :find_group, :only => [:create, :destroy]
  before_filter :find_group_member, :only => [ :remove, :promote, :demote, :create_private ]
  verify :method => :post, :only => [:create, :promote, :demote, :create_private ], :redirect_to => :home_path
  verify :method => :delete, :only => [:destroy, :remove ], :redirect_to => :home_path

  layout :layout_for_action

  def create
    @group_member = @group.group_members.create!(:user => current_user, :member_type => MEMBER)
    flash[:notice] = t('group.join', :group => @group.name)
    redirect_to group_path(@group)
  end

  def promote
    if change_member_type(@group_member, current_user, MEMBER, MODERATOR)
      flash[:notice] = t('group.promote_success', :user => @group_member.user_login)
    else
      flash[:error] = t('general.no_permissions')
    end
    redirect_to group_path(@group_member.group)
  end

  def demote
    if change_member_type(@group_member, current_user, MODERATOR, MEMBER)
      flash[:notice] = t('group.demote_success', :user => @group_member.user_login)
    else
      flash[:error] = t('general.no_permissions')
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
    if @group.can_see? current_user
      redirect_to group_path(@group)
    else
      redirect_to my_stuff_my_firehoze_path
    end
  end

  def destroy
    @group_member = GroupMember.find_by_user_id_and_group_id(current_user.try(:id), params[:id])
    @group_member.destroy
    flash[:notice] = t('group.left', :group => @group.name)
    if @group.can_see? current_user
      redirect_to group_path(@group)
    else
      redirect_to my_stuff_my_firehoze_path
    end
  end

  def new_private
    # The invitation record is unmarshalled based upon the URL that was created by ActiveURL
    # when the invitation was first created. If we get here, it means the user
    # clicked on the link in their invitation email.
    @invitation = GroupInvitation.find(params[:group_invitation_id])
    unless @invitation.user == current_user
      flash[:error] = t('group_invitation.wrong_user', :user => @invitation.user.login)
      redirect_back_or_default home_path
      return
    end
    @group_member = GroupMember.find_by_user_id_and_group_id(current_user.try(:id), @invitation.group)
    if @group_member.nil?
      flash[:error] = t('group_invitation.rescinded')
      redirect_back_or_default home_path
    elsif @group_member.member_type != PENDING
      flash[:error] = t('group_invitation.already_member')
      redirect_back_or_default home_path
    end
    # retrieve various fields for the @user record based upon the values stored in the registration
#    @user = populate_user_from_registration_and_params
  rescue ActiveUrl::RecordNotFound
    flash[:error] = t 'group_invitation.invitation_no_longer_valid'
    redirect_back_or_default home_path
  end

  def create_private
    if @group_member.nil? or @group_member.member_type != PENDING or (params[:join] != 'yes' and params[:join] != 'no')
      flash[:error] = t 'group_invitation.invitation_no_longer_valid'
      redirect_back_or_default home_path
    elsif @group_member.user != current_user
      flash[:error] = t('group_invitation.wrong_user', :user => @group_member.user_login)
      redirect_back_or_default home_path
    elsif params[:join] == 'yes'
      @group_member.update_attribute(:member_type, MEMBER)
      flash[:notice] = t('group.welcome', :group => @group_member.group.name)
      redirect_to group_path(@group_member.group)
    else
      @group = @group_member.group
      @group_member.delete
      flash[:notice] = t('group.no_thanks')
      redirect_back_or_default home_path
    end
  end

  private

  def change_member_type(group_member, user, from_type, to_type)
    if group_member.group.owned_by?(user) and group_member.member_type == from_type
      group_member.update_attribute(:member_type, to_type)
      group_member
    end
  end

  def check_permissions(member, user)
    if @group_member.can_edit?(user)
      true
    else
      flash[:error] = t('general.no_permissions')
      false
    end
  end

  def find_group_member
    @group_member = GroupMember.find(params[:id])
  end

  def find_group
    @group = Group.find(params[:id])
  end

  def populate_invitation
    invitation = GroupInvitation.new(params[:invitation])
    invitation.user = @invitation.user
    invitation.group = @invitation.group
    invitation
  end

  def layout_for_action
    if %w(new_private create_private).include?(params[:action])
      'application_v2'
    else
      'application'
    end
  end
end