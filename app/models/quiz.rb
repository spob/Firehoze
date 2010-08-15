class Quiz < ActiveRecord::Base
  belongs_to :group, :counter_cache => true
  validates_presence_of :name, :group
  validates_uniqueness_of :name, :scope => :group_id
  validates_length_of :name, :maximum => 100, :allow_nil => true
  
  named_scope :visible_by_user,
              lambda { |user, group| return {} if group.owned_by?(user) || group.moderated_by?(user);
              {:conditions => ["(disabled_at IS NULL OR disabled_at >= ?) AND published = 1",  Time.now]}
              }
end
