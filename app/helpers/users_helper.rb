require 'uri'
require 'net/http'

module UsersHelper
  def follow_link user, current_user
    if current_user
      if user.followed_by?(current_user)
        link_to "Stop Following", instructor_follow_path(user), :method => :delete
      elsif user.verified_instructor? and user != current_user
        link_to "Follow this instructor", instructor_follows_path(:id => user), :method => :post
      end
    end
  end

  def signin_or_signout_link
    if current_user
      "Greetings, #{h(current_user.login)} (not #{signout_link(h(current_user.login))}?) #{signout_link("Sign Out")}"
    else
      "#{link_to "Sign In", login_path} | #{link_to "Sign Up", new_registration_path}"
    end
  end

  def show_bio
    unless @user.bio.blank?
      if @user.rejected_bio
        "<i>" + t('user.rejected_bio') + "</i>"
      else
        @user.bio
      end
    end
  end

  def signout_link(string)
    link_to "#{string}", logout_path, :method => :delete
  end

  def avatar_tag(user, options = {})
    # pass a value
    #for :url other than :cdn in order to force the avatar to be rendered from S3 (as opposed to
    # the cdn
    if user
      size = options[:size] || :medium
      url_type = options[:url] || :cdn
      avatar_url = user.avatar.file? ? convert_to_cdn(user.avatar.url(size), url_type) :
              user.gravatar_url(:size => convert_size_to_pixels(size), :default => convert_to_cdn(User.default_avatar_url(size), url_type))
      image_tag avatar_url, options.merge({ :alt => h(privacy_sensitive_username(user)), :class => 'avatar' })
    end
  end

  def gravatar_as_source(user)
    return false if user.avatar.file?

    Net::HTTP.get_response( URI.parse( user.gravatar_url(:default => 'xxxxxxx'))).code == "200"
  end

  def avatar_link_to(user, options)
    link_to avatar_tag(user, options),  user_path(user),  :title => h(privacy_sensitive_username(user)) if user
  end

  def payment_levels_for_select
    PaymentLevel.ascend_by_name.collect { |m| [m.name, m.id] }
  end

  def possessive_helper word
    word + "'" + (word.end_with?("s") ? "" : "s")
  end

  private

  def convert_to_cdn(url, url_type)
    if url_type == :cdn
      User.convert_avatar_url_to_cdn(url)
    else
      url
    end
  end

  def convert_size_to_pixels size
    case size
      when :tiny
        35
      when :smaller
        60
      when :small
        75
      when :medium
        110
      when :large
        220
      when :vlarge
        400
      else
        220
    end
  end
end