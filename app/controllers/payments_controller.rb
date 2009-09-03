class PaymentsController < ApplicationController
  before_filter :require_user

  # Admins only
  permit ROLE_ADMIN, :except => 'show'

  layout 'admin'

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  #verify :method => :put, :only => [:update ], :redirect_to => :home_path
  #verify :method => :destroy, :only => [:delete ], :redirect_to => :home_path

  def index
    @users = User.instructors.sort_by{|user| user.unpaid_credits_amount * -1}.paginate :page => params[:page],
                                                                                       :per_page => (session[:per_page] || ROWS_PER_PAGE)
  end

  def list
    @user = User.find(params[:id])
    @payments = @user.payments.paginate :page => params[:page],
                                        :per_page => (session[:per_page] || ROWS_PER_PAGE)
  end

  def show
    @payment = Payment.find(params[:id])
    unless current_user.is_admin? or current_user == @payment.user
      flash[:error] = t 'payment.cannot_view'
      redirect_to home_path
    end
  end

  def show_unpaid
    @user = User.find(params[:id])
    unless current_user.is_admin? or current_user == @user
      flash[:error] = t 'payment.cannot_view'
      redirect_to home_path
    end
  end

  def create
    @user = User.find(params[:id])
    Payment.transaction do
      @payment = @user.generate_payment
      if @payment.save
        flash[:notice] = t 'payment.create_success'
        redirect_to payment_path(@payment)
      else
        redirect_to payments_path
      end
    end
  end
end
