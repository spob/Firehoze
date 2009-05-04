Factory.define :periodic_job, :default_strategy => :create, :class => PeriodicJob do |f|
  f.add_attribute :type, 'PeriodicJob'  
  f.job "puts 'hello'"
end