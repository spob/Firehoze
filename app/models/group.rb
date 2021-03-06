class Group < ActiveRecord::Base
  acts_as_taggable
  has_friendly_id :name, :use_slug => true

  after_update :reprocess_logo, :if => :cropping?
  after_save :set_free_lessons_for_members

  belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"
  belongs_to :category
  has_many :group_members
  has_many :group_lessons
  has_many :lessons, :through => :group_lessons
  has_many :topics, :order => 'pinned DESC, last_commented_at DESC'
  has_many :active_lessons, :source => :lesson, :through => :group_lessons,
           :conditions => { :group_lessons => { :active => true }}
  has_many :users, :through => :group_members
  has_many :member_users, :through => :group_members, :source => :user,
           :conditions => { :group_members => { :member_type => [ OWNER, MODERATOR, MEMBER ] } }
  has_many :moderator_users, :through => :group_members, :source => :user,
           :conditions => { :group_members => { :member_type => [ OWNER, MODERATOR ] } }
  has_many :activities, :as => :trackable, :dependent => :destroy
  has_many :all_activities, :class_name => 'Activity', :foreign_key => "group_id"
  has_many :flags, :as => :flaggable, :dependent => :destroy

  validates_presence_of :name, :owner, :category
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 50, :allow_nil => true

  attr_protected :active

  named_scope :public, :conditions => { :private => false }
  named_scope :private, :conditions => { :private => true }
  named_scope :free_to_members, :conditions => { :free_lessons_to_members => true }
  named_scope :ascend_by_category_name_and_name, :joins => :category, :order => 'categories.name, groups.name'
  named_scope :ascend_by_name, :order => 'groups.name'
  named_scope :ids, :select => ["groups.id"]
  named_scope :active, :conditions => { :active => true }
  named_scope :active_or_owner_access_all,
              lambda{ |access_all, user_id|
                { :conditions => ["(groups.active = ? or ? = 1 or groups.owner_id = ?)", true, access_all, user_id] }
              }
  named_scope :not_a_member,
              lambda{ |user| return {} if user.nil?;
              { :conditions => ["groups.id not in (?)", user.member_groups.collect(&:id) + [-1]] }
              }
  named_scope :by_category,
              lambda{ |category_id| return {} if category_id.nil?;
              {:joins => {:category => :exploded_categories},
               :conditions => { :exploded_categories => {:base_category_id => category_id}}}}
  named_scope :a_member,
              lambda{ |user| return {} if user.nil?;
              { :conditions => ["groups.id in (?)", user.member_groups.collect(&:id) + [-1]] }
              }

  # From the thinking sphinx doc: Don’t forget to place this block below your associations,
  # otherwise any references to them for fields and attributes will not work.
  define_index do
    indexes name
    indexes :id
    indexes private
    indexes description
    has category(:id), :as => :category_ids
    set_property :delta => true
  end


  # PAPERCLIP
  has_attached_file :logo,
                    :styles => {
                            :tiny => ["35x35#", :png],
                            :small => ["75x75#", :png],
                            :medium => ["110x110#", :png],
                            :large => ["220x220#", :png],
                            :vlarge => ["400x400>", :png]
                    },
                    :processors => [:cropper],
                    :storage => :s3,
                    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                    :s3_permissions => 'public-read',
                    :path => "#{APP_CONFIG[CONFIG_S3_DIRECTORY]}/groups/:attachment/:id/:style/:basename.:extension",
                    :bucket => APP_CONFIG[CONFIG_AWS_S3_IMAGES_BUCKET]

  # Used for cropping
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  validates_attachment_size :logo, :less_than => 1.megabytes, :message => "All uploaded images must be less then 1 megabyte"
  validates_attachment_content_type :logo, :content_type => [ 'image/gif', 'image/png', 'image/x-png', 'image/jpeg', 'image/pjpeg', 'image/jpg' ]

  @@flag_reasons = [
          FLAG_LEWD,
          FLAG_SPAM,
          FLAG_OFFENSIVE,
          FLAG_DANGEROUS,
          FLAG_OTHER ]

  def self.flag_reasons
    @@flag_reasons
  end

  def self.default_logo_url(style)
    # "http://#{APP_CONFIG[CONFIG_AWS_S3_IMAGES_BUCKET]}/groups/avatars/missing/%s/missing.png" % style.to_s
    # todo: add a logo for missing logo as well
    "/images/groups/%s/missing.png" % style.to_s
  end

  # convert an amazon url for a logo to a cdn url
  def self.convert_logo_url_to_cdn(url, url_type=:cdn)
    if url_type == :cdn
      regex = Regexp.new("//.*#{APP_CONFIG[CONFIG_AWS_S3_IMAGES_BUCKET]}")
      regex2 = Regexp.new("https")
      url.gsub(regex, "//" + APP_CONFIG[CONFIG_CDN_OUTPUT_SERVER]).gsub(regex2, "http")
    else
      url
    end
  end

  def group_logo_url size
    self.logo.file? ? self.logo.url(size) : Group.default_logo_url(size)
  end

  def self.fetch_tagged_with category_id, tag, per_page, page
    Group.public.active.by_category(category_id).find_tagged_with(tag, :include => [:category]).paginate(:per_page => per_page, :page => page)
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

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def self.fetch_user_groups(user, page, per_page)
    user.member_groups.ascend_by_category_name_and_name.paginate(:include => [:category], :per_page => per_page, :page => page) if user
  end

  def can_see?(user)
    !self.private or includes_member?(user)
  end

  def compile_activity
    self.activities.create!(:actor_user => self.owner,
                            :actee_user => nil,
                            :acted_upon_at => self.created_at,
                            :group => self,
                            :activity_string => "group.activity",
                            :activity_object_id => self.id,
                            :activity_object_human_identifier => self.name,
                            :activity_object_class => self.class.to_s)
    self.update_attribute(:activity_compiled_at, Time.now)
  end

  def reject
    self.active = false
  end

  def invite(user)
    group_member = self.group_members.find(:first, :conditions => {:user_id => user.id })
    if group_member
      group_member.touch
    else
      group_member = self.group_members.create!(:user => user, :member_type => PENDING)
    end
    group_member
  end

  def logo_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(logo.url(style))
  end

  private

  def reprocess_logo
    logo.reprocess!
  end

  def set_free_lessons_for_members
    # Public groups cannot give free lessons to its members
    self.free_lessons_to_members = false unless private
    true
  end
end