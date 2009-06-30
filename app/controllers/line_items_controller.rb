class LineItemsController < ApplicationController
  before_filter :require_user

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path
  verify :method => :destroy, :only => [:delete ], :redirect_to => :home_path

  # Add an item to the shopping cart
  def create
    # When adding an item to the cart, the onl items passed in are the sku_id and the quantity
    @sku = Sku.find_by_sku!(params[:sku])
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
    flash[:notice] = t 'line_item.created_added_sku',
                       :sku_desc => help.pluralize(quantity, @sku.description)
    redirect_to current_cart_url
  end

  def update
    # When adding an item to the cart, the onl items passed in are the sku_id and the quantity to increment or
    # decrement the line quantity (e.g., -1 to reduce the quantity by one
    @line_item = LineItem.find(params[:id])
    delta = params[:qty_change].to_i
    @line_item.quantity = @line_item.quantity + delta

    if @line_item.quantity < APP_CONFIG[CONFIG_MIN_CREDIT_PURCHASE]
      # there's a minimum number of credits you can purchase at any one time. We don't want to get
      # nickeled and dimed with purchases of 1 credti at a time
      # TODO: Make credit i18n below
      flash[:error] = t('line_item.minimum_credit_purchase',
                        :min => help.pluralize(APP_CONFIG[CONFIG_MIN_CREDIT_PURCHASE].to_i,
                                               'credit'))
    elsif @line_item.save
      flash[:notice] = t 'line_item.updated_success'
    else
      flash[:error] = t 'line_item.updated_failure'
    end
    redirect_to current_cart_url
  end

  def destroy
    line_item = LineItem.find params[:id]
    sku = line_item.sku.sku
    line_item.destroy
    flash[:notice] = t 'line_item.remove_sku_success', :sku => sku
    redirect_to current_cart_url
  end
end
