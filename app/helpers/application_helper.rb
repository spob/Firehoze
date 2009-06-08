# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def show_cart?
    if current_user
      if session[:cart_id]
        @current_cart ||= Cart.find(session[:cart_id])
      end
    end
    @current_cart and @current_cart.present?
  end
end
