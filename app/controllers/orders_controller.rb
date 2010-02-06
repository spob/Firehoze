class OrdersController < ApplicationController
  include SslRequirement

  before_filter :require_user
  before_filter :set_no_uniform_js
  layout :layout_for_action

  permit "#{ROLE_ADMIN} or #{ROLE_PAYMENT_MGR}", :only => [ :index ]

  ssl_required :new, :show, :create, :update if Rails.env.production?

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path

  def new
    # Does an order already exist (which implies that they tried to submit it at least once before
    # but it failed
    @order = current_cart.order

    # No...so go ahead and create a new order object, defaulting information as appropriate based upon
    # the user who is currently logged in
    @order ||= Order.new(:first_name => current_user.first_name,
                         :last_name => current_user.last_name,
                         :billing_name => current_user.full_name,
                         :address1 => current_user.address1,
                         :address2 => current_user.address2,
                         :city => current_user.city,
                         :state => current_user.state,
                         :zip => current_user.postal_code,
                         :country => current_user.country || 'US')
  end

  def index
    session[:lesson_to_buy] = nil
    @search = Order.cart_purchased_at_not_null.descend_by_id.search(params[:search])
    @orders = @search.paginate(:page => params[:page], :per_page => (cookies[:per_page] || ROWS_PER_PAGE))
  end

  def create
    Order.transaction do
      if current_cart.order
        # Order was created in a previous attempt that failed
        @order = current_cart.order
        @order.update_attributes(params[:order])
      else
        # else build a new order
        @order = current_cart.build_order(params[:order])
      end
      @order.ip_address = request.remote_ip
      @order.user = current_user

      if params[:default_address]
        user = User.find(current_user.id)
        user.address1 = @order.address1
        user.address2 = @order.address2
        user.city = @order.city
        user.state = @order.state
        user.country = @order.country
        user.postal_code = @order.zip

        # Note this isn't really required for now because form doesn't allow you to select
        # default address option is already verified...but added logic just in case we
        # loosen this in the future
        if user.address1_changed? or user.address2_changed? or user.city_changed? or
                user.state_changed? or user.postal_code_changed? or user.country_changed?
          user.verified_address_on = nil
          user.instructor_status = AUTHOR_STATUS_INPROGRESS
        end
        user.save!
      end
      # Saving the order will charge the credit card itself using the ActiveMerchant plugin. If this succeeds,
      # the credit card was charged.
      if @order.save
        if @order.purchase
          @order.email_receipt
          flash[:notice] = t 'order.order_placed'
          redirect_to order_path(@order, :protocol => SECURE_PROTOCOL)
        else
          flash[:error] = @order.last_transaction.first.message
          render :action => 'new'
        end
      else
        render :action => 'new'
      end
    end
  end

  def update
    create
  end

  def show
    @order = Order.find(params[:id])
    unless @order.user == current_user or current_user.is_an_admin?
      flash[:error] = t("order.no_access")
      redirect_to home_path
    end
  end

  private

# disable the uniform plugin, otherwise the advanced search form is all @$@!# up
  def set_no_uniform_js
    if %w(new create).include?(params[:action])
      @no_uniform_js = true
    end
  end

  def layout_for_action
    if %w(index).include?(params[:action]) || (params[:action] == 'show' and current_user.is_an_admin?)
      'admin'
    else
      'application'
    end
  end
end
