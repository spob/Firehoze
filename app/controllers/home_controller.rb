class HomeController < ApplicationController
  include SslRequirement

  before_filter :require_user

#  verify :method => :put, :only => [ :update ], :redirect_to => :home_path

  before_filter :set_per_page, :only => [ :show ]

  def show
    @user = @current_user
  end

  private 

  def set_per_page
    @per_page = %w(show).include?(params[:action]) ? 5 : Lesson.per_page
  end

end
