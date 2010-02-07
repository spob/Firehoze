class PeriodicJobsController < ApplicationController
  include SslRequirement

  before_filter :require_user
  permit ROLE_ADMIN

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :rerun, :run_now ],
         :redirect_to => :periodic_jobs_path

  layout 'admin'

  def index
    @periodic_jobs = PeriodicJob.list params[:page], cookies[:per_page] || ROWS_PER_PAGE
  end

  # Clicking rerun on a job that has completed will cause they job to run one time
  def rerun
    job = PeriodicJob.find(params[:id])
    # todo: probably to verify that the job has infact run before allowing them to request that it be rerun
    RunOncePeriodicJob.create(
            :name => job.name,
            :job => job.job,
            :data => job.data)
    flash[:notice] = t 'periodic_jobs.one_time_job_scheduled'
    redirect_to periodic_jobs_path
  end

  # Clicking rerun on a job that has completed will cause they job to run one time
  def run_now
    job = PeriodicJob.find(params[:id])
    job.update_attribute(:next_run_at, Time.now) if job.next_run_at.present?
    flash[:notice] = t 'periodic_jobs.run_now'
    redirect_to periodic_jobs_path
  end
end