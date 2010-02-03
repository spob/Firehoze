class CartsController < ApplicationController
  include SslRequirement
  before_filter :require_user
  
  def show
    @cart = current_cart
  end
end
