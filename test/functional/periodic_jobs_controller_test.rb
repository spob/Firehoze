require 'test_helper'

class PeriodicJobsControllerTest < ActionController::TestCase
  context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    context "with admin access" do
      setup do
        @user.has_role 'admin'
        @job = Factory(:run_once_periodic_job)
      end

      context "on GET to :index" do
        setup { get :index }

        should_assign_to :periodic_jobs
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "index"
      end

      context "on POST to :rerun" do
        setup { post :rerun, :id => @job }

        should_respond_with :redirect
        should_set_the_flash_to /Job has been scheduled/
        should_redirect_to("jobs page") { periodic_jobs_path } 
      end
    end

    context "without admin access" do
      context "on GET to :index" do
        setup { get :index }

        should_not_assign_to :user_logons
        should_respond_with :redirect
        should_set_the_flash_to /denied/
        should_redirect_to("home page") { home_url }
      end
    end
  end
end
