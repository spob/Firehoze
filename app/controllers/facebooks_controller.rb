class FacebooksController < ApplicationController

#  before_filter :require_user

  def connect
    # if the session isn't secured, we don't have a good user id
    if facebook_session and
            facebook_session.secured? and
            !request_is_facebook_tab?
      @user = User.facebook_key_equals(params[:id]).first
      if @user
        @user.update_attributes(:facebook_id => facebook_session.user.uid, :facebook_key => nil)
        flash[:notice] = "Your facebook account has been associated to your Firehoze account"
      else
        flash[:error] = "Can't find account to associate to"
      end
    end
  end

  def index
    
  end

  private

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  def set_current_user
    set_facebook_session
    # if the session isn't secured, we don't have a good user id
    if facebook_session and
            facebook_session.secured? and
            !request_is_facebook_tab?
      self.current_user =
              User.for(facebook_session.user.to_i, facebook_session)
    end
  end
end
