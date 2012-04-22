# Install hook code here
unless defined?(Rails.root.to_s)
  $stderr.puts "$0 must be run from Rails.root.to_s with -rconfig/boot"
  exit
end

require 'fileutils'
FileUtils.rm_rf(Rails.root.to_s + '/script/process')