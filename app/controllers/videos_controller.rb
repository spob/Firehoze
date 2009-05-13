class VideosController < ApplicationController
  before_filter :require_user, :only => [:new, :create] 

  def index
    @videos = Video.list params[:page]
  end

  def new
    @video = Video.new
  end

  def create
    @video = Video.new(params[:video])
    @video.author = current_user
    if @video.save
      flash[:notice] = "Video uploaded"
      redirect_to video_path(@video)
    else
      render :action => :new
    end
  end

  def show
    @video = Video.find params[:id]
  end
end
