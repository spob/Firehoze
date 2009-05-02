class HomesController < ApplicationController
  # This is a dummy controller which may eventually be removed.
  # For now I just needed a screen that did not require restricted
  # access

  before_filter :require_user
  
  def index
  end

end
