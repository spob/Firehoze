class SearchesController < ApplicationController
  def index
    @search_lesson_criteria = params[:search_lesson_criteria]
    @lesson_format = 'narrow'
    @collection = 'search'
    # using paginate to set a maximum # of rows returned
    @lessons = Lesson.search @search_lesson_criteria,
                             :conditions => { :status => 'Ready'},
                             :include => :instructor,
                             :page => 1,
                             :per_page => 25
  end
end
