class CategoriesController < ApplicationController
  before_filter :require_user

  # Admins only
  permit ROLE_ADMIN

#  verify :method => :post, :only => [:create ], :redirect_to => :home_path
#  verify :method => :put, :only => [:update ], :redirect_to => :home_path
#  verify :method => :destroy, :only => [:delete ], :redirect_to => :home_path

  def index
    @categories = Category.list params[:page], session[:per_page] || ROWS_PER_PAGE
  end
end
