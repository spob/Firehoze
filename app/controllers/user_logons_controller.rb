class UserLogonsController < ApplicationController
  before_filter :require_user

  permit Constants::ROLE_SYSADMIN

  def index
    @user_logons = UserLogon.list params[:page]
  end
end
