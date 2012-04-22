# Install hook code here
unless defined?(Rails.root.to_s)
  $stderr.puts "$0 must be run from RAILS_ROOT with -rconfig/boot"
  exit
end

require 'fileutils'
FileUtils.rm_rf(Rails.root.to_s + '/script/process') # remove the old stubs first
FileUtils.cp_r(Rails.root.to_s + '/vendor/plugins/irs_process_scripts/script', Rails.root.to_s + '/script/process')
