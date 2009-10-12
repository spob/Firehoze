class LessonAttachmentsController < ApplicationController
  include SslRequirement

  before_filter :require_user
  before_filter :find_lesson, :except => [ :edit, :update, :destroy ]

  verify :method => :post, :only => [ :create ], :redirect_to => :home_path
  verify :method => :put, :only => [ :update ], :redirect_to => :home_path
  verify :method => :delete, :only => [:destroy ], :redirect_to => :home_path

  def create
    @lesson = Lesson.find(params[:lesson_id])
    @attachment = LessonAttachment.new( params[:attachment] )
    @attachment.lesson = @lesson
    if @attachment.save!
      flash[:notice] = t 'attachment.create_success'
      redirect_to lesson_path(@lesson)
    else
      render :action => 'new'
    end
  end

  def destroy
    @attachment = LessonAttachment.find(params[:id])
    @lesson = @attachment.lesson
    name = @attachment.title
    @attachment.destroy
    flash[:notice] = t 'attachment.delete_success', :name => name
    redirect_to lesson_path(@lesson)
  end

  def new

  end

  def edit

  end

  def update

  end

  private

  # Called by the before filter to retrieve the lesson based on the lesson_id that
  # was passed in as a parameter
  def find_lesson
    @lesson = Lesson.find(params[:lesson_id])
  end
end
