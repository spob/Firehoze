module FacebookInvitationsHelper
  def exclude_ids(friends)
    friend_ids = friends.split(/,/)
    existing_users = User.facebook_id_not_null.collect{|u| u.facebook_id.to_s}
    friend_ids & existing_users
  end
end
