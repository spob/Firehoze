class DiscountsController < ApplicationController
  before_filter :retrieve_sku
  before_filter :require_user

  # Sys admins only
  permit Constants::ROLE_SYSADMIN

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path
  verify :method => :destroy, :only => [:delete ], :redirect_to => :home_path
  
  def index
    @discounts = Discount.list @sku, params[:page]
  end
  
  def show
    @discount = sku.discounts.find(params[:id])
  end
  
  def new
    @discount = @sku.discounts.build
  end
  
  def create
    @discount = @sku.discounts.build(params[:discount])
    if @discount.save
      flash[:notice] = "Successfully created discount."
      redirect_to sku_discounts_path(@sku)
    else
      render :action => 'new'
    end
  end
  
  def edit
    @discount = @sku.discounts.find(params[:id])
  end
  
  def update
    @discount = @sku.discounts.find(params[:id])
    if @discount.update_attributes(params[:discount])
      flash[:notice] = "Successfully updated discount."
      redirect_to sku_discounts_url(@sku)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @discount = Discount.find(params[:id])
    @discount.destroy
    flash[:notice] = "Successfully destroyed discount."
      redirect_to sku_discounts_path(@sku)
  end

  private

  def retrieve_sku
    @sku = Sku.find(params[:sku_id])
  end
end
