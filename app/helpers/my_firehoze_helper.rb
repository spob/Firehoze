module MyFirehozeHelper
  include ApplicationHelper

  def list_instructed_lessons user
    buffer = nil
    lessons = user.lessons.find(:all, :conditions => { :id => current_user.instructed_lessons })
    lessons.each do |lesson|
      if buffer.nil?
        buffer = " "
      else
        buffer += ", "
      end
      buffer += link_to h(lesson.title), lesson_path(lesson)
    end
    buffer
  end
end
