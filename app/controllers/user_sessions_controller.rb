# This class interactions with the authlogic gem to acutally control logging in and logging out
class UserSessionsController < ApplicationController
  include SslRequirement

  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  ssl_required :create if Rails.env.production?

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :delete, :only => [ :destroy ], :redirect_to => :home_path

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      redirect_back_or_default myfirehoze_path
    else
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = t 'login.logout_success'
    if APP_CONFIG[CONFIG_ALLOW_UNRECOGNIZED_ACCESS]
      redirect_to root_path
    else
      redirect_to login_path
    end
  end
end
