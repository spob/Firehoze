class FacebooksController < ApplicationController
  ensure_authenticated_to_facebook
  ensure_application_is_installed_by_facebook_user

#  before_filter :set_current_user

  def index
    set_facebook_session
    # if the session isn't secured, we don't have a good user id
    if facebook_session and
            facebook_session.secured? and
            !request_is_facebook_tab?
      @fb_id = facebook_session.user.to_i
    end
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
