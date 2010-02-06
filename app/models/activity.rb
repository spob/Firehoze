class Activity < ActiveRecord::Base
  belongs_to :trackable, :polymorphic => true
  belongs_to :group
  belongs_to :actor_user, :class_name => "User", :foreign_key => "actor_user_id"
  belongs_to :actee_user, :class_name => "User", :foreign_key => "actee_user_id"
  validates_presence_of :actor_user, :acted_upon_at
  named_scope :by_followed_instructors,
              lambda { |user|
                {
                        :include => [:group],
                        :joins => 'INNER JOIN instructor_follows ON instructor_follows.instructor_id = activities.actor_user_id ',
#                        :conditions => {:actor_user => { :followed_instructors_users => {:id => user.id }}},
                        :conditions => ['instructor_follows.user_id = ? AND (activities.group_id IS NULL OR groups.private = ? OR activities.group_id in (?))',
                                  user.id, false, (user ? user.group_ids.collect(&:group_id) : [] ) + [-1]]
                }
              }
  named_scope :visible_to_user,
              lambda{ |user|
                { :include => [:actor_user, :group],
                  #   :joins => 'LEFT OUTER JOIN groups ON groups.id = activities.group_id',
                  :conditions => ['(activities.group_id IS NULL OR groups.private = ? OR activities.group_id in (?))',
                                  false, (user ? user.group_ids.collect(&:group_id) : [] ) + [-1]]
                } }

  def self.compile
    # Strictly speaking, these calls are redundant since they've been shifted to observers...but, they can't hurt,
    # and will make sure nothing slips through the cracks.
    Lesson.ready.activity_compiled_at_null(:lock => true).each do |lesson|
      Lesson.transaction do
        lesson.compile_activity
      end
    end

    Review.activity_compiled_at_null(:lock => true).each do |review|
      Review.transaction do
        review.compile_activity
      end
    end

    Comment.public.activity_compiled_at_null(:lock => true).each do |comment|
      Comment.transaction do
        comment.compile_activity
      end
    end

    Credit.used.activity_compiled_at_null(:lock => true).each do |credit|
      Comment.transaction do
        credit.compile_activity
      end
    end

    Group.activity_compiled_at_null(:lock => true).each do |group|
      Group.transaction do
        group.compile_activity
      end
    end

    GroupLesson.active.activity_compiled_at_null(:lock => true).each do |group_lesson|
      GroupLesson.transaction do
        group_lesson.compile_activity
      end
    end

    GroupMember.active.activity_compiled_at_null(:lock => true).each do |group_member|
      GroupMember.transaction do
        group_member.compile_activity
      end
    end

    User.active.activity_compiled_at_null(:lock => true).each do |user|
      User.transaction do
        user.compile_activity
      end
    end

    User.active.instructors.instructor_signup_notified_at_not_null.instructor_activity_compiled_at_null.each do |user|
      User.transaction do
        user.compile_instructor_activity
      end
    end
  end
end