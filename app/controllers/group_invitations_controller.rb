class GroupInvitationsController < ApplicationController
  before_filter :require_user
  before_filter :find_group

  verify :method => :post, :only => [:create], :redirect_to => :home_path

  def new
    unless can_invite(@group)
      redirect_to group_path(@group)
    end
  end

  def create
    if can_invite(@group)
      @to_user = User.find_by_login(params[:to_user])
      @to_user ||= User.find_by_email(params[:to_user_email])
      user_str = params[:to_user]
      user_str = params[:to_user_email] if user_str.nil? or user_str.blank?
      if @to_user.nil?
        flash.now[:error] = t('group.no_such_user', :user => user_str)
        render 'new'
      else
        invite = GroupInvitation.new
        invite.user = @to_user
        invite.group = @group
        invite.message = params[:message]
        if invite.save
          @group_member = @group.group_members.find(:first, :conditions => {:user_id => @to_user.id })
          if @group_member
            @group_member.touch
          else
            @group_member = GroupMember.create!(:user => @to_user, :group => @group, :member_type => PENDING)
          end
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
