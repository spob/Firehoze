# This controller is a nested resource. It will generally be invoked from the lesson controller
class LessonCommentsController < ApplicationController
  include SslRequirement

  if APP_CONFIG[CONFIG_ALLOW_UNRECOGNIZED_ACCESS]
    before_filter :require_user, :except => [:index, :new]
  else
    before_filter :require_user
  end
  # Since this controller is nested, in most cases we'll need to retrieve the lesson first, so I made it a
  # before filter
  before_filter :find_lesson, :except => [ :edit, :update ]
  before_filter :find_lesson_comment, :only => [ :edit, :update ]

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path
#  verify :method => :destroy, :only => [:delete ], :redirect_to => :home_path

  layout :layout_for_action

  def index
    @lesson_comments = LessonComment.list @lesson, params[:page], current_user
    @style = params[:style]
    render :layout => 'content_in_tab' if @style == 'tab'
  end

  def new
    if can_comment? current_user, @lesson
      @lesson_comment = @lesson.comments.build
      @lesson_comment.public = true
    end
  end

  def create
    if can_comment? current_user, @lesson
      @lesson_comment = @lesson.comments.build(params[:lesson_comment])
      @lesson_comment.user = current_user
      if @lesson_comment.save
        flash[:notice] = t 'lesson_comment.create_success'
        redirect_to lesson_path(@lesson, :anchor => :lesson_comment)
      else
        render :action => 'new'
      end
    end
  end

  def edit
    unless @lesson_comment.can_edit? current_user
      flash[:error] = t 'lesson_comment.cannot_edit'
      redirect_to lesson_path(@lesson_comment.lesson, :anchor => :lesson_comment)
    end
  end

  def update
    if @lesson_comment.can_edit? current_user
      params[:lesson_comment][:public] ||= false
      if @lesson_comment.update_attributes(params[:lesson_comment])
        flash[:notice] = t 'lesson_comment.update_success'
        redirect_to lesson_url(@lesson_comment.lesson, :anchor => :lesson_comment)
      else
        render :action => 'edit'
      end
    else
      flash[:error] = t 'lesson_comment.cannot_edit'
      redirect_to lesson_path(@lesson_comment.lesson, :anchor => :lesson_comment)
    end
  end

  private

  # Called by the before filter to retrieve the lesson based on the lesson_id that
  # was passed in as a parameter
  def find_lesson
    @lesson = Lesson.find(params[:lesson_id])
  end

  def find_lesson_comment
    @lesson_comment = LessonComment.find(params[:id])
  end

  def layout_for_action
    if %w(create edit index new update).include?(params[:action])
      'application_v2'
    else
      'application'
    end
  end

  def can_comment? user, lesson
    if lesson.can_comment? user
      true
    elsif !user
      store_location new_lesson_lesson_comment_path(@lesson)
      flash[:error] = t('lesson.must_logon_to_comment')
      redirect_to new_user_session_url
      false
    else
      flash[:error] = t('lesson.must_own')
      redirect_to lesson_path(@lesson, :anchor => :lesson_comment)
      false
    end
  end
end