class AdminConsolesController < ApplicationController
  before_filter :require_user

  def index
    if current_user.is_admin?
      redirect_to list_users_path
    elsif current_user.is_moderator?
      redirect_to flags_path
    elsif current_user.is_paymentmgr?
      redirect_to payments_path
    else
      # force a permission denied                
      redirect_to list_users_path
    end
  end
end
