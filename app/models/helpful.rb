# A helpful record indicates whether or not a user found a particular review helpful. The
# helpful models maps a user to a review and has a flag which, if true, indicates the user
# found the review helpful and if false, they did not find it helpful
class Helpful < ActiveRecord::Base
  belongs_to :user
  belongs_to :review

  validates_presence_of :user, :review, :helpful
end
