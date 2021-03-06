# Allow an admin to see a history of user logons
class UserLogonsController < ApplicationController
  include SslRequirement
  
  before_filter :require_user

  # admins only
  permit "#{ROLE_ADMIN} or #{ROLE_COMMUNITY_MGR}"

  layout 'admin'

  def index
    @search = UserLogon.last_90_days.descend_by_created_at.search(params[:search])
    @user_logons = @search.paginate(:include => [:user],
                                    :page => params[:page],
                                    :per_page => (cookies[:per_page] || ROWS_PER_PAGE))
  end

  def graph
    @graph = open_flash_chart_object(900,500,"/user_logons/graph_code")
  end

  @@num_days = 90

  def graph_code
    data1 = []

	sql = ActiveRecord::Base.connection()
	now = Time.zone.now
    max_users = 0
    @@num_days.times do |i|
      x = now - (i * 86400)
      y = User.unique_logons_by_date(i).count
      max_users = y if y > max_users
      data1 << ScatterValue.new(x.to_i,y)
    end

    dot = HollowDot.new
    dot.size = 3
    dot.halo_size = 2
    dot.tooltip = "#date:d M y#<br>Users: #val#"

    line = ScatterLine.new("#DB1750", 3)
    line.values = data1
    line.default_dot_style = dot

    x = XAxis.new
    x.set_range((now - (@@num_days * 86400)).to_i, now.to_i)
    x.steps = 86400

    labels = XAxisLabels.new
    labels.text = "#date: l jS, M Y#"
    labels.steps = 86400
    labels.visible_steps = 2
    labels.rotate = 90

    x.labels = labels

    y = YAxis.new
    y.set_range(0,max_users,5)

    chart = OpenFlashChart.new
    title = Title.new("Unique User Logons")

    chart.title = title
    chart.add_element(line)
    chart.x_axis = x
    chart.y_axis = y

    render :text => chart, :layout => false
  end

  def date_to_i the_date
    Time.parse(the_date.to_s).to_i
  end
end
