# This controller is a nested resource. It will generally be invoked from the lesson controller
class ReviewsController < ApplicationController
  include SslRequirement

  if APP_CONFIG[CONFIG_ALLOW_UNRECOGNIZED_ACCESS]
    before_filter :require_user, :except => [:index]
  else
    before_filter :require_user
  end
  # Since this controller is nested, in most cases we'll need to retrieve the lesson first, so I made it a
  # before filter
  before_filter :find_lesson, :except => [ :edit, :update, :show, :ajaxed ]
  before_filter :find_review, :only => [ :edit, :update, :show ]
  before_filter :set_per_page, :only => [ :ajaxed, :index ]


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

  def show
    if @review.status == REVIEW_STATUS_ACTIVE or (current_user and current_user.is_moderator?)
      # view the review
    else
      flash[:error] = t 'review.not_ready'
      redirect_to lesson_path(@review.lesson)
    end
  end

  def new
    @review = @lesson.reviews.build
    # A user can only write a review for a lesson once
    if @lesson.reviewed_by? current_user
      flash[:error] = t 'review.already_reviewed'
      redirect_to lesson_reviews_path(@lesson)
    elsif !current_user.owns_lesson? @lesson
      flash[:error] = t 'review.must_view_to_review'
      redirect_to lesson_reviews_path(@lesson)
    elsif @lesson.instructor == current_user
      flash[:error] = t 'review.cannot_review_own_lesson'
      redirect_to lesson_reviews_path(@lesson)
    end
  end

  def create
    @review = @lesson.reviews.build(params[:review])
    @review.user = current_user

    respond_to do |format|
      format.html do
        if @review.save
          flash[:notice] = t 'review.create_success'
          redirect_to lesson_reviews_path(@lesson)
        else
          flash[:error] = t 'review.create_failure'
          render :action => 'new'
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
      redirect_to lesson_reviews_path(@lesson)
    end
  end

  def update
    if @review.update_attributes(params[:review])
      flash[:notice] = t 'review.update_success'
      redirect_to review_path(@review)
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
end