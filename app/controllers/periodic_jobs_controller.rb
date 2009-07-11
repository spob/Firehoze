class PeriodicJobsController < ApplicationController
  before_filter :require_user
  permit ROLE_ADMIN

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:rerun ],
          :redirect_to => :periodic_jobs_path

  def index
    @periodic_jobs = PeriodicJob.list params[:page], ROWS_PER_PAGE
  end

  # Clicking rerun on a job that has completed will cause they job to run one time
  def rerun
    job = PeriodicJob.find(params[:id])
    # todo: probably to verify that the job has infact run before allowing them to request that it be rerun
    RunOncePeriodicJob.create(
            :name => job.name,
                    :job => job.job)
    flash[:notice] = t 'periodic_jobs.one_time_job_scheduled'
    redirect_to periodic_jobs_path
  end
end