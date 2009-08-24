class ContactUsersController < ApplicationController
  before_filter :require_user

  verify :method => :post, :only => [ :create ], :redirect_to => :home_path

  def new
    @to_user = User.find(params[:id])
    unless @to_user.can_contact?(current_user)
      flash[:error] = t 'contact_user.cannot_contact'
      redirect_to home_path
    end
  end

  def create
    @to_user = User.find(params[:id])
    @subject = params[:subject]
    @msg = params[:msg]
    RunOncePeriodicJob.create!(
            :name => 'Contact User',
            :job => "ContactUsersController.contact_user(#{@to_user.id}, #{current_user.id}, '#{@subject.gsub(/'/, "")}', #JOBID#)",
            :data => @msg)
      flash[:notice] = t 'contact_user.msg_sent'
      redirect_to user_path(@to_user)
  end

  def self.contact_user(to_user_id, from_user_id, subject, job_id)
    job = PeriodicJob.find(job_id)
    to_user = User.find(to_user_id)
    from_user = User.find(from_user_id)
    Notifier.deliver_contact_user(to_user, from_user, subject, job.data)
  end
end
