require 'mechanize'

class ImgurScraper < Mechanize
  def save_images(url)
    @url = sanitize_input(url.dup)

    get @url
    directory = @url[/\/r\/(.*?)\//, 1]

    thumbnails = page.images_with(:src => /i.imgur.com\/[[:alnum:]]{6,10}/)
    thumbnails.each do |link|
      begin
        transact do
          agent = Mechanize.new
          page = agent.get(link.to_s.chomp('.jpg')) # use thumbnail URL to go to full image
          image = page.image_with(:src => /i.imgur.com\/[[:alnum:]]{6,10}/).fetch
          save_name = link.to_s.split('/')[-1]
          image.save! "E:\\Users\\Pictures\\#{directory}\\#{save_name}"
        end
      rescue
        $stderr.puts link
      end
    end
  end

  private
  def sanitize_input(url)
    abort("ERROR: URL is not a string.") unless url.is_a?(String)

    url.insert(0, 'http://') unless url[0..6] == 'http://'

    if url[-1, 1] != "/"
      url << "/"
    end

    return url
  end
end

ImgurScraper.new.save_images(ARGV[0])

