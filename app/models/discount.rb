# A discount allows a user to purchase a SKU as a reduced price.
# The discount will be referenced by any line items for which the discount was granted.
# This class is a base class. Subclasses will implement actual discount logic
class Discount < ActiveRecord::Base
  belongs_to :sku
  has_many   :line_items
  validates_presence_of :sku

  attr_accessible :active, :type

#  TODO: restrict multiple active discounts with same minimum qty 

# Basic paginated listing finder
  def self.list(sku, page)
    paginate :page => page, :conditions => { :sku_id => sku }, :order => 'minimum_quantity',
             :per_page => Constants::ROWS_PER_PAGE
  end

  # Can only delete a Discount if it has not be used to purchase any line items
  def can_delete?
    self.line_items.empty?
  end
end
