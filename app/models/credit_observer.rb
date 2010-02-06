class CreditObserver < ActiveRecord::Observer
  def after_save(credit)
    if credit.activity_compiled_at.nil? and !credit.lesson.nil?
      Credit.transaction do
        credit.compile_activity
      end
    end
  end
end
