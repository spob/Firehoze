class UserLogonsController < ApplicationController
  before_filter :require_user

  permit "sysadmin"

  def index
    @user_logons = UserLogon.list params[:page]
  end
end
