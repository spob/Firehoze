class Contest < ActiveRecord::Base
  has_one :group
  has_many :prizes, :through => :contest_prizes



end
