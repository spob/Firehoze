# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include TagsHelper

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

  def strike_through(text, condition)
    return "<strike>#{text}</strike>" if condition
    text
  end

  def italics(text, condition)
    return "<i>#{text}</i>" if condition
    text
  end

  def rbs_formatter(text)
    return text if text.blank?
    text = text.gsub(/^\*\s(.*)$/, '<ul><li>\1</li></ul>').gsub(/<\/ul>\s*<ul>/, "\n")
    text = text.gsub(/^#\s(.*)$/, '<ol><li>\1</li></ol>').gsub(/<\/ol>\s*<ol>/, "\n")
    text.gsub(/^<br\s*\/><ul>/, "<ul>").gsub(/^<br\s*\/><ol>/, "<ol>").gsub(/^<br\s*\/><li>/, "<li>")
    auto_link(simple_format(text))
  end

  # Set field focus. For an explanation, see:
  # http://neoarch.wordpress.com/2008/02/29/setting-focus-in-rails-with-prototype/
  def set_focus_to_id(id, othertxt=nil)
    javascript_tag("$('#{id}').focus()");
  end

  def language_value(key)
    LANGUAGES.rassoc(key).first
  end

  def link_to_profile(user, options=[])
    if options.include?("full_name")
      link_to_unless_current user.name_or_username, user_path(user)
    else
      link_to_unless_current user.username_or_name, user_path(user)
    end
  end
end
