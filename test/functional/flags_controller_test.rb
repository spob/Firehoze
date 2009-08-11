require 'test_helper'

class FlagsControllerTest < ActionController::TestCase
  context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    context "given an existing lesson" do
      setup do
        @lesson = Factory.create(:lesson)
      end

      context "on GET to :new" do
        setup { get :new, :flagger_type => 'Lesson', :flagger_id => @lesson }

        should_assign_to :flag
        should_assign_to :flagger
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "new"
      end

      context "on POST to :create" do
        setup do
          @new_flag_attr = Factory.attributes_for(:flag, :flaggable_id => @lesson.id)
          post :create, :flag => @new_flag_attr, :flagger_type => 'Lesson', :flagger_id => @lesson
        end

        should_assign_to :flagger
        should_respond_with :redirect
        should_set_the_flash_to /Thank you for bringing this to our attention/
        should_redirect_to("Show lessons page") { lesson_url(@lesson) }
      end
    end
  end
end
