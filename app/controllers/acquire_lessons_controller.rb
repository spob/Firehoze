# This controller manages the process of a user applying a credit to watch a lesson
class AcquireLessonsController < ApplicationController
  include SslRequirement

  before_filter :require_user, :except => [:ajaxed ]
  before_filter :set_per_page, :only => [ :ajaxed ]
  before_filter :find_lesson
  ssl_required :create if Rails.env.production?

  verify :method => :post, :only => [:create ], :redirect_to => :home_path

  # Show the user a confirmation screen asking them if they'd like to apply a credit to watch this video
  def new
  end

  # Consume an available credit to watch this lesson 
  def create
    @credit = @lesson.acquire(current_user, request.session_options[:id])
    if @credit
      redirect_to lesson_path(@lesson)
    else
      # no available creates
      flash[:error] = t('lesson.need_credits')
      redirect_to store_path(1)
    end
  end

  # SUPPORTING AJAX PAGINATION
  def ajaxed
    @collection = params[:collection]
    @credits =
            case @collection
              when 'available'
                current_user.available_credits(:order => "created_at ASC").paginate(:per_page => @per_page, :page => params[:page])
              when 'used'
                current_user.credits.where("redeemed_at IS NOT NULL AND expired_at IS NOT NULL").joins(:lesson).order("created_at ASC").paginate(:per_page => @per_page, :page => params[:page])
              when 'expired'
                current_user.credits.where("expired_at IS NOT NULL").order("created_at ASC").paginate(:per_page => @per_page, :page => params[:page])
            end
  end

  private

  def set_per_page
    @per_page =
            if params[:per_page]
              params[:per_page]
            else
              5
            end
  end

  def find_lesson
    @lesson = Lesson.find params[:id]
  end
end