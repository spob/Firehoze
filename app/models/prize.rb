class Prize < ActiveRecord::Base
  belongs_to_many :contest, :through => :contest_prize
end
