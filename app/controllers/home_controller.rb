class HomeController < ApplicationController
  include SslRequirement

  before_filter :require_user

  before_filter :set_per_page, :only => [ :show ]

  def show
    redirect_to my_firehoze_index_path
  end

  private

  def set_per_page
    @per_page = %w(show).include?(params[:action]) ? 5 : Lesson.per_page
  end
end
