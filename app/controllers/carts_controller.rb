class CartsController < ApplicationController
  include SslRequirement
  before_filter :require_user
  layout 'application_v2'
  
  def show
    @cart = current_cart
  end
end
