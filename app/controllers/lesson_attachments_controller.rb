class LessonAttachmentsController < ApplicationController
  include SslRequirement

  before_filter :require_user
  before_filter :find_lesson, :except => [ :edit, :update, :destroy ]
  before_filter :find_attachment, :except => [:create, :new]

  verify :method => :post, :only => [ :create ], :redirect_to => :home_path
  verify :method => :put, :only => [ :update ], :redirect_to => :home_path
  verify :method => :delete, :only => [:destroy ], :redirect_to => :home_path

  def create
    @lesson = Lesson.find(params[:lesson_id])
    if has_access? @lesson
      @attachment = LessonAttachment.new( params[:attachment] )
      @attachment.lesson = @lesson
      if @attachment.save
        flash[:notice] = t 'attachment.create_success'
        redirect_to lesson_path(@lesson)
      else
        render :action => 'new'
      end
    end
  end

  def destroy
    if has_access? @attachment.lesson
      @lesson = @attachment.lesson
      name = @attachment.title
      @attachment.destroy
      flash[:notice] = t 'attachment.delete_success', :name => name
      redirect_to lesson_path(@lesson)
    end
  end

  def new
    has_access? @lesson
  end

  def edit
    has_access? @attachment.lesson
  end

  def update
    if has_access? @attachment.lesson
      if @attachment.update_attributes(params[:attachment])
        flash[:notice] = t 'attachment.update_success'
        redirect_to lesson_path(@attachment.lesson)
      else
        render :action => 'edit'
      end
    end
  end

  private

  def has_access? lesson
    if lesson.can_edit? current_user
      return true
    else
      flash[:error] = t 'attachment.access_message'
      redirect_to lesson_path(@attachment.lesson)
      return false
    end
  end

  # Called by the before filter to retrieve the lesson based on the lesson_id that
  # was passed in as a parameter
  def find_lesson
    @lesson = Lesson.find(params[:lesson_id])
  end

  def find_attachment
    @attachment = LessonAttachment.find(params[:id])
  end
end
