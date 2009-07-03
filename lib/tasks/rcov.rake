# Generates test coverage data.
# in order to use this task, you must first install the rcov gem
# http://github.com/relevance/rcov/tree/master
# note these should not be part of the environment.rb
# Run the following if you haven't already:
# gem sources -a http://gems.github.com
# Install the gem(s):
# sudo gem install relevance-rcov

# Run command
# rake test:coverage

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'
require 'shoulda/tasks'
namespace :test do
  desc 'Measures test coverage'
  task :coverage do
    rm_f "coverage"
    rm_f "coverage.data"
    rcov = "rcov -Itest --rails --aggregate coverage.data -T -x \" rubygems/*,/Library/Ruby/Site/*,gems/*,rcov*\""
    system("#{rcov} --no-html test/unit/*_test.rb test/unit/helpers/*_test.rb")
    system("#{rcov} --no-html test/functional/*_test.rb")
    system("#{rcov} --html test/integration/*_test.rb")
    system("open coverage/index.html") if PLATFORM['darwin']
  end
end
