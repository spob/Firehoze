class Discount < ActiveRecord::Base
  belongs_to :sku   
  validates_presence_of :sku
end
