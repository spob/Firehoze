# A UserLogon records an instance of a user logging on to the system.
class UserLogon < ActiveRecord::Base
  # todo: not sure this is necessary...Bob to investigate
  acts_as_authorizable
  
  belongs_to :user

   # Basic paginated listing finder
  def self.list(page)
    paginate :page => page, 
      :conditions => ['created_at > ?', (Time.zone.now - 60*60*24*90).to_s(:db)],
      :order => 'created_at desc', 
      :per_page => Constants::ROWS_PER_PAGE
  end
end
