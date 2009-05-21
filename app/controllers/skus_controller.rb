class SkusController < ApplicationController
  before_filter :require_user

  # Sys admins only
  permit Constants::ROLE_SYSADMIN

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path
  verify :method => :destroy, :only => [:delete ], :redirect_to => :home_path

  def index
    @skus = Sku.list params[:page]
  end

  def new
    @sku = CreditSku.new
  end

  def create
    @sku = CreditSku.new(params[:sku])
    set_description @sku
    if @sku.save
      flash[:notice] = "SKU saved"
      redirect_to skus_path
    else
      render :action => :new
    end
  end

  def edit
    @sku = Sku.find params[:id]
  end

  def update
    @sku = Sku.find params[:id]
    @sku.attributes = params[:sku]
    set_description @sku
    if @sku.save
      flash[:notice] = "SKU updated!"
      redirect_to skus_path
    else
      render :action => :edit
    end
  end

  def destroy
    sku = Sku.find params[:id]
    name = sku.sku
    sku.destroy
    flash[:notice] = "SKU #{name} was successfully deleted."
    redirect_to skus_url
  end

  private

  def set_description sku
    sku.description = "#{help.pluralize sku.num_credits, 'credit'} for #{help.number_to_currency sku.price}"
  end
end
