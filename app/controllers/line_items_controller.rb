class LineItemsController < ApplicationController
  before_filter :require_user

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path
  verify :method => :destroy, :only => [:delete ], :redirect_to => :home_path

  # Add an item to the shopping cart
  def create
    # When adding an item to the cart, the onl items passed in are the sku_id and the quantity
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
        @line_item = LineItem.new(:cart => current_cart, :sku => @sku, :quantity => quantity,
                                  :unit_price => @sku.price)
        @line_item.sku = @sku
        @line_item.cart = current_cart
        @line_item.unit_price = @sku.price
        @line_item.save!
      end
      # This should never fail. If it does, something is seriously wrong so go ahead
      # and throw an exception
      current_cart.save!
    end
    flash[:notice] = "Added #{@sku.description} to cart."
    redirect_to current_cart_url
  end

  def update
    # When adding an item to the cart, the onl items passed in are the sku_id and the quantity to increment or
    # decrement the line quantity (e.g., -1 to reduce the quantity by one
    @line_item = LineItem.find(params[:id])
    delta = params[:qty_change].to_i
    @line_item.quantity = @line_item.quantity + delta

    if @line_item.quantity < APP_CONFIG['min_credit_purchase']
      # there's a minimum number of credits you can purchase at any one time. We don't want to get
      # nickeled and dimed with purchases of 1 credti at a time
      flash[:error] = "You must buy at least #{APP_CONFIG['min_credit_purchase']} credits"
    elsif @line_item.save
      flash[:notice] = "Updated line item."
    else
      flash[:error] = "Line update failed"
    end
    redirect_to current_cart_url
  end

  def destroy
    line_item = LineItem.find params[:id]
    sku = line_item.sku.sku
    line_item.destroy
    flash[:notice] = "SKU #{sku} was successfully removed from the cart."
    redirect_to current_cart_url
  end
end
