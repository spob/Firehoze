class LessonsController < ApplicationController
  include SslRequirement

  if APP_CONFIG[CONFIG_ALLOW_UNRECOGNIZED_ACCESS]
    before_filter :require_user, :only => [:new, :create, :edit, :update, :unreject]
  else
    before_filter :require_user, :except => [:conversion_notify, :index]
  end
  permit ROLE_ADMIN, :only => [:convert]
  permit "#{ROLE_ADMIN} or #{ROLE_MODERATOR}", :only => [:list_admin]
  permit ROLE_MODERATOR, :only => [:unreject]

  caches_page :index

  cache_sweeper :tag_cloud_sweeper, :only => [:update, :conversion_notify, :unreject]

  verify :method => :post, :only => [ :create, :convert, :unreject ], :redirect_to => :home_path
  verify :method => :put, :only => [ :update, :conversion_notify ], :redirect_to => :home_path
  before_filter :find_lesson, :only => [ :convert, :edit, :lesson_notes, :rate, :stats, :show_lesson_status, :show_groups, :update, :watch, :unreject ]
  before_filter :set_per_page, :only => [ :ajaxed, :index, :list, :tabbed, :tagged_with ]
  before_filter :set_collection, :only => [ :ajaxed, :list, :tabbed ]
  before_filter :set_no_uniform_js

  LIST_COLLECTIONS = %w(newest most_popular highest_rated tagged_with recently_browsed tagged_with)

  layout :layout_for_action

  # The number of free download counts to display on the create lesson page
  @@free_download_counts = [ 0, 5, 10, 25 ]


  # Unrecognized user page
  def index
    if params[:reset] == "y"
      # clear category browsing
      session[:browse_category_id] = nil
    end
    if current_user
      redirect_to home_path
    elsif APP_CONFIG[CONFIG_ALLOW_UNRECOGNIZED_ACCESS]
      @lessons = Lesson.list(params[:page], current_user)
    else
      # We're running in closed beta mode...redirect to the login page
      redirect_to login_path
    end
  end

  def list
    @lesson_format = 'wide'
    @category_id = session[:browse_category_id].to_i if session[:browse_category_id]
    @lessons =
            case @collection
              when 'most_popular'
                Lesson.ready.most_popular.not_owned_by(current_user).by_category(@category_id).paginate(:per_page => @per_page, :page => params[:page])
              when 'newest'
                Lesson.ready.newest.not_owned_by(current_user).by_category(@category_id).paginate(:per_page => @per_page, :page => params[:page])
              when 'highest_rated'
                Lesson.ready.highest_rated.not_owned_by(current_user).by_category(@category_id).paginate(:per_page => @per_page, :page => params[:page])
            end
  end

  def tagged_with
    @tag = params[:tag]
    @collection = 'tagged_with'
    @lesson_format = 'narrow'
    @lessons = Lesson.fetch_tagged_with nil, nil, @tag, @per_page, params[:page]
  end

  def list_admin
    @search = Lesson.searchlogic(params[:search])
    @lessons = @search.paginate :include => [:instructor, :category], :page => params[:page], :per_page => cookies[:per_page] || ROWS_PER_PAGE
  end

  def check_lesson_by_title
    @lesson = Lesson.find_by_title(params[:lesson][:title].try(:strip))

    respond_to do |format|
      format.js
    end
  end

  def new
    @lesson = Lesson.new
    unless current_user.verified_instructor? or current_user.try("is_an_admin?")
      flash[:error] = t 'lesson.must_be_instructor'
      redirect_to instructor_signup_wizard_account_path(current_user)
    end
  end

  def create
    if current_user.verified_instructor?
      video_param = params[:lesson].delete("video")
      video = nil
      @lesson = Lesson.new(params[:lesson])
      @lesson.initial_free_download_count = params[:initial_free_download_count].try('to_i')
      # the instructor is assumed to be the current user when creating a new lesson
      @lesson.instructor = current_user
      Lesson.transaction do
        if @lesson.save
          video = OriginalVideo.new({ :lesson => @lesson, :video => video_param})
          video.save!
          @lesson.trigger_conversion(conversion_notify_lessons_url)
          flash[:notice] = t 'lesson.created'
          redirect_to lesson_path(@lesson)
        else
          render :action => :new
        end
      end
    else
      flash[:error] = t 'lesson.must_be_instructor'
      redirect_to instructor_signup_wizard_account_path(current_user)
    end
  rescue Exception => e
    # Creating the original video failed...the lesson should have rolled back. Let's trap the error. This is
    # often because a wrong content type was attempted to be loaded
    content_type_str = ""
    content_type_str = "(content type: #{video.video.content_type})" unless video.nil?
    flash[:error] = "#{e.message} #{content_type_str}"
    render :action => :new
  end

  def advanced_search
    @advanced_search = AdvancedSearch.new
    @advanced_search.language = current_user.language if current_user
    @advanced_search.created_in = 30
    @advanced_search.created_in = 9999
    @advanced_search.categories ||= []
  end

  def perform_advanced_search
    # Dynamically setup the advanced search object so the search criteria will show properly in the screen
    @advanced_search = AdvancedSearch.new
    AdvancedSearch.public_instance_methods(false).find_all{|item| item.ends_with? "="}.each do |a|
      @advanced_search.send(a, params[:advanced_search][a.gsub(/=/, "")])
    end
    @advanced_search.categories = Category.find(:all, :conditions => { :id => params[:advanced_search][:category_ids]})

    # now perform the search
    conditions = params[:advanced_search]
    conditions[:status] = 'Ready'
    with = {}
    with[:created_at] = params[:advanced_search][:created_in].to_i.days.ago..1.day.since if params[:advanced_search][:created_in]
    with[:category_ids] = @advanced_search.categories.collect(&:id) unless @advanced_search.categories.empty?
    with[:rating_average] = params[:advanced_search][:rating_average].to_f..5.0 if params[:advanced_search][:rating_average]
    params[:advanced_search].delete(:category_ids)
    params[:advanced_search].delete(:created_in)
    params[:advanced_search].delete(:rating_average)
    @lessons = Lesson.search :conditions => conditions,
                             :with => with,
                             :include => :instructor,
                             :page => 1,
                             :per_page => ADVANCED_SEARCH_RESULTS_TO_DISPLAY,
                             :retry_stale => true
    render :action => :advanced_search
  end

  def show
    session[:lesson_to_buy] = nil
    @lesson = Lesson.find(params[:id], :include => [:instructor, :reviews])
    @show_purchases = @lesson.can_view_purchases?(current_user)
    @show_video_stats = @lesson.can_view_lesson_stats?(current_user)

    @instructor = @lesson.instructor

    if @lesson.ready? or @lesson.instructed_by?(current_user) or (current_user and current_user.is_a_moderator?)
      LessonVisit.touch(@lesson, current_user, request.session.session_id)
    else
      flash[:error] = t 'lesson.not_ready'
      redirect_to lessons_path
    end
  end

#  def recommend
#  end

  def show_groups
    @groups = @lesson.lesson_groups(current_user)
  end

  def stats
    @lesson = Lesson.find(params[:id], :include => [:instructor, :reviews])

    @show_purchases = @lesson.can_view_purchases?(current_user)
    @show_video_stats = @lesson.can_view_lesson_stats?(current_user)
  end

  def unreject
    if @lesson.status == LESSON_STATUS_REJECTED
      @lesson.update_status(true)
      @lesson.save!
      flash[:notice] = t 'lesson.unrejected'
    else
      flash[:error] = t 'lesson.unreject_failed'
    end
    redirect_to lesson_path(@lesson)
  end

  def lesson_notes
  end

  def edit
    unless @lesson.can_edit? current_user
      flash[:error] = t 'lesson.access_message'
      redirect_to lesson_path(@lesson)
    end
  end

  def update
    if @lesson.can_edit? current_user
      if @lesson.update_attributes(params[:lesson])
        flash[:notice] = t 'lesson.updated'
        redirect_to lesson_path(@lesson)
      else
        render :action => :edit
      end
    else
      flash[:error] = t 'lesson.access_message'
      redirect_to lesson_path(@lesson)
    end
  end

# update lesson status via ajax
  def show_lesson_status
    render :inline => "<%= translate('lesson.#{@lesson.status}') %> <%= image_tag('general/spinners/ajax-loader_small_arrows.gif') if @lesson.status == LESSON_STATUS_CONVERTING %>"
  end

# SUPPORTING AJAX TABS
  def tabbed
    @lesson_format = current_user ? 'narrow' : 'wide'
    @category_id = session[:browse_category_id].to_i if session[:browse_category_id]
    @lessons =
            case @collection
              when 'most_popular'
                Lesson.fetch_most_popular(current_user, @category_id, @per_page, 1)
              when 'newest'
                Lesson.fetch_newest(current_user, @category_id, @per_page, 1)
              when 'highest_rated'
                Lesson.fetch_highest_rated(current_user, @category_id, @per_page, 1)
            end
  end

# SUPPORTING AJAX PAGINATION (keeping this around for a little while, just in case we need it later)
  def ajaxed
    @lesson_format = 'wide'
    @category_id = session[:browse_category_id].to_i if session[:browse_category_id]
    @lessons =
            case @collection
              when 'most_popular'
                Lesson.fetch_most_popular(current_user, @category_id, @per_page, params[:page])
              when 'newest'
                Lesson.fetch_newest(current_user, @category_id, @per_page, params[:page])
              when 'highest_rated'
                Lesson.fetch_highest_rated(current_user, @category_id, @per_page, params[:page])
              when 'tagged_with'
                @lesson_format = 'narrow'
                @tag = params[:tag]
                Lesson.fetch_tagged_with(current_user, @category_id, @tag, @per_page, params[:page])
              when 'recently_browsed'
                Lesson.fetch_latest_browsed(current_user, @category_id, @per_page, params[:page])
              when 'owned'
                Lesson.fetch_owned(current_user, @per_page, params[:page])
              when 'wishlist'
                Lesson.fetch_wishlist(current_user, @category_id, @per_page, params[:page])
              when 'instructed'
                Lesson.fetch_instructed_lessons(current_user, @category_id, @per_page, params[:page])
            end
  end

  def watch
    if current_user
      if @lesson.ready?
        if current_user.owns_lesson? @lesson or current_user == @lesson.instructor
          redirect_to lesson_path(@lesson)
        elsif @lesson.free_credits.available.size > 0
          Lesson.transaction do
            if @lesson.consume_free_credit current_user
              current_user.wishes.delete(@lesson) if current_user.on_wish_list?(@lesson)
              redirect_to lesson_path(@lesson)
            else
              # This should only happen in very rare circumstances with concurrency problems
              flash[:error] = t('lesson.need_credits')
              redirect_to lesson_path(@lesson)
            end
          end
        elsif current_user.available_credits.empty?
          # User doesn't have enough credits...redirect them to the online store
          flash[:error] = t('lesson.need_credits')
          redirect_to store_path(@lesson)
        else
          redirect_to new_acquire_lesson_path(:id => @lesson)
        end
      else
        flash[:error] = t('lesson.not_ready')
        redirect_to lesson_path(@lesson)
      end
    else
      store_location lesson_path(@lesson)
      flash[:error] = t('lesson.must_logon_to_watch')
      redirect_to new_user_session_url
    end
  end

# Trigger a conversion to occur at flixcloud. This will normally be triggered to occur
# automatically when a new file is uploaded...but the admin can trigger it manually
  def convert
    @lesson.trigger_conversion conversion_notify_lessons_url
    flash[:notice] = t('lesson.conversion_triggered')
    redirect_to lesson_path(@lesson)
  end

# This method is the callback that flixcloud will invoke when the video has completed
# processing
  def conversion_notify
    render :text => "OK"
    job = FlixCloud::Notification.new(params)
    logger.info "Received conversion completion notification for job #{job.id}: #{job.state}"
    video = ProcessedVideo.find_by_flixcloud_job_id!(job.id)

    unless video.finish_conversion job
      logger.error "Job #{id} for lesson #{video.lesson.id} failed: #{job.error_message}"
      lesson.fail!
    end
  end

  def rate
    raise ArgumentError, 'A lesson can not be rated by the instructor of lesson' if @lesson.instructor == current_user
    @lesson.rate(params[:stars], current_user)
    id = "ajaxful-rating-lesson-#{@lesson.id}"
    render :update do |page|
      page.replace_html id, ratings_for(@lesson, :wrap => false)
      page.replace_html "#{dom_id(@lesson)}_average", current_average(@lesson)
      page.replace_html "#{dom_id(@lesson)}_count", vote_counts_phrase(@lesson)
      page.visual_effect :highlight, id
    end
  end

# Used to populate the free download count drop down
  def self.free_download_counts
    @@free_download_counts
  end

  private

# disable the uniform plugin, otherwise the advanced search form is all @$@!# up
  def set_no_uniform_js
    if %w(advanced_search list_admin perform_advanced_search new create edit update).include?(params[:action])
      @no_uniform_js = true
    end
  end

  def layout_for_action
    if params[:style] == 'tab'
      'content_in_tab'
    elsif %w(tabbed).include?(params[:action])
      'content_in_tab'
    elsif %w(list_admin).include?(params[:action])
      'admin_v2'
    elsif %w(index).include?(params[:action])
      'unrecognized'
    else
      'application_v2'
    end
  end

  def find_lesson
    @lesson = Lesson.find(params[:id])
  end

  def set_collection
    @collection = params[:collection] || 'most_popular'
    raise "Invalid collection" unless (LIST_COLLECTIONS).include?(@collection)
  rescue
    false
  end

  def set_per_page
    @per_page =
            if params[:per_page]
              params[:per_page]
            elsif %w(tabbed).include?(params[:action])
              3
            elsif %w(ajaxed).include?(params[:action])
              5
            else
              Lesson.per_page
            end
  end

end
