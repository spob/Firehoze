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

  private

  def find_promotion
    @promotion = Promotion.find(params[:id])
  end

  def layout_for_action
    'admin'
  end
end
