require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'engineyard-hudson/appcloud_env'

describe Engineyard::Hudson::AppcloudEnv do
  def appcloud_env
    @appcloud_env ||= Engineyard::Hudson::AppcloudEnv.new
  end
  
  def find_environments(options = {})
    appcloud_env.find_environments(options)
  end
  
  before do
    @tmp_root   = File.dirname(__FILE__) + "/../tmp"
    @home_path  = File.expand_path(File.join(@tmp_root, "home"))
    FileUtils.mkdir_p(@home_path)
    ENV['EYRC'] = File.join(@home_path, ".eyrc")
  end
  describe ".find_environments - no args" do
    it "return [nil, nil] unless it has reason to return something else" do
      appcloud_env.stub(:fetch_environment).and_raise(EY::NoEnvironmentError)
      find_environments.should == []
    end
    it "returns [env_name, account_name] if finds one env 'hudson' in any account" do
      appcloud_env.should_receive(:fetch_environment).with("hudson", nil).and_return(EY::Model::App.new(123, EY::Model::Account.new(789, 'mine')))
      appcloud_env.should_receive(:fetch_environment).with("hudson_server", nil).and_raise(EY::NoEnvironmentError)
      appcloud_env.should_receive(:fetch_environment).with("hudson_production", nil).and_raise(EY::NoEnvironmentError)
      appcloud_env.should_receive(:fetch_environment).with("hudson_server_production", nil).and_raise(EY::NoEnvironmentError)
      find_environments.should == [['hudson', 'mine']]
    end
    it "returns many result pairs" do
      appcloud_env.should_receive(:fetch_environment).with("hudson", nil).and_return(EY::Model::App.new(123, EY::Model::Account.new(789, 'mine')))
      appcloud_env.should_receive(:fetch_environment).with("hudson_server", nil).and_raise(EY::NoEnvironmentError)
      appcloud_env.should_receive(:fetch_environment).with("hudson_server_production", nil).and_raise(EY::NoEnvironmentError)
      appcloud_env.should_receive(:fetch_environment).with("hudson_production", nil) {
        raise EY::MultipleMatchesError, <<-ERROR.gsub(/^\s+/, '')
           hudson_production # ey <command> --environment='hudson_production' --account='mine'
           hudson_production # ey <command> --environment='hudson_production' --account='yours'
        ERROR
      }
      find_environments.should == [['hudson', 'mine'], ['hudson_production', 'mine'], ['hudson_production', 'yours']]
    end
  end
end
