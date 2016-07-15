require 'mechanize'

class ImgurScraper < Mechanize
  def save_images(url)
    page = get(url)
    directory = url[/\/r\/(.*?)\//, 1]

    thumbnails = page.images_with(:src => /i.imgur.com\/[[:alnum:]]{6,10}/)
    thumbnails.each do |link|
      begin
        transact do
          #puts "Code has made it this far"
          agent = Mechanize.new
          page = agent.get(link.to_s.chomp('.jpg')) # use thumbnail URL to go to full image
          image = page.image_with(:src => /i.imgur.com\/[[:alnum:]]{6,10}/).fetch
          save_name = link.to_s.split('/')[-1]
          image.save! "E:\\Users\\Pictures\\test_directory\\#{directory}\\#{save_name}"
        end
      rescue
        $stderr.puts link
      end
    end
  end
  #self
end#.new.save_images(ARGV[0])
ImgurScraper.new.save_images("http://imgur.com/r/aww")

