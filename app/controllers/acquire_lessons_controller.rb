# This controller manages the process of a user applying a credit to watch a lesson
class AcquireLessonsController < ApplicationController
  before_filter :require_user

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path

  # Show the user a confirmation screen asking them if they'd like to apply a credit to watch this video
  def new
    @lesson = Lesson.find params[:id]
  end

  # Consume an available credit to watch this lesson 
  def create
    @lesson = Lesson.find params[:id]
    if current_user.available_credits.empty?
      # no free creates
      flash[:error] = t('lesson.need_credits')
      redirect_to store_path(1)
    else
      @credit = current_user.available_credits.first
      @credit.update_attributes(:lesson => @lesson, :acquired_at => Time.now)
      redirect_to watch_lesson_path(@lesson)
    end
  end
end
