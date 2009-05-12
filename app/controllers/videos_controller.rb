class VideosController < ApplicationController

  def index
    @videos = Video.list params[:page]
  end
end
