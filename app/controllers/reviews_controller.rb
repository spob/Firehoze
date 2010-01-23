# This controller is a nested resource. It will generally be invoked from the lesson controller
class ReviewsController < ApplicationController
  include SslRequirement

  if APP_CONFIG[CONFIG_ALLOW_UNRECOGNIZED_ACCESS]
    before_filter :require_user, :except => [:index, :new]
  else
    before_filter :require_user
  end
  # Since this controller is nested, in most cases we'll need to retrieve the lesson first, so I made it a
  # before filter
  before_filter :find_lesson, :except => [ :edit, :update, :ajaxed ]
  before_filter :find_review, :only => [ :edit, :update ]
  before_filter :set_per_page, :only => [ :ajaxed, :index ]

  layout :layout_for_action


  permit ROLE_MODERATOR, :only => [:edit, :update]

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path
  #verify :method => :destroy, :only => [:delete ], :redirect_to => :home_path

  def index
    @reviews = Review.list @lesson, params[:page], current_user, @per_page
    @style = params[:style]
    render :layout => 'content_in_tab' if @style == 'tab'
  end

  # SUPPORTING AJAX PAGINATION
  def ajaxed
    @collection = params[:collection]
    @reviews =
            case @collection
              when 'by_author'
                Review.list(nil, @per_page, current_user, params[:page])
            end
  end

#  def show
#    if @review.status == REVIEW_STATUS_ACTIVE or (current_user and current_user.is_moderator?)
#      # view the review
#    else
#      flash[:error] = t 'review.not_ready'
#      redirect_to lesson_path(@review.lesson)
#    end
#  end

  def new
    @review = @lesson.reviews.build
    # A user can only write a review for a lesson once
    can_review? @lesson
  end

  def create
    @review = @lesson.reviews.build(params[:review])
    @review.user = current_user

    respond_to do |format|
      format.html do
        if can_review? @lesson
          if @review.save
            flash[:notice] = t 'review.create_success'
            redirect_to lesson_path(@lesson, :anchor => 'reviews')
          else
            flash[:error] = t 'review.create_failure'
            render :action => 'new'
          end
        end
      end
      format.js do
        if @review.save
          flash[:notice] = t 'review.create_success'
        else
          flash[:error] = t 'review.create_failure'
        end
      end
    end
  end

  def edit
    unless @review.can_edit? current_user
      flash[:error] = t 'review.cannot_edit'
      redirect_to lesson_path(@lesson, :anchor => 'reviews')
    end
  end

  def update
    if @review.update_attributes(params[:review])
      flash[:notice] = t 'review.update_success'
      redirect_to lesson_path(@lesson, :anchor => 'reviews')
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

  def find_review
    @review = Review.find(params[:id])
  end

  def set_per_page
    @per_page =
            if params[:per_page]
              params[:per_page]
            else
              5
            end
  end

  def layout_for_action
    if %w(list_admin).include?(params[:action])
      'admin'
    elsif %w(index edit update new create).include?(params[:action])
      'application_v2'
    else
      'application'
    end
  end

  def can_review? lesson
    return true if lesson.can_review? current_user
    if lesson.reviewed_by? current_user
      flash[:error] = t 'review.already_reviewed'
      redirect_back_to_reviews lesson
    elsif !lesson.owned_by?(current_user)
      flash[:error] = t 'review.must_view_to_review'
      redirect_back_to_reviews lesson
    elsif lesson.instructed_by?(current_user)
      flash[:error] = t 'review.cannot_review_own_lesson'
      redirect_back_to_reviews lesson
    elsif !current_user
      store_location new_review_path(@lesson)
      flash[:error] = t('review.must_logon')
      redirect_to new_user_session_url
    end
    false
  end

  def redirect_back_to_reviews lesson
    redirect_to lesson_path(lesson, :anchor => "reviews")
  end
end