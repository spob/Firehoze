module OrdersHelper
  include ApplicationHelper
  
  def order_formatted_address order, newline_character = "\n"
    std_formatted_address(order.address1,
                          order.address2,
                          order.city,
                          order.state,
                          order.zip,
                          order.country,
                          newline_character)
  end
end
