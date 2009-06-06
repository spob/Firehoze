# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # Format a date and adjust the timezone for the user's timezone
  # TODO: make i18n compatible
  def format_date_time(the_date)
    the_date.strftime("%b %d, %Y %I:%M%p") if the_date
  end

  # TODO: make i18n compatible
  def format_date(the_date)
    the_date.strftime("%b %d, %Y") if the_date
  end

  def show_cart?
    if current_user
      if session[:cart_id]
        @current_cart ||= Cart.find(session[:cart_id])
      end
    end
    @current_cart and !@current_cart.line_items.empty?
  end
end
