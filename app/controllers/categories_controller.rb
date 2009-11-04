class CategoriesController < ApplicationController
  before_filter :require_user, :except => [ :show, :index ]
  before_filter :find_category, :except => [:index, :list_admin, :create, :explode, :show]

  # Admins only
  permit ROLE_ADMIN, :except => [ :show, :index ]

  layout :layout_for_action

  verify :method => :post, :only => [:create, :explode], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path
  verify :method => :delete, :only => [:destroy ], :redirect_to => :home_path

  # These are the values displayed in the html select in the UI to define which type of SKU to create. For  now,
  # there is only one type
  @@sort_by = [ [ 'Most Popular', 'most_popular' ],
                [ 'Highest Rated', 'highest_rated' ],
                [ 'Newest', 'newest'] ]

  def self.sort_by
    @@sort_by
  end

  def list_admin
    @category ||= Category.new(:sort_value => 10)
    @categories = Category.list params[:page], session[:per_page] || ROWS_PER_PAGE
  end

  def create
    @category = Category.new(params[:category])
    if @category.save
      flash[:notice] = t('category.create_success')
      redirect_to list_admin_categories_path
    else
      error_msg = ""
#      @category.errors.each { |attr, msg| error_msg = error_msg + "#{error_msg == "" ? "" : ", "}#{attr} #{msg}" }
      flash[:error] = t('category.create_failed', :msg => error_msg)
      index
      redirect_to list_admin_categories_path
    end
  end

  def destroy
    name = @category.name
    @category.destroy
    flash[:notice] = t 'category.delete_success', :name => name
    redirect_to list_admin_categories_path
  end

  def edit

  end

  def index
    @categories = Category.root.ascend_by_sort_value
    render :layout => 'application_v2'
  end

  def show
    session[:browse_sort] = params[:sort_by] if params[:sort_by]
    id = params[:id]
    if id == "all"
      redirect_to categories_path
    else
      @category = Category.find(id)
      category_id = @category.id

      @lesson_format = 'wide'
      @lessons =
              case session[:browse_sort]
                when 'most_popular'
                  Lesson.ready.most_popular.not_owned_by(current_user).by_category(category_id).paginate(:per_page => LESSONS_PER_PAGE, :page => params[:page])
                when 'highest_rated'
                  Lesson.ready.highest_rated.not_owned_by(current_user).by_category(category_id).paginate(:per_page => LESSONS_PER_PAGE, :page => params[:page])
                else
                  session[:browse_sort] = 'newest'
                  Lesson.ready.newest.not_owned_by(current_user).by_category(category_id).paginate(:per_page => LESSONS_PER_PAGE, :page => params[:page])
              end
      @collection = session[:browse_sort]
    end
  end

  def update
    if @category.update_attributes(params[:category])
      flash[:notice] = t 'category.update_success'
      redirect_to list_admin_categories_path
    else
      render :action => 'edit'
    end
  end

  def explode
    RunOncePeriodicJob.create!(
            :name => 'Explode Categories',
            :job => "Category.explode")
    flash[:notice] = t 'category.explosion_started'
    redirect_to list_admin_categories_path
  end

  private

  def layout_for_action
    if %w(list_admin edit).include?(params[:action])
      'admin'
    else
      'application'
    end
  end

  def find_category
    @category = Category.find params[:id]
  end
end
