class PromotionsController < ApplicationController
  before_filter :require_user
  before_filter :find_promotion, :only => [ :show ]

  permit ROLE_PAYMENT_MGR

  layout 'admin'

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :put, :only => [:update ], :redirect_to => :home_path
  verify :method => :delete, :only => [:destroy ], :redirect_to => :home_path

  @@promo_types = [ [ 'Free Credits', 'FreeCreditPromo'] ]

  def self.types
    @@promo_types
  end

  def index
    @promotions = Promotion.list params[:page], cookies[:per_page] || ROWS_PER_PAGE
  end

  def new
    @promotion = Promotion.new(:expires_at => 30.days.since, :price => 0)
    
    # disable the uniform plugin, otherwise the advanced search form is all @$@!# up
    @no_uniform_js = true
  end

  def create
    @promotion =  Promotion.new(params[:promotion])
    if @promotion.save
      flash[:notice] = t 'promotion.create_success'
      redirect_to promotions_path
    else
      render :action => :new
    end
  end

  private

  def find_promotion
    @promotion = Promotion.find(params[:id])
  end

  def layout_for_action
    'admin'
  end
end
