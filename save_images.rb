require_relative '4chan_save_images'
require_relative 'save_subreddit_images'

ARGV.each do |a|
  case a
  when /imgur.com\/r\//
    ImgurSubScraper.new.save_images(ARGV[0])
  when /4chan.org/
    ChanScraper.new.save_images(ARGV[0])
  else
    puts "Invalid URL not site not supported"
  end
end
