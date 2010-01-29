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

  def show_lesson_link
    if session[:lesson_to_buy]
      @lesson = Lesson.find(session[:lesson_to_buy])
      if current_user and !@lesson.owned_by?(current_user)
        "<div class='blue-box-pale with-icon'>#{ link_to(image_tag('icons/left_32.png', :alt => 'return'), lesson_path(@lesson)) } Return to #{link_to(@lesson.title, lesson_path(@lesson))}</div>"
      end
    end
  end
end
