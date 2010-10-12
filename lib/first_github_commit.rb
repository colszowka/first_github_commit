require 'bundler'
Bundler.setup(:default)

require 'redirect_follower'
require 'yaml'

class FirstGithubCommit
  class TooManyRequests < StandardError; end;
  class RepoNotFound < StandardError; end;

  attr_reader :user, :repo, :requests_made, :page
  
  DEBUG = false
  MAX_REQUESTS = 30
  
  def initialize(user, repo)
    @user, @repo = user, repo
    @requests_made = 0
    @range = (1..130)
    
    # Make sure the repo even exists!
    raise RepoNotFound if RedirectFollower.new(url_for_page(1)).response.kind_of?(Net::HTTPNotFound)
    
    find_upper_limit
    find_page_number
  end
  
  def yaml
    @yaml ||= YAML.load(last_response.body)["commits"].last
  end
  
  def github_url
    @github_url ||= "http://github.com/#{user}/#{repo}/commits/master?page=#{page}"
  end
  
  def self.find(user, repo)
    FirstGithubCommit.new(user, repo).yaml
  end
  
  private
  
    attr_reader :last_response, :upper_limit, :lower_limit, :range
    attr_writer :range
  
    def upper_limit
      range.last
    end
    
    def lower_limit
      range.first
    end
  
    def find_upper_limit
      while get_page(range.last) and not last_response.kind_of?(Net::HTTPNotFound)
        debug range.last
        debug last_response.inspect
        self.range = (upper_limit..upper_limit*2)
      end
    end
    
    def find_page_number
      while last_response.kind_of?(Net::HTTPNotFound) or range.to_a.length > 2
        self.range = (range.first..((range.last - range.first)/2 + range.first))
        last_response = get_page(range.last)
        debug last_response.inspect
        if last_response.kind_of?(Net::HTTPSuccess)
          self.range = (range.last..(range.last+range.last-range.first))
        end
        debug range.inspect
      end

      if last_response.kind_of?(Net::HTTPSuccess) 
        @page = range.last
      else
        @page = range.first
        last_response = get_page(page)
      end
      
      page
    end
  
    def get_page(page_number)
      raise FirstGithubCommit::TooManyRequests if @requests_made > MAX_REQUESTS
      @requests_made += 1
      @last_response = RedirectFollower.new(url_for_page(page_number)).response
    end
  
    def base_url
      @base_url ||= "http://github.com/api/v2/yaml/commits/list/#{user}/#{repo}/master"
    end
    
    def url_for_page(page_number)
      base_url + "?page=#{page_number}"
    end
    
    def debug(*args)
      return nil unless DEBUG == true
      args.each do |arg|
        puts arg
      end
    end
end
