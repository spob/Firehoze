class CategoriesController < ApplicationController
  before_filter :require_user
  before_filter :find_category, :except => [:index, :create]

  # Admins only
  permit ROLE_ADMIN

  layout 'admin'

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path
  verify :method => :delete, :only => [:destroy ], :redirect_to => :home_path

  def index
    @category ||= Category.new(:sort_value => 10)
    @categories = Category.list params[:page], session[:per_page] || ROWS_PER_PAGE
  end

  def create
    @category = Category.new(params[:category])
    if @category.save
      flash[:notice] = t('category.create_success')
      redirect_to categories_path
    else
      error_msg = ""
      @category.errors.each { |attr, msg| error_msg = error_msg + "#{error_msg == "" ? "" : ", "}#{attr} #{msg}" }
      flash[:error] = t('category.create_failed', :msg => error_msg)
      index
      redirect_to categories_path
    end
  end

  def destroy
    name = @category.name
    @category.destroy
    flash[:notice] = t 'category.delete_success', :name => name
    redirect_to categories_path
  end

  def edit

  end

  def update

  end

  private

  def find_category
    @category = Category.find params[:id]
  end
end
