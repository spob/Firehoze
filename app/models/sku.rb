# The class is a super class for a variety of different SKU types
class Sku < ActiveRecord::Base
  validates_presence_of     :sku,         :type, :description
  validates_uniqueness_of   :sku,         :case_sensitive => false
  validates_length_of       :sku,         :maximum => 30, :allow_nil => true
  validates_length_of       :type,        :maximum => 50
  validates_length_of       :description, :maximum => 150, :allow_nil => true

  def self.list(page)
    paginate :page => page, :order => 'sku',
            :per_page => Constants::ROWS_PER_PAGE
  end

  def can_delete? user
    user.is_sysadmin?
  end
end
