class CartsController < ApplicationController
  before_filter :require_user
  
  def show
    @cart = current_cart
  end
end
