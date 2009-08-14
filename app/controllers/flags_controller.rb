class FlagsController < ApplicationController
  before_filter :require_user
  before_filter :find_flagger, :except => [:index]
  helper_method :flaggable_show_path
  layout :layout_for_action

  permit ROLE_ADMIN, :only => [ :index ]

  verify :method => :post, :only => [:create ], :redirect_to => :home_path

  def create
    @flag = @flagger.flags.new(params[:flag])
    @flag.status = FLAG_STATUS_PENDING
    @flag.user = current_user
    if @flag.save
      flash[:notice] = t('flag.create_success')
      redirect_to flaggable_show_path(@flag)
    else
      render :action => "new"
    end
  end

  def new
    @flag = @flagger.flags.new
  end

  def index
    @flags = Flag.pending(:order_by => object_id).paginate :page => params[:page], :per_page => @per_page
  end
  
  def flaggable_show_path(flag)
    if flag.flaggable.class == Review or flag.flaggable.class == LessonComment
       show_url Lesson, flag.flaggable.lesson.id
    else
       show_url flag.flaggable.class, flag.flaggable.id
    end
  end

  private

  def layout_for_action
    %w(index).include?(params[:action]) ? 'admin' : 'application'
  end

  def show_url klass, id
    url_for :controller => klass.to_s.pluralize, :action => 'show', :id => id
  end

  def find_flagger
    @klass = params[:flagger_type].constantize
    @flagger = @klass.find(params[:flagger_id])
  end
end
