module PagesHelper
  extend ActiveSupport::Memoizable

  def instructors_group_link
    group = Group.find_by_id(APP_CONFIG[CONFIG_FIREHOZE_INSTRUCTOR_GROUP_ID])
    group_name = "Firehoze Instructors Group"
    if group
      link_to group_name, group_path(group)
    else
      group_name
    end
  end

  memoize :instructors_group_link
end
