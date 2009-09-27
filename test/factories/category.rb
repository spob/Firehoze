Factory.sequence :name do |n|
  "category_name#{n}"
end

Factory.define :root_category, :class => Category do |category|
  category.name { Factory.next(:name) }
end

Factory.define :category, :parent => :root_category do |category|  
  category.association :parent_category, :factory => :root_category
end