# This class interactions with the authlogic gem to acutally control logging in and logging out
class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :delete, :only => [ :destroy ], :redirect_to => :home_path
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = t 'login.login_success'
      redirect_back_or_default home_path
    else
      render :action => :new
    end
  end
  
  def destroy
    current_user_session.destroy
    flash[:notice] = t 'login.logout_success'
    redirect_back_or_default home_path
  end
end
