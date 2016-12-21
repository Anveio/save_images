require 'mechanize'
require 'net/https'

class RedditScraper < Mechanize
  def save_images(input)
    @url = format_url(input.dup)
    page = unsecure_page
    page = get(@url)


  end

  private
    def format_url(url)
      abort("ERROR: URL is not a string.") unless url.is_a?(String)

      url.insert(0, 'http://') unless url[0..6] == 'http://'

      if url[-1, 1] != "/"
        url << "/"
      end

      return url
    end

    def unsecure_page(url) #factory for making unsecure Nokogiri pages
      url = Uri.parse(url)
      http = NET::HTTP.new( url.host, url.port)
    end
end
