gem 'minitest', '>= 5.0.0'
require 'mechanize'
require 'minitest/autorun'
require_relative 'save_reddit_page.rb'

class RedditScraperTest < Minitest::Test
  def setup
    @url = "https://www.reddit.com/r/aww"
    page = RedditScraper.new.save_images(@url)
  end


  def test_successful_page_get
    assert_equal Mechanize::Page, @page.is_a?(Mechanize::Page)
  end

end

