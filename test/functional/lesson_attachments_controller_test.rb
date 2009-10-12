require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class LessonAttachmentsControllerTest < ActionController::TestCase
  fast_context "with an attachment" do
    setup { @attachment = Factory.create(:lesson_attachment) }

    fast_context "when logged in as joe nobody" do
      setup do
        activate_authlogic
        UserSession.create Factory.create(:user)
      end

      fast_context "on GET to :edit" do
        setup { get :edit, :id => @attachment }

        should_respond_with :redirect
        should_assign_to :attachment
        should_redirect_to("lesson show") { lesson_path(@attachment.lesson) }
        should_set_the_flash_to /do not have access/
      end
    end

    fast_context "when logged in as instructor" do
      setup do
        activate_authlogic
        UserSession.create @attachment.lesson.instructor
      end

      fast_context "on GET to :edit" do
        setup { get :edit, :id => @attachment }

        should_respond_with :success
        should_render_template :edit
        should_assign_to :attachment
        should_not_set_the_flash
      end

      fast_context "on PUT to :update" do
        setup { put :update, :id => @attachment.id, :lesson => Factory.attributes_for(:lesson_attachment) }

        should_set_the_flash_to :attachment_updated
        should_assign_to :attachment
        should_respond_with :redirect
        should_redirect_to("lesson page") { lesson_path(@attachment.lesson) }
      end
    end
  end
end