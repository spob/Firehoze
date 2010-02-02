class CategoriesController < ApplicationController
  if APP_CONFIG[CONFIG_ALLOW_UNRECOGNIZED_ACCESS]
    before_filter :require_user, :except => [ :show, :index ]
  else
    before_filter :require_user
  end
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
    @no_uniform_js = true
    @category ||= Category.new(:sort_value => 10)
    @categories = Category.list params[:page], cookies[:per_page] || ROWS_PER_PAGE
  end

  def create
    @category = Category.new(params[:category])
    if @category.save
      flash[:notice] = t('category.create_success')
      redirect_to list_admin_categories_path
    else
      error_msg = ""
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
    @suggested_lessons = Lesson.lesson_recommendations(current_user, 5)
  end

  def show
    set_browse_sort_cookie(params[:sort_by], "most_popular") if params[:sort_by]
    id = params[:id]
    if id == "all"
      redirect_to categories_path
    else
      @category = Category.find(id)
      category_id = @category.id

      @ids = Lesson.ready.not_owned_by(current_user).by_category(category_id).ids + [-1]
      if fragment_exist?(Category.tag_cloud_cache_id("lesson", @category.id))
        @tags = ["dummy"]
      else
        @tags = Lesson.ready.tag_counts(:conditions => ["lessons.id IN (?)", @ids], :limit => 40, :order => "count DESC").sort{|x, y| x.name <=> y.name}
      end
      @lessons = case cookies[:browse_sort]
        when 'most_popular'
          Lesson.most_popular.find(:all, :conditions => { :id => @ids}).paginate(:per_page => LESSONS_PER_PAGE, :page => params[:page])
        when 'highest_rated'
          Lesson.highest_rated.find(:all, :conditions => { :id => @ids}).paginate(:per_page => LESSONS_PER_PAGE, :page => params[:page])
        else
          cookies[:browse_sort] = 'newest'
          Lesson.newest.find(:all, :conditions => { :id => @ids}).paginate(:per_page => LESSONS_PER_PAGE, :page => params[:page])
      end
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

  def set_browse_sort_cookie value, default_value
    value ||= default_value
    cookies[:browse_sort] = { :value => value, :expires => 1.day.from_now }
  end

  def layout_for_action
    if %w(list_admin edit).include?(params[:action])
      'admin_v2'
    elsif %w(index show).include?(params[:action])
      'application_v2'
    else
      'application'
    end
  end

  def find_category
    @category = Category.find params[:id]
  end
end
