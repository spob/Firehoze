class LessonsController < ApplicationController
  before_filter :require_user, :only => [:new, :create, :edit, :update]

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
    @lesson.author = current_user
    if @lesson.save
      flash[:notice] = "Lesson created"
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
      flash[:error] = "You do not have access to edit this lesson"
      redirect_to lesson_path(@lesson)
    end
  end

  def update
    @lesson = Lesson.find params[:id]
    if @lesson.can_edit? current_user
      if @lesson.update_attributes(params[:lesson])
        flash[:notice] = "Lesson updated!"
        redirect_to lesson_path(@lesson)
      else
        render :action => :edit
      end
    else
      flash[:error] = "You do not have access to edit this lesson"
      redirect_to lesson_path(@lesson)
    end
  end
end