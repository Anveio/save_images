require_relative '4chan_save_images'
require_relative 'save_subreddit_images'

ARGV.each do |a|
  case a
  when /imgur.com\/r\//i
    ImgurSubScraper.new.save_images(ARGV[0])
  when /4chan.org/i
    ChanScraper.new(ARGV[0]).save_images
  when /reddit.com/i
    RedditScraper.new.save_images(ARGV[0])
  else
    puts "Invalid URL or the site is not supported."
  end
end
