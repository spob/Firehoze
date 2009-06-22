module UsersHelper
  def signin_or_signout_link
    if current_user
      "Greetings, #{current_user.login} (not #{signout_link(current_user.login)}?) #{signout_link("Sign Out")}"
    else
      "#{link_to "Sign In", login_path} | #{link_to "Register", new_registration_path}"
    end
  end

  def signout_link(string)
    link_to "#{string}", logout_path, :method => :delete
  end
end
