class ExplodedCategory < ActiveRecord::Base
  belongs_to :category
  belongs_to :base_category, :class_name => 'Category'
  validates_presence_of :category, :base_category, :base_name, :name, :level
end
