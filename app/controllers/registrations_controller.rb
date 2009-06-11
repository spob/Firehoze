class RegistrationsController < ApplicationController
  def new
    @registration = Registration.new
  end

  def create
    @registration = Registration.new(params[:registration])
    @registration.send_email = true
    if @registration.save
      flash[:notice] = "Please check your email to complete the registration."
      redirect_to root_path 
    else
      #@registration.errors.each { |attr,msg| puts "#{attr} - #{msg}" }
      render :action => "new"
    end
  end  
end
