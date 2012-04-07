class Prize < ActiveRecord::Base
  belongs_to_many :contests, :through => :contest_prize
end
