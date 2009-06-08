class LineItemsController < ApplicationController
  before_filter :require_user

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path
  verify :method => :destroy, :only => [:delete ], :redirect_to => :home_path

  def create
    @sku = Sku.find(params[:sku_id])
    quantity = params[:quantity].to_i

    LineItem.transaction do
      # First check if this sku is already in the user's shopping cart.
      @line_item = LineItem.by_cart(current_cart).by_sku(@sku).first
      if @line_item
        #  If so, increase that quantity
        @line_item.quantity += quantity
        @line_item.save!
      else
        # else create a new line item for that sku

        # This should never fail. If it does, something is seriously wrong so go ahead
        # and throw an exception
        @line_item = LineItem.create!(:cart => current_cart, :sku => @sku, :quantity => quantity,
                                      :unit_price => @sku.price)
      end
      # This should never fail. If it does, something is seriously wrong so go ahead
      # and throw an exception
      current_cart.save!
    end
    flash[:notice] = "Added #{@sku.description} to cart."
    redirect_to current_cart_url
  end

  #def update
  #  @line_item = LineItem.find(params[:id])
  #  if params[:line_item][:quantity].to_i == 0
  #    destroy
  #  else
  #    if @line_item.update_attribute(:quantity, params[:discount][:quantity])
  #      flash[:notice] = "Updated line item."
  #    end
  #    redirect_to current_cart_url
  #  end
  #end

  def destroy
    line_item = LineItem.find params[:id]
    sku = line_item.sku.sku
    line_item.destroy
    flash[:notice] = "SKU #{sku} was successfully removed from the cart."
    redirect_to current_cart_url
  end
end
