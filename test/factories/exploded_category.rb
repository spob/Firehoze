Factory.define :exploded_category do |category|
  category.association :base_category, :factory => :root_category
  category.association :category
  category.base_name { |a| a.base_category.name }
  category.name { |a| a.category.name }
  category.level 1
end