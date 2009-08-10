class FlagsController < ApplicationController
  before_filter :require_user
  before_filter :find_flagger

  verify :method => :post, :only => [:create ], :redirect_to => :home_path

  def create
    @flag = @flagger.flags.new(params[:flag])
    @flag.status = FLAG_STATUS_PENDING
    @flag.user = current_user
    if @flag.save
      flash[:notice] = t('flag.create_success')
      redirect_to :controller => @flagger.class.to_s.pluralize.downcase, :action => :show, :id => @flagger.id
    else
      render :action => "new"
    end
  end

  def new
    @flag = @flagger.flags.new
  end

  private

  def find_flagger
    @klass = params[:flagger_type].capitalize.constantize
    @flagger = @klass.find(params[:flagger_id])
  end
end
