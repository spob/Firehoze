class Flag < ActiveRecord::Base
  belongs_to :flaggable, :polymorphic => true
  belongs_to :user
  validates_presence_of :user, :type, :status
end
