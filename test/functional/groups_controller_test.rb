require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class GroupsControllerTest < ActionController::TestCase

  fast_context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    fast_context "without moderator access" do
      context "on GET to :list_admin" do
        setup { get :list_admin }

        should_respond_with :redirect
        should_set_the_flash_to /Permission denied/
        should_redirect_to("home page") { lessons_path }
      end
    end

    fast_context "as moderator" do
      setup { @user.has_role 'moderator' }

      fast_context "on GET to :list_admin" do
        setup { get :list_admin }
        should_respond_with :success
        should_not_set_the_flash
        should_assign_to :groups
        should_render_template 'list_admin'
      end
    end

    context "on GET to :new" do
      setup { get :new }

      should_assign_to :group
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "new"
    end

    fast_context "on POST to :create" do
      setup do
        post :create,
             :group => Factory.attributes_for(:group, :owner => Factory.create(:user),
                                              :category => Factory.create(:category))
      end

      should_set_the_flash_to /Successfully created group/
      should_assign_to :group
      should_respond_with :redirect
      should_redirect_to("Group show page") { group_url(assigns(:group)) }
      should "populate members" do
        assert_equal @user, assigns(:group).owner
        assert assigns(:group).users.include?(@user)
        assert_equal OWNER, assigns(:group).group_members.first.member_type

        assert assigns(:group).includes_member?(assigns(:group).owner)
        assert !assigns(:group).includes_member?(Factory(:user))
      end
    end

    fast_context "with a group defined" do
      setup { @group = Factory.create(:group, :owner => @user) }

      fast_context "on GET to :edit" do
        setup { get :edit, :id => @group.id }

        should_assign_to :group
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "edit"
      end

      context "on PUT to :update" do
        setup { put :update, :id => @group.id, :group => @group.attributes }

        should_set_the_flash_to /Successfully updated group/
        should_assign_to :group
        should_respond_with :redirect
        should_redirect_to("Group show page") { group_url(@group) }
      end

      fast_context "with tags defined" do
          setup do
            assert !@group.nil?
            @group.tag_list = 'taggy'
            @group.save!
          end

          fast_context "on GET to :tagged_with and a good tag" do
            setup { get :tagged_with, :tag => 'taggy' }

            should_assign_to :groups
            should "have a group returned" do
              assert 1, assigns(:groups).size
            end
            should_render_template 'tagged_with'
            should_not_set_the_flash
          end

          fast_context "on GET to :tagged_with and a bad tag" do
            setup { get :tagged_with, :tag => 'blah' }

            should_assign_to :groups
            should "not have a lesson returned" do
              assert assigns(:groups).empty?
            end
            should_render_template 'tagged_with'
            should_not_set_the_flash
          end
        end
    end
  end
end