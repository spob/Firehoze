class Category < ActiveRecord::Base
  acts_as_tree :order => "sort_value ASC", :foreign_key => "parent_category_id"
  has_friendly_id :name
  belongs_to :parent_category, :class_name => 'Category'
  has_many :lessons
  has_many :groups
  has_many :child_categories, :class_name => 'Category', :foreign_key => 'parent_category_id', :dependent => :destroy
  has_many :exploded_categories, :dependent => :destroy
  has_many :base_exploded_categories, :class_name => 'ExplodedCategory', :foreign_key => 'base_category_id', :dependent => :destroy
  has_many :ancestor_categories, :dependent => :destroy
  has_many :early_ancestor_categories, :class_name => 'AncestorCategory', :foreign_key => 'ancestor_category_id', :dependent => :destroy

  validates_presence_of :name, :sort_value
  validates_uniqueness_of :name
  validates_numericality_of :sort_value, :level, :allow_nil => true

  named_scope :by_parent_sort_value, :include => [:parent_category],
              :order => 'parent_categories_categories.sort_value ASC, categories.sort_value ASC'
  named_scope :root, :conditions => { :parent_category_id => nil }, :include => [:child_categories]
  named_scope :visible_to_lessons, :conditions => { :visible_to_lessons => true }

  after_save :set_lesson_delta_flag

  @@counter = 0

  def self.tag_cloud_cache_id(type, id)
    "#{type}_tag_cloud_category_#{id}"
  end

  def self.list(page, per_page)
    Category.ascend_by_compiled_sort.paginate(:page => page,
                                              :per_page => per_page)
  end

  def can_delete?
    self.child_categories.empty? and self.lessons.empty? and self.groups.empty?
  end

  def has_children?
    self.child_categories.present?
  end

  def self.sort_by_filters
    %w(most_popular highest_rated newest)
  end

  def self.explode
    @@counter = 0
    Category.transaction do
      ExplodedCategory.delete_all
      AncestorCategory.delete_all

      Category.root.ascend_by_sort_value.each do |category|
        category.explode category, 1
      end
    end
  end

  def explode root_category, level
    unless ExplodedCategory.find(:first, :conditions => { :category_id => self.id, :base_category_id => root_category.id})
      @@counter = @@counter + 1
      self.update_attributes(:level => self.ancestors.size,
                             :compiled_sort => @@counter)
      ExplodedCategory.create!(:category => self, :base_category => root_category,
                               :name => self.name, :base_name => root_category.name,
                               :level => level)
    end
    self.child_categories.each do |child|
      child.explode root_category, level + 1
      child.explode child, 1
    end
    i = 1
    self.ancestors.each do |ancestor|
      unless AncestorCategory.find(:first, :conditions => { :category_id => self.id, :ancestor_category_id => ancestor.id})
        AncestorCategory.create!(:category => self, :ancestor_category => ancestor,
                                 :name => self.name, :ancestor_name => ancestor.name,
                                 :generation => i)
      end
      i = i + 1
    end
  end

  def formatted_name
    self.level = self.ancestors.size unless self.level
    buffer = ""
    self.level.times do
      buffer = buffer + "-"
    end
    buffer + self.name
  end

  def lesson_count(user = nil)
    Lesson.ready.not_owned_by(user).by_category(self.id).count
  end

  def group_count(user = nil)
    Group.public.by_category(self.id).count
  end

  private

  def set_lesson_delta_flag
    self.lessons.each do |lesson|
      lesson.update_attribute(:delta, true)
    end
  rescue ActiveRecord::StatementInvalid
    # Won't work if run during migration - column is added later, so swallow it
    raise unless ActiveRecord::Migrator.current_version.to_i <= 20090927012532
  end
end                                  