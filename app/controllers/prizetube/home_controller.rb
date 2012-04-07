class Prizetube::HomeController < ApplicationController
  THUMBNAILS_PER_PAGE = 5

  include SslRequirement

  layout "prizetube/application"

  before_filter :find_user
  before_filter :find_most_popular_contests
  before_filter :find_upcoming_contests
  before_filter :find_branded_contests
  before_filter :find_ending_soon_contests

  # Unrecognized user page
  def index
    logger.debug "Prizetube::HomeController.index"
  end

  def new
  end

  def create
  end

  def show
  end

  def edit
  end

  def update
  end

  private

  def find_user
  end

  def find_most_popular_contests
    @most_popular_contests = Group.descend_by_starts_at.all(:conditions => { :contest => true }).paginate(:per_page => THUMBNAILS_PER_PAGE, :page => params[:most_popular_contests_page])
  end

  def find_upcoming_contests
    @upcoming_contests = Group.descend_by_starts_at.all(:conditions => { :contest => true }).paginate(:per_page => THUMBNAILS_PER_PAGE, :page => params[:upcoming_contests_page])
  end

  def find_branded_contests
    @branded_contests = Group.descend_by_starts_at.all(:conditions => { :contest => true }).paginate(:per_page => THUMBNAILS_PER_PAGE, :page => params[:branded_contests_page])
  end

  def find_ending_soon_contests
    @ending_soon_contests = Group.ascend_by_ends_at.all(:conditions => { :contest => true }).paginate(:per_page => THUMBNAILS_PER_PAGE, :page => params[:ending_soon_contests_page])
  end

end
