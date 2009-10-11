require 'markaby'

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
    return if lesson.nil?
    tn_options = { :class => :lesson_tn, :alt => h(lesson.title) }
    tn_options.merge!(options)

    img_src = lesson.thumbnail_url ? lesson.sized_thumbnail_url(size) : "videos/video_placeholder.jpg"
    link_to(image_tag(img_src, tn_options), lesson_path(lesson))
  end

  def number_of_students_phrase(lesson)
    if lesson.credits_count
      "<span class='ui-icon ui-icon-person adjacent_icon'></span>#{h(t('lesson.students'))}: #{lesson.credits_count}"
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
      if lesson.owned_by?(current_user) or lesson.can_edit?(current_user)
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

  def button_to_edit(lesson)
    if lesson.can_edit?(current_user)
      button_to t('lesson.edit'), edit_lesson_path(lesson), :method => :get
    end
  end

  def link_to_add_attachment(lesson)
    if lesson.can_edit?(current_user)
      link_to "Add Attachment", new_lesson_lesson_attachment_path(lesson)
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

  def button_to_comment(lesson, label)
    button_to label, new_lesson_lesson_comment_path(lesson), :method => :get
  end

  def button_to_wish(lesson)
    if lesson.instructed_by?(current_user) or lesson.owned_by?(current_user)
      return
    elsif current_user and current_user.on_wish_list?(lesson)
      button_to "Remove from Wish List", wish_list_path(lesson), :method => :delete, :disable_with => translate('general.disable_with')
    else
      button_to "Add to Wish List", wish_lists_path(:id => lesson), :method => :post, :disable_with => translate('general.disable_with')
    end
  end

  def bread_crumb category
    buffer = ""
    AncestorCategory.category_id_equals(category.id).descend_by_generation(:select => [:ancestor_name]).each do |cat|
      buffer = buffer + link_to(h(cat.ancestor_name), category_path(cat.ancestor_category)) + " > "
    end
    buffer = buffer + h(category.name)
  end

  def list_attachments
    unless @lesson.attachments.empty?
      markaby do
        b "Attachments:"
        br
        ul do
          @lesson.attachments.each do |a|
            li do
              a a.title, :href => a.attachment.url
            end
          end
        end
      end
    end
  end

  private

  def markaby(&block)
    Markaby::Builder.new({}, self, &block)
  end
end