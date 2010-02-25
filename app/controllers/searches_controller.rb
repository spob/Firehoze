class SearchesController < ApplicationController

  def index
    @search_criteria = params[:search_criteria]

    # using paginate to set a maximum # of rows returned
    @lessons = Lesson.search @search_criteria,
      :conditions => { :status => 'Ready'},
      :include => [:instructor, :category],
      :page => params[:lesson_page],
      :per_page => SEARCH_RESULTS_PER_PAGE,
      :retry_stale => true

    # member_groups = [-1] + (current_user ? current_user.member_groups : [])
    @groups = Group.search @search_criteria,
      :conditions => { :private => 0},
      :include => [:category],
      :page => params[:group_page],
      :per_page => SEARCH_RESULTS_PER_PAGE,
      :retry_stale => true

    @users = User.search @search_criteria,
      :page => params[:user_page],
      :per_page => SEARCH_RESULTS_PER_PAGE,
      :retry_stale => true
  end
end
