class Prizetube::HomeController < ApplicationController
  include SslRequirement

  layout "prizetube/application"

  before_filter :find_user
  before_filter :find_most_popular_contests
  before_filter :find_upcoming_contests
  before_filter :find_branded_contests
  before_filter :find_ending_soon_contests
  before_filter :find_prizebucks_leaders

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
  end

  def find_upcoming_contests
  end

  def find_branded_contests
  end

  def find_ending_soon_contests
  end

  def find_prizebucks_leaders
  end

end
