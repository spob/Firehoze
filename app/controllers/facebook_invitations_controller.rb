class FacebookInvitationsController < ApplicationController
#  verify :method => :post, :only => [:create ], :redirect_to => :facebooks_path

  def new
    if should_update_profile?
      update_profile
    end
    @from_user_id = facebook_session.user.to_s
#    friend_ids = params[:fb_sig_friends].split(/,/)
#  	@not_potential_users =
#  	  current_user.friends_with_senseis(friend_ids).map(&:facebook_id)
  end

  def create
    puts "====================================================here"
    @sent_to_ids = params[:ids]
    puts "====================================================there"
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
end
