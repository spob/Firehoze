class LessonsController < ApplicationController
  before_filter :require_user, :only => [:new, :create, :edit, :update, :watch]

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path

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
      flash[:notice] = t 'lesson.created)'
      redirect_to lesson_path(@lesson)
    else
      render :action => :new
    end
  end

  def show
    @lesson = Lesson.find params[:id]
  end

  def edit
    @lesson = Lesson.find params[:id]
    unless @lesson.can_edit? current_user
      flash[:error] = t 'lesson.access_message'
      redirect_to lesson_path(@lesson)
    end
  end

  def update
    @lesson = Lesson.find params[:id]
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
    @lesson = Lesson.find params[:id]
    if current_user.owns_lesson? @lesson
      # watch the video
    elsif current_user.available_credits.empty?
      # User doesn't have enough credits...redirect them to the online store
      flash[:error] = t('lesson.need_credits')
      redirect_to store_path(1)
    else
      redirect_to acquire_lesson_path(@lesson)
    end
  end
end