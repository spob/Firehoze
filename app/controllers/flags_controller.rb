class FlagsController < ApplicationController
  include SslRequirement
  
  before_filter :require_user
  before_filter :find_flaggable, :only => [ :new, :create ]
  before_filter :find_flag, :only => [ :show, :update, :edit ]
  before_filter :set_no_uniform_js
  helper_method :flaggable_show_path
  layout :layout_for_action

  permit ROLE_MODERATOR, :only => [ :index, :show, :update, :edit ]

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path

  def create
    if reflag_ok(@flaggable)
      @flag = @flaggable.flags.new(params[:flag])
      @flag.status = FLAG_STATUS_PENDING
      @flag.user = current_user
      if @flag.save
        flash[:notice] = t('flag.create_success')
        redirect_to flaggable_show_path(@flag)
      else
        render :action => "new"
      end
    end
  end

  def new
    @flag = @flaggable.flags.new
    if current_user
      reflag_ok(@flaggable)
    else
      store_location new_flag_path(:flagger_type => @flaggable.class.to_s, :flagger_id => @flaggable.id)
      flash[:error] = t('flag.must_logon', :item => t("flag.#{@flaggable.class.to_s.downcase}"))
      redirect_to new_user_session_url
    end
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
    @flags = Flag.pending(:order_by => object_id).all(:include => [:flaggable, :user]).paginate :page => params[:page],
                                                           :per_page => cookies[:per_page] || ROWS_PER_PAGE
  end

  def flaggable_show_path(flag)
    if flag.flaggable.class == LessonComment
      lesson_lesson_comments_path(flag.flaggable(:include => [:lesson]).lesson, :anchor => "LessonComment#{flag.flaggable.id}")
    elsif flag.flaggable.class == TopicComment
      topic_path(flag.flaggable(:include => [:topic]).topic, :anchor => "TopicComment#{flag.flaggable.id}")
    else
      show_url flag.flaggable.class, flag.flaggable.id
    end
  end

  private

  def reflag_ok flaggable
    msg = nil
    flags = current_user.get_flags(flaggable)
    unless flags.empty?
      if flags.collect(&:status).include? FLAG_STATUS_REJECTED
        msg = t 'flag.user_flagging_reject'
      elsif flags.collect(&:status).include? FLAG_STATUS_PENDING
        msg = t 'flag.user_flagging_pending'
      end
    end
    if msg
      flash[:error] = msg
      redirect_to flaggable_show_path(flags.first)
      false
    else
      true
    end
  end

  def layout_for_action
    if %w(index show edit).include?(params[:action])
      'admin_v2'
    elsif %w(new create).include?(params[:action])
      'application_v2'
    else
      'application'
    end
  end

  def show_url klass, id, anchor=nil
    url_for :controller => klass.to_s.pluralize, :action => 'show', :id => id, :anchor => anchor
  end

  def find_flaggable
    @klass = params[:flagger_type].constantize
    @flaggable = @klass.find(params[:flagger_id])
  end

  def find_flag
    @flag = Flag.find(params[:id])
  end

  def populate_flagger_type
    params[:flagger_type] = @flag.flaggable.class.to_s
    params[:flagger_id] = @flag.flaggable.id
    find_flaggable
  end

# disable the uniform plugin, otherwise the advanced search form is all @$@!# up
  def set_no_uniform_js
    if %w(new create).include?(params[:action])
      @no_uniform_js = true
    end
  end
end