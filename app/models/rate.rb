class Rate < ActiveRecord::Base
  belongs_to :user
  belongs_to :rateable, :polymorphic => true
  
  attr_accessible :rate, :dimension

  scope :lesson_rates, :conditions => { :rateable_type => "Lesson" }
  scope :by_rateable_id,
              lambda{ |rateable| {:conditions => { :rateable_id => rateable.id } }
              }
end
