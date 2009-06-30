class LessonsController < ApplicationController
  before_filter :require_user, :only => [:new, :create, :edit, :update, :watch, :convert]
  permit Constants::ROLE_SYSADMIN, :only => [:convert]

  verify :method => :post, :only => [:create, :convert ], :redirect_to => :home_path
  verify :method => :put, :only => [:update, :conversion_notify ], :redirect_to => :home_path
  before_filter :find_lesson, :only => [ :show, :edit, :update, :watch, :convert, :rate ]

  def index
    @lessons = Lesson.list(params[:page], (current_user and current_user.is_sysadmin?))
  end

  def new
    @lesson = Lesson.new
  end

  def create
    @lesson = Lesson.new(params[:lesson])
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
    if current_user.owns_lesson? @lesson or current_user == @lesson.instructor
      # watch the video
    elsif current_user.available_credits.empty?
      # User doesn't have enough credits...redirect them to the online store
      flash[:error] = t('lesson.need_credits')
      redirect_to store_path(1)
    else
      redirect_to new_acquire_lesson_path(:id => @lesson)
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
    @lesson.rate(params[:stars], current_user)
    id = "ajaxful-rating-lesson-#{@lesson.id}" 
    render :update do |page|
      page.replace_html id, ratings_for(@lesson, :wrap => false)
      page.visual_effect :highlight, id
    end
  end

  private

  def find_lesson
    @lesson = Lesson.find(params[:id])
  end

end
