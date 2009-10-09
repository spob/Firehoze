class StoreController < ApplicationController
  include SslRequirement

  before_filter :require_user

  def show
    if params[:id] and params[:id].to_i > 0
      session[:lesson_to_buy] = params[:id]
    else
      session[:lesson_to_buy] = nil
    end
  end
end
