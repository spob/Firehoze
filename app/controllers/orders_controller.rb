class OrdersController < ApplicationController
  before_filter :require_user

  verify :method => :post, :only => [:create ], :redirect_to => :home_path

  def new
    # Create a new order object, defaulting information as appropriate based upon
    # the user who is currently logged in
    @order = Order.new(:first_name => current_user.first_name,
                       :last_name => current_user.last_name,
                       :billing_name => current_user.full_name,
                       :country => 'US')
  end

  def create
    @order = current_cart.build_order(params[:order])
    @order.ip_address = request.remote_ip
    @order.user = current_user
    # Saving the order will charge the credit card itself using the ActiveMerchant plugin. If this succeeds,
    # the credit card was charged.
    if @order.save
      if @order.purchase
        redirect_to order_path(@order)
      else
        # todo: create a better screen to tell the user something failed
        render :action => 'failure'
      end
    else
      render :action => 'edit'
    end
  end
  
  def show
    @order = Order.find(params[:id])
  end
end
