require 'mechanize'

class ImgurSubScraper < Mechanize
  def save_images(input)
    @url = format_url(input.dup)

    page = get(@url)

    subreddit = subreddit_name(page)
    puts "Connection Established: Downloading #{subreddit}"
    directory = "E:\\Users\\Pictures\\#{subreddit}"

    thumbnails = page.images_with(:src => /i.imgur.com\/[[:alnum:]]{6,10}/)
    thumbnails.each do |link|
      begin
        transact do
          short_link = link.to_s.chomp('b.jpg')
          save_name = link.to_s.split('/')[-1]

          page = Mechanize.new.get(short_link) # use thumbnail URL to go to full image

          #if retrieving an image fails, assume it's a gif/mp4
          if page.image_with(:src => /i.imgur.com\/[[:alnum:]]{6,10}/) == nil
            video = Mechanize.new.get("#{short_link}.mp4")
            video.save! "#{directory}\\#{save_name.gsub(/.jpg/, '')}.mp4"
          else
            pic = page.image_with(:src => /i.imgur.com\/[[:alnum:]]{6,10}/).fetch
            pic.save! "#{directory}\\#{save_name}"
          end
        end
      rescue
        $stderr.puts link
      end
    end
    puts "Finished downloading images."
  end

  private
    def format_url(input)
      abort("ERROR: URL is not a string.") unless input.is_a?(String)
      url = input.chomp.downcase

      url.insert(0, 'http://') unless url[0..6] == 'http://'

      if url[-1, 1] != "/"
        url << "/"
      end

      return url
    end

    def subreddit_name(page)
      subreddit_name = page.at("title")
      subreddit_name.to_s[/r\/(.*?) on Imgur/, 1]
    end
end
