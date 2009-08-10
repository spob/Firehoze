module FlagsHelper
  def flaggable_show_path
    url_for :controller => @flag.flaggable.class.to_s.pluralize, :action => 'show', :id => @flag.flaggable.id
  end

  def offending_user
    @flag.flaggable.instructor if @flag.flaggable.class == Lesson
  end

  def reason_select_list
    reasons = []
    for r in @flag.flaggable.class.flag_reasons
      s = translate("flag.flag_#{r}")
      reasons << [s, r]
    end
    reasons
  end
end
