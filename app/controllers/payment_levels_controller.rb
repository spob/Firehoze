class PaymentLevelsController < ApplicationController
  include SslRequirement
  
  before_filter :require_user
  before_filter :find_payment_level, :only => [ :edit, :update, :destroy ]

  # Admins only
  permit ROLE_ADMIN

  layout 'admin'

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path

  def index
    @payment_levels = PaymentLevel.order("name ASC").paginate(:page => params[:page],
                                                           :per_page => cookies[:per_page] || ROWS_PER_PAGE)
  end

  def new
    @payment_level = PaymentLevel.new
  end

  def create
    @payment_level =  PaymentLevel.new(params[:payment_level])
    if @payment_level.save
      flash[:notice] = t 'payment_level.create_success'
      redirect_to payment_levels_path
    else
      render :action => :new
    end
  end

  def edit
  end

  def update
    @payment_level.attributes = params[:payment_level]
    if @payment_level.save
      flash[:notice] = t 'payment_level.update_success'
      redirect_to payment_levels_path
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

  private

  def find_payment_level
    @payment_level = PaymentLevel.find params[:id]
  end
end
