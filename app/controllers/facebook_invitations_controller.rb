class FacebookInvitationsController < ApplicationController

  def new
    if should_update_profile?
      update_profile
    end
    @from_user_id = facebook_session.user.to_s
    friend_ids = params[:fb_sig_friends].split(/,/)
  end

  def should_update_profile?
    params[:from]
  end

  def update_profile
    @user = facebook_session.user
    @user.profile_fbml =
            render_to_string(:partial=>"profile",
                             :locals=>{:from=>params[:from]})
  end

  def create
    @sent_to_ids = params[:ids]
  end
end
