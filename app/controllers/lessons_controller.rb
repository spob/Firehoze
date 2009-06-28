class LessonsController < ApplicationController
  before_filter :require_user, :only => [:new, :create, :edit, :update, :watch]

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :put, :only => [:update, :conversion_notify ], :redirect_to => :home_path
  before_filter :find_lesson, :only => [ :show, :edit, :update, :watch ]

  def index
    @lessons = Lesson.list params[:page]
  end

  def new
    @lesson = Lesson.new
  end

  def create
    @lesson = Lesson.new(params[:lesson])
    # the instructor is assumed to be the current user when creating a new lesson
    @lesson.instructor = current_user
    if @lesson.save
      RunOncePeriodicJob.create(:name => 'ConvertVideo',
                                :job => "Lesson.convert_video #{@lesson.id}")
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

  def conversion_notify
    render :text => "OK" 
    job = FlixCloud::Notification.new(params)
    logger.info "Received conversion completion notification for job #{job.id}: #{job.state}"
    lesson = Lesson.find_by_flixcloud_job_id!(job.id)
    if job.successful?
      lesson.conversion_ended_at = job.finished_job_at  
      lesson.finish_conversion!
    else
      logger.error "Job #{id} for lesson #{lesson.id} failed: #{job.error_message}"
      lesson.fail!   
    end
  end

  private

  def find_lesson
    @lesson = Lesson.find(params[:id])
  end

end
