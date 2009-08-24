class PeriodicJobObserver < ActiveRecord::Observer
  def after_update(job)
    if !job.last_run_at.nil? and job.last_run_result != "OK"
      RunOncePeriodicJob.create(
              :job => "")
    end
  end
end