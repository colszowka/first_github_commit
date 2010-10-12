require 'helper'

class TestFirstGithubCommit < Test::Unit::TestCase

  after_finding 'thoughtbot', 'shoulda' do
    should_return_a_hash
    should_have_value 'tsaleh', :at => 'author.name'
    should_have_value '4b825dc642cb6eb9a060e54bf8d69288fbee4904', :at => "tree"
    should_have_value "2007-03-14T11:11:47-07:00", :at => "authored_date"
  end
  
  after_finding 'rails', 'rails' do
    should_return_a_hash
    should_have_value 'David Heinemeier Hansson', :at => 'author.name'
    should_have_value 'dhh', :at => "author.login"
    should_have_value "2004-11-23T17:04:44-08:00", :at => "committed_date"
  end
  
  after_finding 'lifo', 'fast_context' do
    should_return_a_hash
    should_have_value 'Pratik Naik', :at => 'author.name'
    should_have_value 'lifo', :at => "author.login"
    should_have_value "2009-09-29T04:30:54-07:00", :at => "committed_date"
  end
  
  after_initializing_for 'lifo', 'fast_context' do
    should("have page 1 for page number") { assert_equal 1, subject.page }
    should("have yaml hash") { assert subject.yaml.kind_of?(Hash) }
    should "have 'http://github.com/lifo/fast_context/commits/master?page=1' for github_url" do
      assert_equal 'http://github.com/lifo/fast_context/commits/master?page=1', subject.github_url
    end
  end
  
  context "finding a non-existing repo" do
    should "raise FirstGithubCommit::RepoNotFound" do
      assert_raise FirstGithubCommit::RepoNotFound do 
        FirstGithubCommit.find('colszowka', 'missing')
      end
    end
  end
end
