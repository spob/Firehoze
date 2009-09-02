class PaymentsController < ApplicationController
  before_filter :require_user

  # Admins only
  permit ROLE_ADMIN

  layout 'admin'

  #verify :method => :post, :only => [:create ], :redirect_to => :home_path
  #verify :method => :put, :only => [:update ], :redirect_to => :home_path
  #verify :method => :destroy, :only => [:delete ], :redirect_to => :home_path

  def index
    @users = User.instructors.sort_by{|user| user.unpaid_credits_amount * -1}.paginate :page => params[:page],
                                                                                       :per_page => (session[:per_page] || ROWS_PER_PAGE)
  end

  def show_unpaid
    @user = User.find(params[:id])
  end
end
