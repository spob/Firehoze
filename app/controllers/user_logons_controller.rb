# Allow an admin to see a history of user logons
class UserLogonsController < ApplicationController
  include SslRequirement
  
  before_filter :require_user

  # admins only
  permit ROLE_ADMIN

  layout 'admin_v2'

  def index
    @search = UserLogon.last_90_days.descend_by_created_at.search(params[:search])
    @user_logons = @search.paginate(:include => [:user],
                                    :page => params[:page],
                                    :per_page => (session[:per_page] || ROWS_PER_PAGE))
  end
end
