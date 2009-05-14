class VideosController < ApplicationController
  before_filter :require_user, :only => [:new, :create, :edit, :update]

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path

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

  def edit
    @video = Video.find params[:id]
    unless @video.can_edit? current_user
      flash[:error] = "You do not have access to edit this video"
      redirect_to video_path(@video)
    end
  end

  def update
    @video = Video.find params[:id]
    if @video.can_edit? current_user
      if @video.update_attributes(params[:video])
        flash[:notice] = "Video updated!"
        redirect_to video_path(@video)
      else
        render :action => :edit
      end
    else
      flash[:error] = "You do not have access to edit this video"
      redirect_to video_path(@video)
    end
  end
end