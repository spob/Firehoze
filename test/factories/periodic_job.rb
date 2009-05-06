Factory.define :periodic_job, :default_strategy => :create do |f|
  f.add_attribute :type, 'PeriodicJob'
  f.name 'test job'
  f.job "puts 'hello'"
end

Factory.define :run_once_periodic_job, :default_strategy => :create, :parent => :periodic_job,
        :class => 'RunOncePeriodicJob' do |f|
  f.add_attribute :type, 'RunOncePeriodicJob'
end

Factory.define :run_interval_periodic_job, :default_strategy => :create, :parent => :periodic_job,
        :class => 'RunIntervalPeriodicJob' do |f|
  f.add_attribute :type, 'RunIntervalPeriodicJob'
  f.interval 30
end

Factory.define :run_at_periodic_job, :default_strategy => :create, :parent => :periodic_job,
        :class => 'RunAtPeriodicJob' do |f|
  f.add_attribute :type, 'RunAtPeriodicJob'
  f.run_at_minutes 60
end