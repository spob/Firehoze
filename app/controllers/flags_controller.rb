class FlagsController < ApplicationController
  before_filter :require_user
  before_filter :find_flagger, :only => [ :new, :create ]
  before_filter :find_flag, :only => [ :show, :update, :edit ]
  helper_method :flaggable_show_path
  layout :layout_for_action

  permit ROLE_MODERATOR, :only => [ :index, :show, :update, :edit ]

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path

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

  def show
    populate_flagger_type
  end

  def edit
    populate_flagger_type
  end

  def update
    @flag.response = params[:flag][:response]
    @flag.status = params[:flag][:status]
    @flag.moderator_user = current_user
    Flag.transaction do
      if @flag.save
        flash[:notice] = t 'flag.update_success'
        if @flag.status == FLAG_STATUS_PENDING
          redirect_to flag_path(@flag)
        else
          if @flag.status == FLAG_STATUS_RESOLVED
            for flag in @flag.flaggable.flags.pending
              flag.status = FLAG_STATUS_RESOLVED
              flag.moderator_user = current_user
              flag.save!
            end
            flash[:notice] = t 'flag.flaggable_rejected', :flaggable => @flag.flaggable.class.to_s
            @flag.flaggable.reject
            @flag.flaggable.save!
          end
          redirect_to flags_path
        end
      else
        render :action => 'edit'
      end
    end
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
    %w(index show edit).include?(params[:action]) ? 'admin' : 'application'
  end

  def show_url klass, id
    url_for :controller => klass.to_s.pluralize, :action => 'show', :id => id
  end

  def find_flagger
    @klass = params[:flagger_type].constantize
    @flagger = @klass.find(params[:flagger_id])
  end

  def find_flag
    @flag = Flag.find(params[:id])
  end

  def populate_flagger_type
    params[:flagger_type] = @flag.flaggable.class.to_s
    params[:flagger_id] = @flag.flaggable.id
    find_flagger
  end
end
