# The class is a super class for a variety of different SKU types. A SKU is an item that can be
# purchased in the online store (e.g., it can be added to a shopping cart)
class Sku < ActiveRecord::Base
  validates_presence_of     :sku,         :type, :description
  validates_uniqueness_of   :sku,         :case_sensitive => false
  validates_length_of       :sku,         :maximum => 30, :allow_nil => true
  validates_length_of       :type,        :maximum => 50
  validates_length_of       :description, :maximum => 150, :allow_nil => true

  has_many :line_items

  # Basic paginated listing finder
  def self.list(page)
    paginate :page => page, :order => 'sku',
            :per_page => ROWS_PER_PAGE
  end

  # Only admins can delete a SKU
  def can_delete? user
    user and user.is_admin?
  end

  # Only admins can edit a SKU
  def can_edit? user
    user and user.is_admin?
  end
end
