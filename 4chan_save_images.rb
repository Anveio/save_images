require 'mechanize'

class ChanScraper < Mechanize
  def save_images(url)
    @url = sanitize_url(url.dup)
    @thread_name = @url.split("/").fetch(-1)
    @board_name = @url.split("/").fetch(-4)
    @directory = "E:\\Users\\Pictures\\#{@board_name}\\#{@thread_name}"

    thread = unsecure_page
    thread = thread.get(@url)
    puts "Connection Established, downloading thread"

    file_name = thread.links_with(href: /i.4cdn.org\/#{@board_name}\/[[:alnum:]]{11,14}/)
    file_name.each do |link|
      if link.to_s =~ /gif|jpg|webm|png/
        file = link.click
        file.save! "#{@directory}//#{link.to_s}" unless invalid?(link.to_s)
      end
    end
  end

  private
  def sanitize_url(url)
    abort("ERROR: URL is not a string.") unless url.is_a?(String)
    abort("ERROR: Invalid 4chan URL.") unless url =~ /4chan.org/
    #Mechanize needs "http" in order to retrieve a page
    url.insert(0, 'https://') unless url[0..7] == 'https://'

    #Need final character to be a slash because @thread_name and
    #@board_name count backwards from the last slash
    if url[-1, 1] != "/"
      url << "/"
    end
    return url
  end

  #prevent file name errors when saving
  def invalid?(save_name)
    if save_name.include? "http"
      return true
    end
  end

  def unsecure_page #factory for making Mechanize classes
    a = Mechanize.new
    a.user_agent_alias = 'Mac Safari'
    a.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    return a
  end
end

#ChanScraper.new.save_images(ARGV[0])
