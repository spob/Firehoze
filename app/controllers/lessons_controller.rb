class LessonsController < ApplicationController

  TAB_COLLECTIONS = %w(tabbed tabbed_lessons, tabbed_newest tabbed_most_popular tabbed_highest_rated)
  AJAX_PAGED_COLLECTIONS = %w(ajax_list_newest ajax_list_most_popular ajax_list_highest_rated)

  before_filter :require_user, :only => [:new, :create, :edit, :update, :watch]
  permit ROLE_ADMIN, :only => [:convert]

  verify :method => :post, :only => [ :create, :convert ], :redirect_to => :home_path
  verify :method => :put, :only => [ :update, :conversion_notify ], :redirect_to => :home_path
  before_filter :find_lesson, :only => [ :show, :edit, :update, :watch, :convert, :rate ]
  before_filter :set_per_page, :only => [ :index, :list, :ajax_list_newest, :ajax_list_most_popular, :ajax_list_highest_rated, :tabbed ]
  before_filter :set_collection, :only => TAB_COLLECTIONS

  # The number of free download counts to display on the create lesson page
  @@free_download_counts = [ 0, 5, 10, 25 ]

  def index
    if current_user
      redirect_to home_path
    else
      @lessons = Lesson.list(params[:page], current_user)
    end
  end

  def list
    @collection = params[:collection]
  end

  def new
    @lesson = Lesson.new
  end

  def create
    video_param = params[:lesson].delete("video")
    video = nil
    @lesson = Lesson.new(params[:lesson])
    @lesson.initial_free_download_count = params[:initial_free_download_count].try('to_i')
    # the instructor is assumed to be the current user when creating a new lesson
    @lesson.instructor = current_user
    Lesson.transaction do
      if @lesson.save
        video = OriginalVideo.new({ :lesson => @lesson,
                                    :video => video_param})
        video.save!
        @lesson.trigger_conversion
        flash[:notice] = t 'lesson.created'
        redirect_to lesson_path(@lesson)
      else
        render :action => :new
      end
    end
  rescue Exception => e
    # Creating the original video failed...the lesson should have rolled back. Let's trap the error. This is
    # often because a wrong content type was attempted to be loaded
    content_type_str = ""
    content_type_str = "(content type: #{video.video.content_type})" unless video.nil?
    flash[:error] = "#{e.message} #{content_type_str}"
    render :action => :new
  end

  def show
    if @lesson.ready? or @lesson.instructed_by?(current_user) or (current_user and current_user.is_moderator?)
      LessonVisit.touch(@lesson, current_user, request.session.session_id)
    else
      flash[:error] = t 'lesson.not_ready'
      redirect_to lessons_path
    end
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

  # SUPPORTING AJAX TABS
  def tabbed
    @lesson_format = current_user ? 'narrow' : 'wide'

    @lessons =
            case @collection
              when 'most_popular'
                @more_path = ajax_list_most_popular_lessons_path
                if current_user
                  Lesson.ready.most_popular.not_owned_by(current_user).all(:limit => @per_page) #.paginate(:per_page => @per_page, :page => params[:page])
                else
                  Lesson.ready.most_popular.all(:limit => @per_page) #.paginate(:per_page => @per_page, :page => params[:page])
                end
              when 'newest'
                @more_path = ajax_list_newest_lessons_path
                if current_user
                  Lesson.ready.newest.not_owned_by(current_user).all(:limit => @per_page) #.paginate(:per_page => @per_page, :page => params[:page])
                else
                  Lesson.ready.newest.all(:limit => @per_page) #.paginate(:per_page => @per_page, :page => params[:page])
                end
              when 'highest_rated'
                @more_path = ajax_list_highest_rated_lessons_path
                if current_user
                  Lesson.ready.highest_rated.not_owned_by(current_user).all(:limit => @per_page) #.paginate(:per_page => @per_page, :page => params[:page])
                else
                  Lesson.ready.highest_rated.all(:limit => @per_page) #.paginate(:per_page => @per_page, :page => params[:page])
                end
            end
    render :layout => 'lessons_in_tab'
  end

  def tabbed_newest
    if current_user
      @lessons = Lesson.ready.newest.not_owned_by(current_user).paginate(:per_page => @per_page, :page => params[:page])
    else
      @lessons = Lesson.ready.newest.paginate(:per_page => @per_page, :page => params[:page])
    end
    render :layout => 'lessons_in_tab'
  end

  def tabbed_most_popular
    if current_user
      @lessons = Lesson.ready.most_popular.not_owned_by(current_user).paginate(:per_page => @per_page, :page => params[:page])
    else
      @lessons = Lesson.ready.most_popular.paginate(:per_page => @per_page, :page => params[:page])
    end
    render :layout => 'lessons_in_tab'
  end

  def tabbed_highest_rated
    if current_user
      @lessons = Lesson.ready.highest_rated.not_owned_by(current_user).paginate(:per_page => @per_page, :page => params[:page])
    else
      @lessons = Lesson.ready.highest_rated.paginate(:per_page => @per_page, :page => params[:page])
    end
    render :layout => 'lessons_in_tab'
  end

  # SUPPORTING AJAX PAGINATION
  def ajax_list_newest
    @lessons = Lesson.ready.newest.paginate(:per_page => @per_page, :page => params[:page])
  end

  def ajax_list_most_popular
    @lessons = Lesson.ready.most_popular.paginate(:per_page => @per_page, :page => params[:page])
  end

  def ajax_list_highest_rated
    @lessons = Lesson.ready.highest_rated.paginate(:per_page => @per_page, :page => params[:page])
  end

  # FIXME -- testing purposes here ...
  def list_recently_browsed
    me = User.find 2
    @lessons = me.visited_lessons.paginate :page => params[:page], :per_page => @per_page
    render :layout => 'lessons_in_tab'
  end

  def watch
    if @lesson.ready?
      if current_user.owns_lesson? @lesson or current_user == @lesson.instructor
        # watch the video
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
        redirect_to store_path(1)
      else
        redirect_to new_acquire_lesson_path(:id => @lesson)
      end
    else
      flash[:error] = t('lesson.not_ready')
      redirect_to lesson_path(@lesson)
    end
  end

  # Trigger a conversion to occur at flixcloud. This will normally be triggered to occur
  # automatically when a new file is uploaded...but the admin can trigger it manually
  def convert
    @lesson.trigger_conversion
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

  def find_lesson
    @lesson = Lesson.find(params[:id])
  end


  def set_collection
    @collection = params[:collection]
    raise "Invalid collection" unless (TAB_COLLECTIONS).include?(@collection)
  rescue
    # send_response_document :unprocessable_entity
    false
  end

  def set_per_page
    if TAB_COLLECTIONS.include?(params[:action])
      @per_page = 3
    elsif AJAX_PAGED_COLLECTIONS.include?(params[:action])
      @per_page = 5
    else
      @per_page = %w(index).include?(params[:action]) ? 5 : Lesson.per_page
    end
  end
end
