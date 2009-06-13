class OrdersController < ApplicationController
  before_filter :require_user

  verify :method => :post, :only => [:create ], :redirect_to => :home_path

  def new
    @order = Order.new(:first_name => current_user.first_name,
                       :last_name => current_user.last_name,
                       :billing_name => current_user.full_name,
                       :country => 'US')
  end

  def create
    @order = current_cart.build_order(params[:order])
    @order.ip_address = request.remote_ip
    @order.user = current_user
    if @order.save
      if @order.purchase
        for line_item in @order.cart.line_items do
          line_item.sku.execute_order(current_user, line_item.quantity)
        end
        render :action => 'success'
      else
        render :action => 'failure'
      end
    else
      render :action => 'new'
    end
  end
end
