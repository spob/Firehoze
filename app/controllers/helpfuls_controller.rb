class HelpfulsController < ApplicationController
  before_filter :require_user

  verify :method => :post, :only => [:create ], :redirect_to => :home_path

  def create
    @review = Review.find(params[:review_id])
    if @review.lesson.instructor == current_user
      flash[:error] = t 'helpful.cant_helpful_as_instructor'
    elsif @review.helpfuls.create(:user => current_user, :helpful => (params[:helpful] == 'yes'))
      flash[:notice] = t 'helpful.create_success'
    end
    redirect_to lesson_reviews_path(@review.lesson)
  end
end