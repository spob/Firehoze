class StoreController < ApplicationController
  include SslRequirement
  
  before_filter :require_user
  
  def show
  end
end
