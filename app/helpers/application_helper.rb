# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def show_cart?
    if current_user
      if session[:cart_id]
        begin
          @current_cart ||= Cart.find(session[:cart_id])
        rescue ActiveRecord::RecordNotFound
          @current_cart = nil
          session[:cart_id] = nil
        end
      end
      @current_cart and @current_cart.line_items.present?
    end
  end

  def set_focus_to_id(id, othertxt=nil)
    javascript_tag("$('#{id}').focus()");
  end
end
