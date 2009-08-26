# A UserLogon records an instance of a user logging on to the system.
class UserLogon < ActiveRecord::Base
  # todo: not sure this is necessary...Bob to investigate
  acts_as_authorizable

  belongs_to :user

  named_scope :last_90_days, :conditions => ['user_logons.created_at > ?', (Time.zone.now - 60*60*24*90).to_s(:db)]
end
