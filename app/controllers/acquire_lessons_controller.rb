# This controller manages the process of a user applying a credit to watch a lesson
class AcquireLessonsController < ApplicationController
  include SslRequirement

  before_filter :require_user
  ssl_required :create if Rails.env.production?

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
      # no available creates
      flash[:error] = t('lesson.need_credits')
      redirect_to store_path(1)
    else
      Lesson.transaction do
        @credit = current_user.available_credits.first
        @credit.update_attributes(:lesson => @lesson, :acquired_at => Time.now)
        current_user.wishes.delete(@lesson) if current_user.on_wish_list?(@lesson)
        LessonVisit.touch(@lesson, current_user, request.session.session_id, true)
      end

      redirect_to lesson_path(@lesson)
    end
  end

  # SUPPORTING AJAX PAGINATION
  def ajaxed
    @collection = params[:collection]
    @credits =
            case @collection
              when 'available'
                current_user.available_credits(:order => "created_at ASC")
              when 'used'
                current_user.credits.redeemed_at_not_null.expired_at_null(:include => [:lesson], :order => "created_at ASC")
              when 'expired'
                current_user.credits.expired_at_not_null(:order => "created_at ASC")
            end
  end
end 