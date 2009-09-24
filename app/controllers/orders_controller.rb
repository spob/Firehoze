class OrdersController < ApplicationController
  include SslRequirement

  before_filter :require_user
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
    @search = Order.cart_purchased_at_not_null.descend_by_id.search(params[:search])
    @orders = @search.paginate(:page => params[:page], :per_page => (session[:per_page] || ROWS_PER_PAGE)) 
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
    unless @order.user == current_user or current_user.is_admin?
      flash[:error] = t("order.no_access")
      redirect_to home_path
    end
  end

  private
  
  def layout_for_action
    %w(index).include?(params[:action]) || (params[:action] == 'show' and current_user.is_admin?) ? 'admin' : 'application'
  end
end
