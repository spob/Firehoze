class Category < ActiveRecord::Base
  belongs_to :parent_category, :class_name => 'Category'
  has_many :child_categories, :class_name => 'Category', :foreign_key => 'parent_category_id', :dependent => :destroy

  validates_presence_of :name
  validates_uniqueness_of :name

  named_scope :by_parent_sort_number, :include => [:parent_category],
              :order => 'parent_categories_categories.sort_number ASC, categories.sort_number ASC'

  def self.list(page, per_page)
    Category.by_parent_sort_number.paginate(:page => page,
                                            :per_page => per_page)
  end
end
