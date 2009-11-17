module MyFirehozeHelper
  include ApplicationHelper

  def list_instructed_lessons user, my_firehoze_user
    lessons = user.lessons.find(:all, :conditions => { :id => my_firehoze_user.instructed_lessons })
    lessons.collect{|lesson| link_to(h(lesson.title), lesson_path(lesson)) }.join(", ")
  end
end
