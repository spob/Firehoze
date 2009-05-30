class OrdersController < ApplicationController
  def new
    @order = Order.new
  end
  
  def create
    @order = Order.new(params[:order])
    if @order.save
      flash[:notice] = "Successfully created order."
      redirect_to root_url
    else
      render :action => 'new'
    end
  end
end
