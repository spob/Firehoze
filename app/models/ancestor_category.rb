class AncestorCategory < ActiveRecord::Base
  belongs_to :category
  belongs_to :ancestor_category, :class_name => 'Category'
  validates_presence_of :category, :ancestor_category, :ancestor_name, :name, :generation
end
