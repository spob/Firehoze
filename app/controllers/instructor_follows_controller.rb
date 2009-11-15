class InstructorFollowsController < ApplicationController
  before_filter :require_user
  before_filter :find_instructor, :except => [ :ajaxed ]

  verify :method => :post, :only => [:create], :redirect_to => :home_path
  verify :method => :delete, :only => [:destroy ], :redirect_to => :home_path

  def create
    if @instructor.verified_instructor?
      @instructor.followers << current_user unless @instructor.followed_by?(current_user)
      flash[:notice] = t('instructor_follows.create_success', :instructor => @instructor.login)
    else
      flash[:error] = t('instructor_follows.not_an_instructor', :user => @instructor.login)
    end
    redirect_to user_path(@instructor)
  end

  def destroy
    @instructor.followers.delete(current_user) if @instructor.followed_by?(current_user)
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
                current_user.followed_instructors.ascend_by_login.paginate(:per_page => @per_page, :page => params[:page])
            end
  end

  private

  def find_instructor
    @instructor = User.find(params[:id])
  end
end
