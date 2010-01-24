class TagCloudSweeper < ActionController::Caching::Sweeper
  observe Lesson, Video, Flag

  def after_save(record)
    if record.is_a?(Lesson)
      clear_tag_cloud_cache(record)
    elsif record.is_a?(Video)
      clear_tag_cloud_cache(record.lesson)
    elsif record.is_a?(Flag) and record.flaggable_type == "Lesson" and record.status == FLAG_STATUS_RESOLVED
      clear_tag_cloud_cache(record.flaggable)
    end
  end

  def clear_tag_cloud_cache(lesson)
    expire_fragment(Category.tag_cloud_cache_id("lesson", -1))
    expire_fragment(Category.tag_cloud_cache_id("lesson", lesson.category.id))
    lesson.category.ancestors.each do |c|
      expire_fragment(Category.tag_cloud_cache_id("lesson", c.id))
    end
  end
end