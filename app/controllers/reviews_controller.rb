# This controller is a nested resource. It will generally be invoked from the lesson controller
class ReviewsController < ApplicationController
  before_filter :require_user, :except => [:index]
  # Since this controller is nested, in most cases we'll need to retrieve the lesson first, so I made it a
  # before filter
  before_filter :find_lesson, :except => [ :edit, :update, :destroy ]
  before_filter :find_review, :only => [ :edit, :update ]


  permit Constants::ROLE_MODERATOR, :only => [:edit, :update]

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path
  verify :method => :destroy, :only => [:delete ], :redirect_to => :home_path

  def index
    @reviews = Review.list @lesson, params[:page]
  end

  def new
    @review = @lesson.reviews.build
    # A user can only write a review for a lesson once
    if @lesson.reviewed_by? current_user
      flash[:error] = t 'review.already_reviewed'
      redirect_to lesson_reviews_path(@lesson)
    elsif !current_user.owns_lesson? @lesson
      flash[:error] = t 'review.must_view_to_review'
    elsif @lesson.instructor == current_user
      flash[:error] = t 'review.cannot_review_own_lesson'
      redirect_to lesson_reviews_path(@lesson)
    end
  end

  def create
    @review = @lesson.reviews.build(params[:review])
    @review.user = current_user
    if @review.save
      flash[:notice] = t 'review.create_success'
      redirect_to lesson_reviews_path(@lesson)
    else
      render :action => 'new'
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
      redirect_to lesson_reviews_url(@review.lesson)
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
  
end
