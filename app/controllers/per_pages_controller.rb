class PerPagesController < ApplicationController
  include SslRequirement
  
  verify :method => :post, :only => [:set ], :redirect_to => :home_path

  def set
    cookies[:per_page] = { :value => params[:per_page], :expires => 1.year.from_now }
    flash[:notice] = t 'per_page.per_page_updated', :per_page => cookies[:per_page]
    redirect_to params[:refresh_url]
  end
end
