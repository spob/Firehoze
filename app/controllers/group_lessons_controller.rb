class GroupLessonsController < ApplicationController
  before_filter :require_user
  before_filter :find_group_and_lesson

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :delete, :only => [:destroy ], :redirect_to => :home_path

  def create
    if can_update_groups?(@lesson, current_user)
      @group_lesson = @group.group_lessons.find_by_lesson_id(@lesson)
      if @group_lesson.nil?
        @group_lesson = @group.group_lessons.create!(:user => current_user, :lesson => @lesson)
        flash[:notice] = t('group_lesson.lesson_added', :group =>@group.name)
      elsif !@group_lesson.active
        @group_lesson.update_attribute(:active, true)
        flash[:notice] = t('group_lesson.lesson_added', :group => @group.name)
      else
        flash[:error] = t('group_lesson.already_added')
      end
    end
    redirect_to lesson_path(@lesson.id)
  end

  def destroy
    if can_update_groups?(@lesson, current_user)
      @group_lesson = @group.group_lessons.find_by_lesson_id(@lesson.id)
      if @group_lesson.nil? or !@group_lesson.active
        flash[:error] = t('group_lesson.does_not_belong', :group => @group.name)
      else
        @group_lesson.update_attribute(:active, false)
        flash[:notice] = t('group_lesson.lesson_removed', :group => @group.name)
      end
    end
    redirect_to lesson_path(@lesson.id)
  end

  private

  def can_update_groups?(lesson, user)
    if lesson.owned_by?(user) or lesson.can_edit?(user) or lesson.owned_by?(user)
      return true
    else
      flash[:error] = t('general.no_permissions')
      return false
    end
  end

  def find_group_and_lesson
    @group = Group.find(params[:id])
    @lesson = Lesson.find(params[:lesson_id])
  end
end
