class GroupInvitationsController < ApplicationController
  before_filter :require_user
  before_filter :find_group, :except => [ :check_user_by_login, :check_user]

  layout 'application_v2'

  verify :method => :post, :only => [:create], :redirect_to => :home_path

  def new
    @group_invitation ||= GroupInvitation.new
    unless can_invite(@group)
      redirect_to group_path(@group)
    end
  end

  def create
    if can_invite(@group)
      @group_invitation ||= GroupInvitation.new
      @group_invitation.to_user = params[:group_invitation][:to_user]
      @group_invitation.to_user_email = params[:group_invitation][:to_user_email]
      user_str = (@group_invitation.to_user.blank? ? @group_invitation.to_user_email : @group_invitation.to_user)
      @group_invitation.user = User.find_by_login_or_email(@group_invitation.to_user, @group_invitation.to_user_email)
      @group_invitation.group = @group
      @group_invitation.message = params[:group_invitation][:message]
      if @group_invitation.user.nil?
        flash.now[:error] = t('group.no_such_user', :user => user_str)
        render 'new'
      else
        if @group_invitation.save
          @group_member = @group.invite(@group_invitation.user)
          flash[:notice] = t('group.invitation_success', :user => user_str)
          redirect_to group_path(@group)
        else
          render 'new'
        end
      end
    else
      redirect_to group_path(@group)
    end
  end

  def check_user
    @user = User.find_by_login(params[:group_invitation][:to_user].try(:strip))
    @user ||= User.find_by_email(params[:group_invitation][:to_user_email].try(:strip))

    respond_to do |format|
      format.js
    end
  end

  private

  def can_invite(group)
    if !group.private
      flash[:error] = t('group.cannot_invite_public_group')
    elsif !group.owned_by?(current_user) and !group.moderated_by?(current_user)
      flash[:error] = t('group.must_be_owner_or_moderator')
    end
    flash[:error].nil?
  end

  def find_group
    @group = Group.find params[:id]
  end
end