# Controller to allow the user to reset their password if they've forgotten their password
class PasswordResetsController < ApplicationController
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]
  before_filter :require_no_user

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :put, :only => [ :update ], :redirect_to => :home_path

  # This action will render the page allowing the user to enter an email address to request a new password
  def new
    render
  end

  # Allow the user to request a new password based upon an email address they enter
  def create
    @user = User.find_by_email(params[:email])
    if @user
      # Send them a url to click on to request a new password. Note that no database updates are made until the
      # user clicks the URL...that way, one user cannot maliciously or accidently mess up another user's password
      # by requesting a new password.
      @user.deliver_password_reset_instructions!
      flash[:notice] = "Instructions to reset your password have been emailed to you. " +
              "Please check your email."
      redirect_to root_url
    else
      flash[:notice] = "No user was found with that email address"
      render :action => :new
    end
  end

  # This action will be shown when the user has clicked on the link in the URL. From this screen they can then
  # set a new password
  def edit
    render
  end

  # Now, finally, the user has entered a new password...update their account accordingly.
  def update
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      flash[:notice] = "Password successfully updated"
      redirect_to account_url
    else
      render :action => :edit
    end
  end

  private

  # This perishable token is created by authlogic plugin to track a onetime authorization request. It's used
  # in this case to control that the user is authorized to change this user's password (becuase he/she clicked
  # on the link in the email)
  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      flash[:notice] = "We're sorry, but we could not locate your account. " +
              "If you are having issues try copying and pasting the URL " +
              "from your email into your browser or restarting the " +
              "reset password process."
      redirect_to root_url
    end
  end
end
