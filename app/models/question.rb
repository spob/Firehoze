class Question < ActiveRecord::Base
  belongs_to :quiz, :counter_cache => true
  validates_presence_of :question, :quiz
  validates_uniqueness_of :question, :scope => :quiz_id
  validates_length_of :question, :maximum => 500, :allow_nil => true
end
