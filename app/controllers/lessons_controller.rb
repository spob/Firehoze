class LessonsController < ApplicationController
  before_filter :require_user, :only => [:new, :create, :edit, :update, :watch, :convert]
  permit ROLE_SYSADMIN, :only => [:convert]

  verify :method => :post, :only => [ :create, :convert ], :redirect_to => :home_path
  verify :method => :put, :only => [ :update, :conversion_notify ], :redirect_to => :home_path
  before_filter :find_lesson, :only => [ :show, :edit, :update, :watch, :convert, :rate ]
  before_filter :set_per_page, :only => [ :index, :list ]

  # The number of free download counts to display on the create lesson page
  @@free_download_counts = [ 0, 5, 10, 25 ]

  def index
    @lessons = Lesson.list(params[:page], current_user)
  end

  def list
    @collection = params[:collection]
  end

  def new
    @lesson = Lesson.new
  end

  def create
    @lesson = Lesson.new(params[:lesson])
    @lesson.initial_free_download_count = params[:initial_free_download_count].try('to_i')
    # the instructor is assumed to be the current user when creating a new lesson
    @lesson.instructor = current_user
    if @lesson.save
      @lesson.trigger_conversion
      flash[:notice] = t 'lesson.created'
      redirect_to lesson_path(@lesson)
    else
      render :action => :new
    end
  end

  def show
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

  def watch
    if @lesson.ready?
      if current_user.owns_lesson? @lesson or current_user == @lesson.instructor
        # watch the video
      elsif @lesson.free_credits.available.size > 0
        if @lesson.consume_free_credit current_user
          redirect_to watch_lesson_path(@lesson)
        else
          # This should only happen in very rare circumstances with concurrency problems
          flash[:error] = t('lesson.need_credits')
          redirect_to lesson_path(@lesson)
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
  # automatically when a new file is uploaded...but the sysadmin can trigger it manually
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
    lesson = Lesson.find_by_flixcloud_job_id!(job.id)

    unless lesson.finish_conversion job
      logger.error "Job #{id} for lesson #{lesson.id} failed: #{job.error_message}"
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
      page.replace_html "#{dom_id(@lesson)}_count", "(#{pluralize(@lesson.total_rates, "person has", "people have")} rated this lesson)"
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

  def set_per_page
    @per_page = %w(index).include?(params[:action]) ? 3 : Lesson.per_page
  end

end
