class QuizzesController < ApplicationController
  before_filter :require_logged_in
  prepend_before_filter :retrieve_group, :except => [:edit, :update, :show]
  prepend_before_filter :retrieve_quiz, :only => [:edit, :show, :update]

  def new
    @quiz = @group.quizzes.build
    can_create?(@group)
  end

  def create
    if can_create? @group
      @quiz = @group.quizzes.build(params[:quiz])
      @quiz.published = false
      if @quiz.save
        flash[:notice] = t 'quiz.create_success'
        redirect_to quiz_path(@quiz)
      else
        render :action => 'new'
      end
    end
  end

  def edit
  end

  def show
    can_view?(@quiz)
  end
                                  
  def update
    if @quiz.update_attributes(params[:quiz])
      flash[:notice] = t 'quiz.update_success'
      redirect_to quiz_url(@quiz)
    else
      render :action => 'edit'
    end

  end

  private

  def can_view?(quiz)
    if quiz.group.includes_member?(current_user)
      true
    else
      flash[:error] = t('quiz.must_be_member', :group => quiz.group.name)
      redirect_to home_path
      false
    end
  end

  def can_create? group
    if group.owned_by?(current_user) || group.moderated_by?(current_user)
      true
    else
      flash[:error] = t('quiz.must_be_moderator_or_owner', :group => topic.group.name)
      redirect_to group_path(group)
      false
    end
  end

  def retrieve_quiz
    @quiz = Quiz.find(params[:id])    
    @group = @quiz.group
  end

  def retrieve_group
    @group = Group.find(params[:group_id])
  end

  def require_logged_in
    require_user(group_path(@group || @quiz.group, :anchor => "quiz"))
  end

end
