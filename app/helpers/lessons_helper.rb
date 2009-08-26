module LessonsHelper
  def watch_text(lesson)
    if current_user.nil? or current_user.owns_lesson?(lesson) or current_user == lesson.instructor
      t('lesson.watch')
    elsif lesson.free_credits.available.size > 0
      t('lesson.watch_for_free')
    else
      t('lesson.buy')
    end
  end

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
                  t('lesson.owned_lessons')
                when :tagged_with
                  "#{t('lesson.tagged_with')} &quot;#{args.first}&quot;"
              end
      "<h3>#{header}</h3>"
    end
  end

  def img_tag_lesson_tn(lesson)
    #TODO: We should move the placeholder into a config property
    img_src = lesson.thumbnail_url ? lesson.thumbnail_url : "videos/video_placeholder.jpg"
    link_to(image_tag(img_src, :class => :lesson_tn, :alt => lesson.title), lesson_path(lesson))
  end

  def number_of_students_phrase(lesson)
    if lesson.credits_count
      "<span class='ui-icon ui-icon-person adjacent_icon'></span>#{t('lesson.students')}: #{lesson.credits_count}"
    elsif lesson.created_at > 7.days.ago
      t('lesson.new_release')
    end
  end

  def owned_it_phase(lesson)
    if current_user and current_user.owns_lesson?(lesson)
      t('lesson.owned')
    end
  end

  def button_to_buy(lesson)
    if lesson.ready?
      if lesson.owned_by?(current_user) or current_user == lesson.instructor
        return
      end

      if lesson.free_credits.available.size > 0
        action_text = t('lesson.watch_for_free')
      else
        action_text = t('lesson.buy')
      end

      button_to action_text, watch_lesson_path(lesson), :method => :get
    end
  end

  def link_to_wishes
    link_to t('lesson.wishlist'), list_lessons_path(:collection => :wishlist )
  end

  def button_to_edit(lesson)
    if lesson.instructed_by?(current_user) or current_user.try("is_admin?")
      button_to t('lesson.edit'), edit_lesson_path(lesson), :method => :get
    end
  end

  def button_to_unreject(lesson)
    if current_user.try("is_moderator?") and lesson.status == LESSON_STATUS_REJECTED
      button_to t('lesson.unreject'), unreject_lesson_path(lesson), :method => :post
    end
  end

  def button_to_preview(lesson)
    if lesson.ready?
      if lesson.owned_by?(current_user) or lesson.instructed_by?(current_user)
        return
      else
        button_to "Preview", nil, { :alt => '#FIXME (when preview functionality is coded by Bob)', :disabled => true }
      end
    end
  end

  def button_to_review(lesson)
    if !lesson.reviewed_by?(current_user) and lesson.owned_by?(current_user)
      button_to "Write a Review", new_lesson_review_path(lesson), :method => :get
    end
  end

  def button_to_comment(lesson)
    button_to "Add a Comment", new_lesson_lesson_comment_path(lesson), :method => :get
  end

  def button_to_wish(lesson)
    if lesson.instructed_by?(current_user) or lesson.owned_by?(current_user)
      return
    elsif current_user and current_user.on_wish_list?(lesson)
      button_to "Remove from Wish List", wish_lists_path(:id => lesson), :method => :delete, :disable_with => translate('general.disable_with')
    else
      button_to "Add to Wish List", wish_lists_path(:id => lesson), :method => :post, :disable_with => translate('general.disable_with')
    end
  end

end
