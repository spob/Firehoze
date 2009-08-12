module FlagsHelper

  def offending_user
    if @flag.flaggable.class == Lesson
      @flag.flaggable.instructor
    elsif @flag.flaggable.class == Review or @flag.flaggable.class == LessonComment
      @flag.flaggable.user
    else
      raise
    end
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
