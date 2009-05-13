class PeriodicJobsController < ApplicationController
  before_filter :require_user
  permit Constants::ROLE_SYSADMIN

  verify :method => :post, :only => [:rerun ], :redirect_to => :home_path

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:rerun ],
          :redirect_to => :periodic_jobs_path
  #  verify :method => :put, :only => [ :update ],
  #    :redirect_to => periodic_jobs_path
  #  verify :method => :delete, :only => [ :destroy ],
  #    :redirect_to => periodic_jobs_path

  def index
    @jobs = PeriodicJob.list params[:page], Constants::ROWS_PER_PAGE
  end

  def rerun
    job = PeriodicJob.find(params[:id])
    RunOncePeriodicJob.create(
            :name => job.name,
                    :job => job.job)
    flash[:notice] = "Job has been scheduled to run one time."
    redirect_to periodic_jobs_path
  end
end