class SkusController < ApplicationController
  include SslRequirement
  
  before_filter :require_user

  # Admins only
  permit ROLE_ADMIN

  layout 'admin'

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path
  verify :method => :destroy, :only => [:delete ], :redirect_to => :home_path

  # These are the values displayed in the html select in the UI to define which type of SKU to create. For  now,
  # there is only one type
  @@sku_types = [ [ 'Credit', 'CreditSku'] ]

  def self.types
    @@sku_types
  end

  def index
    @skus = Sku.list params[:page], session[:per_page] || ROWS_PER_PAGE
  end

  def new
    # by default we're creating a CreditSku. May need to revisit this if and when we allow different types of
    # skus to be created.
    @sku = CreditSku.new
  end

  def create
    # dynamically execute the new command based upon the type of sku selected
    command = "#{params[:sku][:type]}.new(params[:sku])"
    #    print command
    @sku = eval command
 
    if @sku.save
      flash[:notice] = t 'sku.create_success'
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
    if @sku.save
      flash[:notice] = t 'sku.update_success'
      redirect_to skus_path
    else
      render :action => :edit
    end
  end

  def destroy
    sku = Sku.find params[:id]
    name = sku.sku
    sku.destroy
    flash[:notice] = t 'sku.delete_success', :name => name
    redirect_to skus_url
  end
end
