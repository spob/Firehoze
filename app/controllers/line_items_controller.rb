class LineItemsController < ApplicationController
  before_filter :require_user

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  # TODO: Add delete

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
        # TODO: pass in the real discounted price

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
end
