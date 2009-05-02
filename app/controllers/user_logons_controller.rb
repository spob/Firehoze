class UserLogonsController < ApplicationController
  before_filter :require_user

  permit RoleDefinition::SYSADMIN

  def index
    @user_logons = UserLogon.list params[:page]
  end
end
