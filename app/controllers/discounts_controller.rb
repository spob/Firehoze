# This controller is a nested resource. It will always be invoked from the sku controller
class DiscountsController < ApplicationController
  before_filter :require_user
  # Since this controller is nested, in most cases we'll need to retrieve the sku first, so I made it a
  # before filter
  before_filter :retrieve_sku, :except => [ :edit, :update, :destroy ]

  # Sys admins only
  permit ROLE_SYSADMIN

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path
  verify :method => :destroy, :only => [:delete ], :redirect_to => :home_path
  
  def index
    @discounts = Discount.list @sku, params[:page]
  end
  
  #def show
  #  @discount = sku.discounts.find(params[:id])
  #end
  
  def new
    @discount = @sku.discounts.build
  end
  
  def create
    # dynamically execute the new command based upon the type of sku selected...since eventually the user
    # will be able to create multiple different kinds of skus via the UI
    command = "#{params[:discount][:type]}.new(params[:discount])"
    #    print command
    @discount = eval command
    @sku.discounts << @discount 
#    @discount = @sku.discounts.build(params[:discount])
    if @sku.save
      flash[:notice] = t 'discount.create_success'
      redirect_to sku_discounts_path(@sku)
    else
      render :action => 'new'
    end
  end
  
  def edit
    @discount = Discount.find(params[:id])
  end
  
  def update
    @discount = Discount.find(params[:id])
    if @discount.update_attributes(params[:discount])
      flash[:notice] = t 'discount.update_success'
      redirect_to sku_discounts_url(@discount.sku)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @discount = Discount.find(params[:id])
    @discount.destroy
    flash[:notice] = t 'discount.destroyed_success'
      redirect_to sku_discounts_path(@discount.sku)
  end

  private

  # Called by thebefore filter to retrieve the sku based on the sku_id that
  # was passed in as a parameter
  def retrieve_sku
    @sku = Sku.find(params[:sku_id])
  end
end
