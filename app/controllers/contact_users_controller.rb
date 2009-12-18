class ContactUsersController < ApplicationController
  include SslRequirement

  before_filter :require_user
  before_filter :find_to_user

  layout 'application_v2'

  verify :method => :post, :only => [ :create ], :redirect_to => :home_path

  def new
    check_permissions
  end

  def create
    @subject = params[:subject]
    @msg = params[:msg]
    if check_permissions
      if @subject.blank? or @msg.blank?
        flash[:error] = t('contact_user.required')
        render :action => 'new'
      else
        RunOncePeriodicJob.create!(
                :name => 'Contact User',
                :job => "ContactUsersController.contact_user(#{@to_user.id}, #{current_user.id}, '#{@subject.gsub(/'/, "")}', #JOBID#)",
                :data => @msg)
        flash[:notice] = t 'contact_user.msg_sent'
        redirect_to user_path(@to_user)
      end
    end
  end

  def self.contact_user(to_user_id, from_user_id, subject, job_id)
    job = PeriodicJob.find(job_id)
    to_user = User.find(to_user_id)
    from_user = User.find(from_user_id)
    Notifier.deliver_contact_user(to_user, from_user, subject, job.data)
  end

  private

  def find_to_user
    @to_user = User.find(params[:id])
  end

  def check_permissions
    if @to_user.can_contact?(current_user)
      true
    else
      flash[:error] = t 'contact_user.cannot_contact'
      redirect_to user_path(@to_user)
      false
    end
  end
end