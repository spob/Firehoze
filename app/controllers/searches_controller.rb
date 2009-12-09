class SearchesController < ApplicationController

  layout 'application_v2'

  def index
    @search_criteria = params[:search_criteria]

    # using paginate to set a maximum # of rows returned
    @lessons = Lesson.search @search_criteria,
      :conditions => { :status => 'Ready'},
      :include => :instructor,
      :page => 1,
      :per_page => 25,
      :retry_stale => true

    # member_groups = [-1] + (current_user ? current_user.member_groups : [])
    @groups = Group.search @search_criteria,
      :conditions => { :private => 0},
      :include => [:owner ],
      :page => 1,
      :per_page => 25,
      :retry_stale => true

    @users = User.search @search_criteria,
      :page => 1,
      :per_page => 25,
      :retry_stale => true
  end
end
