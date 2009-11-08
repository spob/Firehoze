class SearchesController < ApplicationController
  def index
    @search_criteria = params[:search_criteria]
    @lesson_format = 'narrow'
    @collection = 'search'
    # using paginate to set a maximum # of rows returned
    @lessons = Lesson.search @search_criteria,
                             :conditions => { :status => 'Ready'},
                             :include => :instructor,
                             :page => 1,
                             :per_page => 25

#    member_groups = [-1] + (current_user ? current_user.member_groups : [])
    @groups = Group.search @search_criteria,
                           :conditions => { :private => 0},
                           :include => [:owner ],
                           :page => 1,
                           :per_page => 25
  end
end
