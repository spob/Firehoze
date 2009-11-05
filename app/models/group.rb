class Group < ActiveRecord::Base
  has_friendly_id :name

  belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"
  belongs_to :category
  has_many :group_members
  has_many :group_lessons
  has_many :lessons, :through => :group_lessons
  has_many :topics, :order => 'pinned DESC, last_commented_at DESC'
  has_many :active_lessons, :source => :lesson, :through => :group_lessons,
           :conditions => { :group_lessons => { :active => true }}
  has_many :users, :through => :group_members
  has_many :activities, :as => :trackable, :dependent => :destroy
  
  validates_presence_of :name, :owner, :category
  validates_uniqueness_of :name

  named_scope :public, :conditions => { :private => false }
  named_scope :private, :conditions => { :private => true }
  named_scope :not_a_member,
              lambda{ |user| return {} if user.nil?;
              { :conditions => ["groups.id not in (?)", user.groups.collect(&:id) + [-1]] }
              }
  named_scope :by_category,
              lambda{ |category_id| return {} if category_id.nil?;
              {:joins => {:category => :exploded_categories},
               :conditions => { :exploded_categories => {:base_category_id => category_id}}}}
  named_scope :a_member,
              lambda{ |user| return {} if user.nil?;
              { :conditions => ["groups.id in (?)", user.groups.collect(&:id) + [-1]] }
              }

  # From the thinking sphinx doc: Don’t forget to place this block below your associations,
  # otherwise any references to them for fields and attributes will not work.
  define_index do
    indexes name
    indexes description
    has category(:id), :as => :category_ids
    set_property :delta => true
  end

  def owned_by?(user)
    self.owner == user
  end

  def moderated_by?(user)
    group_member = includes_member?(user)
    group_member.try(:member_type) == MODERATOR
  end

  def includes_member?(user)
    if user
      self.group_members.find(:first, :conditions => {:user_id => user.id, :member_type => [OWNER, MODERATOR, MEMBER]})
    end
  end

  def compile_activity
    self.activities.create!(:actor_user => self.owner,
                            :actee_user => nil,
                            :acted_upon_at => self.created_at)
    self.update_attribute(:activity_compiled_at, Time.now)
  end
end