module FlagsHelper

  def offending_user
    @flag.flaggable.instructor if @flag.flaggable.class == Lesson
    @flag.flaggable.user if @flag.flaggable.class == Review
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
