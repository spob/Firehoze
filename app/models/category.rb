class Category < ActiveRecord::Base
  belongs_to :parent_category, :class_name => 'Category'
  has_many :lessons
  has_many :child_categories, :class_name => 'Category', :foreign_key => 'parent_category_id', :dependent => :destroy

  validates_presence_of :name, :sort_value
  validates_uniqueness_of :name
  validates_numericality_of :sort_value, :allow_nil => true

  named_scope :by_parent_sort_value, :include => [:parent_category],
              :order => 'parent_categories_categories.sort_value ASC, categories.sort_value ASC'
  named_scope :root, :conditions => { :parent_category_id => nil }

  def self.list(page, per_page)
    Category.by_parent_sort_value.paginate(:page => page,
                                           :per_page => per_page)
  end

  def can_delete?
    self.child_categories.empty? and self.lessons.empty?
  end

  def self.explode
    Category.transaction do
      ExplodedCategory.delete_all
      Category.root.each do |category|
        category.explode category, 1
      end
    end
  end

  def explode root_category, level
    ExplodedCategory.create!(:category => self, :base_category => root_category,
                             :name => self.name, :base_name => root_category.name,
                             :level => level)
    self.child_categories.each do |child|
      child.explode root_category, level + 1
      child.explode child, 1
    end
  end
end
