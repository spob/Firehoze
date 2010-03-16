class Promotion < ActiveRecord::Base
  validates_presence_of :code, :promotion_type, :expires_at, :price
  validates_uniqueness_of :code, :case_sensitive => false
  validates_length_of :code, :maximum => 15, :allow_nil => true
  validates_length_of :promotion_type, :maximum => 50, :allow_nil => true
  validates_numericality_of :price, :greater_than_or_equal_to => 0, :allow_nil => true

  before_validation :strip_white


  private

  def strip_white
    self.code = code.strip unless code.nil?
  end
end
