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
    # process bold and italics
    text = text.gsub(/(^.+)\*(.+)\*/, '\1<b>\2</b>').gsub(/_(.+)_/, '<i>\1</i>')
    # and unordered lists
    text = text.gsub(/^\*\s(.*)$/, '<ul><li>\1</li></ul>').gsub(/<\/ul>\s*<ul>/, "\n")
    # and ordered lists
    text = text.gsub(/^#\s(.*)$/, '<ol><li>\1</li></ol>').gsub(/<\/ol>\s*<ol>/, "\n")
    text = auto_link(simple_format(text))
    text = text.gsub(/^<br\s*\/><ul>/, "<ul>").gsub(/^<br\s*\/><ol>/, "<ol>").gsub(/^<br\s*\/><li>/, "<li>")
    text = text.gsub(/<\/ul>\s*<br\s*\/>/, "</ul>").gsub(/<\/ol>\s*<br\s*\/>/, "</ol>").gsub(/^<br\s*\/><\/li>/, "</li>")
    text
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

  def flag_link flaggable
    msg = nil
    if current_user
      flags = current_user.get_flags(flaggable)
      unless flags.empty?
        if flags.collect(&:status).include? FLAG_STATUS_REJECTED
          msg = t 'flag.user_flagging_reject'
        elsif flags.collect(&:status).include? FLAG_STATUS_PENDING
          msg = t 'flag.user_flagging_pending'
        end
      end
    end
    if msg.nil?
      link_to "Flag", new_flag_path(:flagger_type => flaggable.class.to_s, :flagger_id => flaggable)
    else
      msg
    end
  end

  def per_page_select refresh_url
    link_to_command(10, refresh_url) +
            link_to_command(25, refresh_url) +
            link_to_command(50, refresh_url) +
            link_to_command(100, refresh_url, false)
  end

  private

  def link_to_command per_page, refresh_url, append_space=true
    if session[:per_page] == per_page.to_s
      "#{per_page}#{append_space ? "&nbsp;" : ""}"
    else
      link_to(per_page, set_per_pages_path(:per_page => per_page, :refresh_url => refresh_url), :method => :post) +
              (append_space ? "&nbsp;" : "")
    end
  end
end
