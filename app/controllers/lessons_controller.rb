class LessonsController < ApplicationController

  before_filter :require_user, :only => [:new, :create, :edit, :update, :unreject]
  permit ROLE_ADMIN, :only => [:convert]
  permit ROLE_MODERATOR, :only => [:unreject]

  verify :method => :post, :only => [ :create, :convert, :unreject ], :redirect_to => :home_path
  verify :method => :put, :only => [ :update, :conversion_notify ], :redirect_to => :home_path
  before_filter :find_lesson, :only => [ :convert, :edit, :lesson_notes, :rate, :show, :update, :watch, :unreject ]
  before_filter :set_per_page, :only => [ :index, :list, :ajaxed, :tabbed ]
  before_filter :set_collection, :only => [ :list, :ajaxed, :tabbed ]

  LIST_COLLECTIONS = %w(newest most_popular highest_rated tagged_with recently_browsed)

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
    @lesson_format = 'wide'
    @lessons =
            case @collection
              when 'most_popular'
                if current_user
                  Lesson.ready.most_popular.not_owned_by(current_user).paginate(:per_page => @per_page, :page => params[:page])
                else
                  Lesson.ready.most_popular.paginate(:per_page => @per_page, :page => params[:page])
                end
              when 'newest'
                if current_user
                  Lesson.ready.newest.not_owned_by(current_user).paginate(:per_page => @per_page, :page => params[:page])
                else
                  Lesson.ready.newest.paginate(:per_page => @per_page, :page => params[:page])
                end
              when 'highest_rated'
                if current_user
                  Lesson.ready.highest_rated.not_owned_by(current_user).paginate(:per_page => @per_page, :page => params[:page])
                else
                  Lesson.ready.highest_rated.paginate(:per_page => @per_page, :page => params[:page])
                end
              when 'tagged_with'
                @lesson_format = 'narrow'
                @tag = params[:tag]
                Lesson.ready.find_tagged_with(@tag).paginate(:page => params[:page], :per_page => @per_page)
            end
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
    @style = params[:style]
    if @style == 'tab'
      render :layout => 'content_in_tab'
      return
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
                if current_user
                  Lesson.ready.most_popular.not_owned_by(current_user).all(:limit => @per_page)
                else
                  Lesson.ready.most_popular.all(:limit => @per_page)
                end
              when 'newest'
                if current_user
                  Lesson.ready.newest.not_owned_by(current_user).all(:limit => @per_page)
                else
                  Lesson.ready.newest.all(:limit => @per_page)
                end
              when 'highest_rated'
                if current_user
                  Lesson.ready.highest_rated.not_owned_by(current_user).all(:limit => @per_page)
                else
                  Lesson.ready.highest_rated.all(:limit => @per_page)
                end
            end
    render :layout => 'content_in_tab'
  end

  # SUPPORTING AJAX PAGINATION (keeping this around for a little while, just in case we need it later)
  def ajaxed
    @lesson_format = 'wide'
    @lessons =
            case @collection
              when 'most_popular'
                if current_user
                  Lesson.ready.most_popular.not_owned_by(current_user).ready.paginate(:per_page => @per_page, :page => params[:page])
                else
                  Lesson.ready.most_popular.ready.paginate(:per_page => @per_page, :page => params[:page])
                end
              when 'newest'
                if current_user
                  Lesson.ready.newest.not_owned_by(current_user).ready.paginate(:per_page => @per_page, :page => params[:page])
                else
                  Lesson.ready.newest.ready.paginate(:per_page => @per_page, :page => params[:page])
                end
              when 'highest_rated'
                if current_user
                  Lesson.ready.highest_rated.not_owned_by(current_user).ready.paginate(:per_page => @per_page, :page => params[:page])
                else
                  Lesson.ready.highest_rated.ready.paginate(:per_page => @per_page, :page => params[:page])
                end
            end
  end

  # FIXME -- testing purposes here ...
  #def list_recently_browsed
  #  me = User.find 2
  #  @lessons = me.visited_lessons.latest.paginate :page => params[:page], :per_page => @per_page
  #  render :layout => 'content_in_tab'
  #end

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
          redirect_to store_path(1)
        else
          redirect_to new_acquire_lesson_path(:id => @lesson)
        end
      else
        flash[:error] = t('lesson.not_ready')
        redirect_to lesson_path(@lesson)
      end
    else
      store_location lesson_path(@lesson)
      flash[:error] = t('lesson.must_logon')
      redirect_to new_user_session_url
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
    raise "Invalid collection" unless (LIST_COLLECTIONS).include?(@collection)
  rescue
    false
  end

  def set_per_page
    @per_page =
            if %w(tabbed).include?(params[:action])
              3
            elsif %w(ajaxed).include?(params[:action])
              5
            else
              Lesson.per_page
            end
  end
end
