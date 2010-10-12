require 'rubygems'
require 'bundler'
Bundler.setup(:default, :development)
require 'simplecov'
SimpleCov.start
require 'test/unit'
require 'shoulda'
require 'pp'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'first_github_commit'
require 'ruby_ext'

class Test::Unit::TestCase

  def self.after_finding(user, repo)
    context "After finding #{user}/#{repo}" do
      setup { @yaml = FirstGithubCommit.find(user, repo) }
      subject { @yaml }
      
      yield
    end
  end
  
  def self.after_initializing_for(user, repo)
    context "After initializing for #{user}/#{repo}" do
      setup { @commit = FirstGithubCommit.new(user, repo) }
      subject { @commit }
      
      yield
    end
  end

  def self.should_return_a_hash
    should "return a hash" do
      assert subject.instance_of?(Hash)
    end
  end
  
  def self.should_have_value(expected_value, options)
    should "have #{expected_value} in #{options[:at]}" do
      assert_equal expected_value, subject.find_nested(options[:at])
    end
  end
end
