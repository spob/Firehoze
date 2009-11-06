class MyFirehozeController < ApplicationController
  include SslRequirement

  before_filter :require_user

#  verify :method => :put, :only => [ :update ], :redirect_to => :home_path

  before_filter :set_per_page, :only => [ :show ]

  def show
    render :layout => 'application_v2'
    @user = @current_user
    if params[:reset] == "y"
      # clear category browsing
      session[:browse_category_id] = nil
    end
  end

  private

  def set_per_page
    @per_page = %w(show).include?(params[:action]) ? 5 : Lesson.per_page
  end
end
