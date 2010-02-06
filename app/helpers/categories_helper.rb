module CategoriesHelper
  def child_categories_links(parent_category)
    child_category_links = []
    Category.parent_category_id_equals(parent_category.id).ascend_by_sort_value.each do |child_category|
      child_category_links << "#{link_to(child_category.name, category_path(child_category))}"
    end
    child_category_links.join(", ")
  end

  def child_categories_names(parent_category)
    child_category_names = []
    Category.parent_category_id_equals(parent_category.id).ascend_by_sort_value.each do |child_category|
      child_category_names << child_category.name
    end
    child_category_names.join(", ")
  end
end
