class Flag < ActiveRecord::Base
  belongs_to :flaggable, :polymorphic => true
  belongs_to :user
end
