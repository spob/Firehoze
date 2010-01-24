class FlagObserver <  ActiveRecord::Observer
  def after_create(flag)
    flag.notify_moderators
  end
end
