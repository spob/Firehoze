class FlagsController < ApplicationController
  before_filter :require_user
  before_filter :find_flagger, :except => [ :new ]

  verify :method => :post, :only => [:create ], :redirect_to => :home_path

  def create
    flag = @flagger.flags.create(params[:flags])
    respond_to do |format|
      format.html {redirect_to :controller => @flagger.class.to_s.pluralize.downcase, :action => :show, :id => @flagger.id}
    end
  end

  def new
    new_flag
  end

  private

  def find_flagger
    @klass = params[:flagger_type].capitalize.constantize
    @flagger = @klass.find(params[:flagger_id])
  end

  def new_flag
    @klass = params[:flagger_type].capitalize.constantize
    @flag = @klass.flags.new
  end

end
