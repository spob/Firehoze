class ContestPrize < ActiveRecord::Base
  belongs_to :contest
  belongs_to :prize
end
