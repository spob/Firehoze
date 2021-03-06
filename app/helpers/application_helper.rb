# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include TagsHelper

  def title(page_title)
    content_for(:title) { page_title }
  end

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
    return "<em>#{text}</em>" if condition
    text
  end

  def bold(text, condition)
    return "<strong>#{text}</strong>" if condition
    text
  end

  def rbs_formatter(text)
    text = h(text)
    return text if text.blank?
    # process bold and italics
    text = text.gsub(/\*(\S.+?)\*/, '<b>\1</b>').gsub(/_(.+?)_/, '<i>\1</i>')
    # and unordered lists
    text = text.gsub(/^\*\s(.*)$/, '<ul><li>\1</li></ul>').gsub(/<\/ul>\s*<ul>/, "\n")
    # and ordered lists
    text = text.gsub(/^#\s(.*)$/, '<ol><li>\1</li></ol>').gsub(/<\/ol>\s*<ol>/, "\n")
    text = auto_link(simple_format(text), :all, :target => "_blank")
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

  def link_to_profile(user, options = {})
    length = options[:length]
    name = length ? (truncate(privacy_sensitive_username(user), :length => length)) : privacy_sensitive_username(user)
    link_to_unless_current name.strip.titleize(), user_path(user)
  end

  def privacy_sensitive_username(user)
    if user
      if current_user.try("is_a_moderator?") or current_user.try("is_an_admin?") or user.try("show_real_name")
        "#{h user.full_name} (#{h user.login})"
      else
        h(user.name_or_username)
      end
    end
  end

  def user_formatted_address user, newline_character = "\n"
    std_formatted_address(user.address1,
                          user.address2,
                          user.city,
                          user.state,
                          user.postal_code,
                          user.country,
                          newline_character)
  end

  def std_formatted_address address1, address2, city, state, postal_code, country, newline_character = "\n"
    "#{h(address1)}#{newline_character}#{h(address2) + newline_character unless (address2.nil? or address2.empty?)}#{h(city)}, #{h(state)} #{h(postal_code)}#{newline_character}#{I18n.t(country, :scope => 'countries')}"
  end

  def flag_link flaggable, show_msg=true
    msg = flag_msg flaggable
    if msg.nil?
      link_to content_tag(:span, "Flag"), new_flag_path(:flagger_type => flaggable.class.to_s, :flagger_id => flaggable), :class => :minibutton
    elsif show_msg
      msg
    end
  end

  def flag_msg flaggable
    msg = nil
    if current_user
      flags = current_user.get_flags(flaggable)
      unless flags.empty?
        if flags.collect(&:status).include? FLAG_STATUS_REJECTED
          msg = t 'flag.user_flagging_reject'
        elsif flags.collect(&:status).include? FLAG_STATUS_PENDING
          msg = t('flag.user_flagged_item', :item => t("flag.#{flaggable.class.to_s.downcase}"))
        end
      end
    end
    msg = "<div class='flagging'> #{image_tag('icons/flag_16.png', :alt => :flag)} #{msg}</div>" unless msg.nil?
  end

  def per_page_select refresh_url
    link_to_command(10, refresh_url) +
            link_to_command(25, refresh_url) +
            link_to_command(50, refresh_url) +
            link_to_command(100, refresh_url, false)
  end

  def about_link
    unless params[:controller] == 'high_voltage/pages' and params[:action] == 'show' and params[:id] == 'about'
      link_to "About Firehoze", page_path("about")
    end
  end

  def browse_category_navigation
    buf = link_to "All", categories_path
    if @category
      AncestorCategory.category_id_equals(@category.id).descend_by_generation(:select => [:ancestor_name]).each do |cat|
        buf = buf + " > " + link_to(cat.ancestor_name, category_path(cat.ancestor_category))
      end
      buf = buf + " > " + @category.name
    end
    buf
  end

  def browser_name
    @browser_name ||= begin

      ua = request.env['HTTP_USER_AGENT']
      return nil if ua.nil?
      ua.downcase!

      if ua.index('msie') && !ua.index('opera') && !ua.index('webtv')
        'ie'+ua[ua.index('msie')+5].chr
      elsif ua.index('gecko/')
        'gecko'
      elsif ua.index('opera')
        'opera'
      elsif ua.index('konqueror')
        'konqueror'
      elsif ua.index('applewebkit/')
        'safari'
      elsif ua.index('mozilla/')
        'gecko'
      end

    end
  end

  def page_selected(current_page, tab_name)
    if current_page == tab_name
      return 'selected'
    end
  end

  def random_quote 
    [
      "In the competitive world of college admissions, grades and test scores make a difference. A cutting-edge tutoring method will help students of all learning abilities and skill levels. This is exciting and innovative. I am excited to see where Firehoze is going to take our future leaders.&nbsp;&nbsp;&nbsp;<br />&mdash; Cheri Barad, Education Consultant",
      "Getting an education...is like drinking from a fire hose.<br /> &mdash; Jerome Weisner, MIT President (1971-80)",
      "This is going to make tutoring more fun and personal.<br /> &mdash; Sam P, Chestnut Hill",
      "Being able to take the tutoring classes at my own pace will be better suited for my learning style.<br /> &mdash; Sarah C, Medfield",
      "I'll be able to choose the tutor I want that appeals to my learning methods.<br /> &mdash; Joe W, Westwood"
    ].rand
  end                                  

  private

  def link_to_command per_page, refresh_url, append_space=true
    if cookies[:per_page] == per_page.to_s
      "#{per_page}#{append_space ? "&nbsp;" : ""}"
    else
      link_to(per_page, set_per_pages_path(:per_page => per_page, :refresh_url => refresh_url), :method => :post) +
              (append_space ? "&nbsp;" : "")
    end
  end
end