class WishListsController < ApplicationController
  include SslRequirement

  if APP_CONFIG[CONFIG_ALLOW_UNRECOGNIZED_ACCESS]
    before_filter :require_user, :except => :create
  else
    before_filter :require_user
  end
  before_filter :find_lesson

  verify :method => :post, :only => [:create ], :redirect_to => :home_path
  verify :method => :destroy, :only => [:delete ], :redirect_to => :home_path

  def create
    if current_user
      if @lesson.owned_by?(current_user)
        flash[:error] = t('wish.already_owned')
      elsif @lesson.instructor == current_user
        flash[:error] = t('wish.you_are_author')
      elsif current_user.on_wish_list?(@lesson)
        flash[:error] = t('wish.already_wished')
      else
        current_user.wishes << @lesson
        flash[:notice] = t('wish.create_success')
      end
      redirect_to lesson_path(@lesson)
    else
      store_location lesson_path(@lesson)
      flash[:error] = t('wish.must_logon')
      redirect_to new_user_session_url
    end
  end

  def destroy
    if current_user.on_wish_list?(@lesson)
      current_user.wishes.delete(@lesson)
      flash[:notice] = t('wish.delete_success')
    else
      flash[:notice] = t('wish.not_on_wishlist')
    end
    redirect_to lesson_path(@lesson)
  end

  private

  # Called by thebefore filter to retrieve the lesson based on the id that
  # was passed in as a parameter
  def find_lesson
    @lesson = Lesson.find(params[:id])
  end
end
