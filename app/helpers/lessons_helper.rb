#require 'markaby'

module LessonsHelper
  #def watch_text(lesson)
  #  if current_user.nil? or current_user.owns_lesson?(lesson) or current_user == lesson.instructor
  #    t('lesson.watch')
  #  elsif lesson.free_credits.available.size > 0
  #    t('lesson.watch_for_free')
  #  else
  #    t('lesson.buy')
  #  end
  #end

  # Not sure how to handle this with i18n???
  def free_remaining_text lesson
    if lesson.has_free_credits?
      "<span class='ui-icon ui-icon-heart adjacent_icon'></span>#{pluralize(lesson.free_credits.available.size, 'Free View')} Remaining"
    end
  end

  # must own lesson, but cannot be the instructor
  def lesson_rating_for(lesson, user, *args)
    if (user == lesson.instructor or !lesson.owned_by?(user))
      ratings_for(lesson, :static)
    else
      ratings_for(lesson)
    end
  end

  def audience_value(key)
    t("lesson.#{key}_level")
  end

  def vote_counts_phrase(lesson)
    "#{pluralize(lesson.total_rates, "vote")} cast"
  end

  def lessons_header(collection, *args)
    if controller.action_name == 'list'
      header =
        case collection
      when :most_popular
        t('lesson.most_popular')
      when :highest_rated
        t('lesson.highest_rated')
      when :newest
        t('lesson.newest')
      when :recently_browsed
        t('lesson.recently_browsed')
      when :owned_lessons
        t('lesson.lessons_you_own')
      when :instructed_lessons
        t('lesson.lessons_you_instructed')
      when :tagged_with
        "#{t('lesson.tagged_with')} &quot;#{args.first}&quot;"
      end
      "<h3>#{header}</h3>"
    end
  end

  def img_tag_lesson_tn(lesson, size, options={})
    unless lesson.nil?
      tn_options = { :class => :lesson_tn, :alt => h(lesson.title) }
      tn_options.merge!(options)

      img_src = lesson.thumbnail_url ? lesson.sized_thumbnail_url(size) : "videos/video_placeholder_#{size}.jpg"
      link_to(image_tag(img_src, tn_options), lesson_path(lesson), :class => 'link-to-lesson')
    end
  end

  def number_of_students_phrase(lesson)
    if lesson.credits_count
      "<span class='ui-icon ui-icon-person adjacent_icon'></span>#{lesson.credits_count}"
    elsif lesson.created_at > 7.days.ago
      t('lesson.new_release')
    end
  end

  def owned_it_phrase(lesson, user)
    if user and user.owns_lesson?(lesson)
      t('lesson.owned')
    end
  end

  def link_to_buy(lesson)
    if lesson.ready?
      unless lesson.owned_by?(current_user) or lesson.can_edit?(current_user)
        if lesson.free_credits.available.size > 0
          action_text = t('lesson.watch_for_free')
        else
          action_text = t('lesson.buy')
        end
        link_to action_text, watch_lesson_path(lesson), :class => :rounded 
      end
    end
  end

  def link_to_edit(lesson)
    if lesson.can_edit?(current_user)
      link_to t('lesson.edit'), edit_lesson_path(lesson), :class => :rounded
    end
  end

  def link_to_add_attachment(lesson, user)
    if lesson.can_edit?(user)
      link_to "Add Attachment", new_lesson_lesson_attachment_path(lesson), :class => :rounded
    end
  end

  def link_to_unreject(lesson, user)
    if user.try("is_moderator?") and lesson.status == LESSON_STATUS_REJECTED
      link_to t('lesson.unreject'), unreject_lesson_path(lesson), :class => :rounded
    end
  end

  #  def button_to_preview(lesson)
  #    if lesson.ready?
  #      unless lesson.owned_by?(current_user) or lesson.instructed_by?(current_user)
  #        button_to "Preview", nil, { :alt => '#FIXME (when preview functionality is coded by Bob)', :disabled => true }
  #      end
  #    end
  #  end

  def link_to_review(lesson, user)
    if !lesson.reviewed_by?(user) and lesson.owned_by?(user)
      link_to "Write a Review", new_lesson_review_path(lesson), :class => :rounded
    end
  end

  def link_to_comment(lesson, label)
    link_to label, new_lesson_lesson_comment_path(lesson), :class => :rounded
  end

  def link_to_wish(lesson)
    unless lesson.instructed_by?(current_user) or lesson.owned_by?(current_user)
      if current_user and current_user.on_wish_list?(lesson)
        link_to "Remove from Wish List", wish_list_path(lesson), :method => :delete, :disable_with => translate('general.disable_with'), :class => :rounded
      else
        link_to "Add to Wish List", wish_lists_path(:id => lesson), :method => :post, :disable_with => translate('general.disable_with'), :class => :rounded
      end
    end
  end

  def bread_crumb category
    buffer = ""
    AncestorCategory.category_id_equals(category.id).descend_by_generation(:select => [:ancestor_name]).each do |cat|
      buffer = buffer + link_to(h(cat.ancestor_name), category_path(cat.ancestor_category)) + " > "
    end
    buffer = buffer + h(category.name)
  end

  def link_to_add_remove_group lesson, group
    if lesson.belongs_to_group?(group)
      link_to("Remove", group_lesson_path(group.id, :lesson_id => lesson.id), :method => :delete) + " from &quot;#{group.name.titleize}&quot; Group"
    else
      link_to("Add", group_lessons_path(:id => group.id, :lesson_id => lesson.id), :method => :post) + " to &quot;#{group.name.titleize}&quot; Group"
    end
  end

  private

  def markaby(&block)
    Markaby::Builder.new({}, self, &block)
  end
end

# (#{h(number_to_human_size(a.attachment.size))})