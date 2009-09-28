Factory.define :ancestor_category do |category|
  category.association :ancestor_category, :factory => :root_category
  category.association :category
  category.ancestor_name { |a| a.ancestor_category.name }
  category.name { |a| a.category.name }
  category.generation 1
end