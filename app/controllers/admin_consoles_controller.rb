class AdminConsolesController < ApplicationController
  include SslRequirement
  
  before_filter :require_user

  def index
    if current_user.is_an_admin? or current_user.is_a_communitymgr?
      redirect_to list_users_path('search[order]' => 'ascend_by_login')
    elsif current_user.is_a_moderator?
      redirect_to flags_path
    elsif current_user.is_paymentmgr?
      redirect_to payments_path
    else
      # force a permission denied                
      redirect_to list_users_path
    end
  end
end
