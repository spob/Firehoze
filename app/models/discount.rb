class Discount < ActiveRecord::Base
  belongs_to :sku
  has_many   :line_items
  validates_presence_of :sku

#  TODO: restrict multiple active discounts with same minimum qty 

  def self.list(sku, page)
    paginate :page => page, :conditions => { :sku_id => sku }, :order => 'minimum_quantity',
            :per_page => Constants::ROWS_PER_PAGE
  end

  def can_delete?
    self.line_items.empty?
  end
end
