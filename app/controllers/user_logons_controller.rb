# Allow a sysadmin to see a history of user logons
class UserLogonsController < ApplicationController
  before_filter :require_user

  # sysadmins only
  permit ROLE_SYSADMIN

  def index
    @user_logons = UserLogon.list params[:page]
  end
end
