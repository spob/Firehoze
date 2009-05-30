class LineItemsController < ApplicationController
  before_filter :require_user

  # TODO: consolidate line items
  # TODO: Add delete
  def create
    @sku = Sku.find(params[:sku_id])
    @line_item = LineItem.create!(:cart => current_cart, :sku => @sku, :quantity => 1, :unit_price => @sku.price)
    flash[:notice] = "Added #{@sku.description} to cart."
    redirect_to current_cart_url
  end
end
