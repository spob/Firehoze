# Allow an admin to see a history of user logons
class UserLogonsController < ApplicationController
  before_filter :require_user

  # admins only
  permit ROLE_ADMIN

  def index
    @user_logons = UserLogon.list params[:page]
  end
end
