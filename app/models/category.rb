class Category < ActiveRecord::Base
  belongs_to :parent_category, :class_name => 'Category'
  has_many   :child_categories, :class_name => 'Category', :foreign_key => 'parent_category_id', :dependent => :destroy

  validates_presence_of     :name
  validates_uniqueness_of   :name
end
