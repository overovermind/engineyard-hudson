$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../../lib'))
require 'bundler/setup'
require 'engineyard-hudson'

Before do
  @tmp_root      = File.dirname(__FILE__) + "/../../tmp"
  @active_project_folder = @tmp_root
  @home_path     = File.expand_path(File.join(@tmp_root, "home"))
  @lib_path      = File.expand_path(File.dirname(__FILE__) + "/../../lib")
  @fixtures_path = File.expand_path(File.dirname(__FILE__) + "/../../fixtures")
  FileUtils.rm_rf   @tmp_root
  FileUtils.mkdir_p @home_path
  ENV['HOME'] = @home_path
end
