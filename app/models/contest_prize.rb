class ContestPrize < ActiveRecord::Base
  belongs_to :group
  belongs_to :prize
end
