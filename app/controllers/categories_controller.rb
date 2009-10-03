class CategoriesController < ApplicationController
  before_filter :require_user, :except => [ :show ]
  before_filter :find_category, :except => [:index, :create, :explode, :show]

  # Admins only
  permit ROLE_ADMIN, :except => [ :show ]

  layout 'admin'

  verify :method => :post, :only => [:create, :explode], :redirect_to => :home_path
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

  def show
    return_path = params[:return_path].nil? ? root_path : params[:return_path]
    id = params[:id]
    if id == "all"
      session[:browse_category_id] = nil
    else
      @category = Category.find(id)
      session[:browse_category_id] = @category.id
    end
    redirect_to return_path
  end

  def update
    if @category.update_attributes(params[:category])
      flash[:notice] = t 'category.update_success'
      redirect_to categories_path
    else
      render :action => 'edit'
    end
  end

  def explode
    RunOncePeriodicJob.create!(
            :name => 'Explode Categories',
            :job => "Category.explode")
    flash[:notice] = t 'category.explosion_started'
    redirect_to categories_path
  end

  private

  def find_category
    @category = Category.find params[:id]
  end
end
