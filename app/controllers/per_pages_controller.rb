class PerPagesController < ApplicationController
  include SslRequirement
  
  verify :method => :post, :only => [:set ], :redirect_to => :home_path

  def set
    session[:per_page] = params[:per_page]
    flash[:notice] = t 'per_page.per_page_updated', :per_page => session[:per_page]
    redirect_to params[:refresh_url]
  end
end
