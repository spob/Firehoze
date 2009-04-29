# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # Format a date and adjust the timezone for the user's timezone
  def format_date_time(the_date)
    the_date.strftime("%b %d, %Y %I:%M%p") if the_date
  end

  def format_date(the_date)
    the_date.strftime("%b %d, %Y") if the_date
  end
end
