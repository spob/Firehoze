class InstructorFollowsController < ApplicationController
  before_filter :require_user
  before_filter :find_instructor, :except => [ :ajaxed ]
  before_filter :set_per_page, :only => [ :ajaxed ]

  verify :method => :post, :only => [:create], :redirect_to => :home_path
  verify :method => :delete, :only => [:destroy ], :redirect_to => :home_path

  def create
    if @instructor.verified_instructor?
      current_user.follow(@instructor)
      flash[:notice] = t('instructor_follows.create_success', :instructor => @instructor.login)
    else
      flash[:error] = t('instructor_follows.not_an_instructor', :user => @instructor.login)
    end
    redirect_to user_path(@instructor)
  end

  def destroy
    current_user.stop_following(@instructor)
    flash[:notice] = t('instructor_follows.delete_success', :instructor => @instructor.login)
    redirect_to user_path(@instructor)
  end

  # SUPPORTING AJAX PAGINATION
  def ajaxed
    @collection = params[:collection]
    @instructors =
            case @collection
              when 'followers'
#                current_user.groups.ascend_by_name.paginate(:per_page => @per_page, :page => params[:page])
              when 'following'
                current_user.followed_instructors.active.paginate(:per_page => @per_page, :page => params[:page])
              when 'students'
                current_user.students.paginate(:per_page => @per_page, :page => params[:page])
            end
  end

  private

  def find_instructor
    @instructor = User.find(params[:id])
  end

  def set_per_page
    @per_page =
            if params[:per_page]
              params[:per_page]
            else
              5
            end
  end
end
