class LineItemsController < ApplicationController
  before_filter :require_user

  # TODO: consolidate line items
  # TODO: Add delete

  def create
    @sku = Sku.find(params[:sku_id])
    quantity = params[:quantity].to_i

    # First check if this sku is already in the user's shopping cart.
    @line_item = LineItem.by_cart(current_cart).by_sku(@sku).first
    if @line_item
      #  If so, increase that quantity
      @line_item.quantity += quantity
      @line_item.save!
    else
      # else create a new line item for that sku
      @line_item = LineItem.create!(:cart => current_cart, :sku => @sku, :quantity => quantity, :unit_price => @sku.price)
    end
    current_cart.save!
    flash[:notice] = "Added #{@sku.description} to cart."
    redirect_to current_cart_url
  end
end
