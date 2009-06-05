class OrdersController < ApplicationController
  before_filter :require_user
  
  verify :method => :post, :only => [:create ], :redirect_to => :home_path

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
