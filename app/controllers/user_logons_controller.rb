# Allow an admin to see a history of user logons
class UserLogonsController < ApplicationController
  include SslRequirement
  
  before_filter :require_user

  # admins only
  permit "#{ROLE_ADMIN} or #{ROLE_COMMUNITY_MGR}"

  layout 'admin'

  def index
    @search = UserLogon.last_90_days.descend_by_created_at.search(params[:search])
    @user_logons = @search.paginate(:include => [:user],
                                    :page => params[:page],
                                    :per_page => (cookies[:per_page] || ROWS_PER_PAGE))
  end
end
