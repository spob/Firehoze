# This controller is a nested resource. It will generally be invoked from the lesson controller
class LessonCommentsController < ApplicationController
  before_filter :require_user, :except => [:index]
  # Since this controller is nested, in most cases we'll need to retrieve the lesson first, so I made it a
  # before filter
  before_filter :find_lesson, :except => [ :edit, :update, :destroy ]
  before_filter :find_lesson_comment, :only => [ :edit, :update ]

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path
  verify :method => :destroy, :only => [:delete ], :redirect_to => :home_path

  def index
    @lesson_comments = LessonComment.list @lesson, params[:page]
    render :layout => 'content_in_tab'
  end

  def index
    @lesson_comments = LessonComment.list @lesson, params[:page]
    @style = params[:style]
    render :layout => 'content_in_tab' if @style == 'tab'
  end

  def new
    @lesson_comment = @lesson.comments.build
  end

  def create
    @lesson_comment = @lesson.comments.build(params[:lesson_comment])
    @lesson_comment.user = current_user
    if @lesson_comment.save
      flash[:notice] = t 'lesson_comment.create_success'
      redirect_to lesson_lesson_comments_path(@lesson)
    else
      render :action => 'new'
    end
  end

  def edit
    unless @lesson_comment.can_edit? current_user
      flash[:error] = t 'lesson_comment.cannot_edit'
      redirect_to lesson_lesson_comments_path(@lesson_comment.lesson)
    end
  end

  def update
    unless @lesson_comment.can_edit? current_user
      flash[:error] = t 'lesson_comment.cannot_edit'
      redirect_to lesson_lesson_comments_path(@lesson_comment.lesson)
      return
    end
    params[:lesson_comment][:public] ||= false
    if @lesson_comment.update_attributes(params[:lesson_comment])
      flash[:notice] = t 'lesson_comment.update_success'
      redirect_to lesson_lesson_comments_url(@lesson_comment.lesson)
    else
      render :action => 'edit'
    end
  end

  private

  # Called by thebefore filter to retrieve the lesson based on the lesson_id that
  # was passed in as a parameter
  def find_lesson
    @lesson = Lesson.find(params[:lesson_id])
  end

  def find_lesson_comment
    @lesson_comment = LessonComment.find(params[:id])
  end
end
