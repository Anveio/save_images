require 'mechanize'

class ChanScraper < Mechanize
  def save_images(url)
    @url = sanitize_url(url.dup)
    thread = unsecure_page
    thread = thread.get(@url)
    puts "Connection Established, downloading thread"

    @thread_name = thread_name(thread)
    @board_name = board_name(thread)
    @directory = "E:\\Users\\Pictures\\#{@board_name}\\#{@thread_name}"

    file_name = thread.links_with(href: /i.4cdn.org\/#{@board_name}\/[[:alnum:]]{11,14}/)
    file_name.each do |link|
      if link.to_s =~ /gif|jpg|webm|png/
        file = link.click
        file.save! "#{@directory}//#{link.to_s}" unless invalid?(link.to_s)
      end
    end

    puts "Finished downloading thread: #{@thread_name} from /#{@board_name}/"
  end

  private
  def sanitize_url(input)
    url = input.chomp
    abort("ERROR: URL is not a string.") unless url.is_a?(String)
    abort("ERROR: Invalid 4chan URL.") unless url =~ /4chan.org/
    #Mechanize needs "http" in order to retrieve a page
    url.insert(0, 'https://') unless url[0..7] == 'https://'

    if url.include? '#'
      url.chomp!(url[url.index('#')..-1])
    end

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

  def thread_name(page)
    thread_name = page.css('.subject')[0]
    thread_name.to_s[/<span class="subject">(.*?)<\/span>/, 1]
  end

  def board_name(page)
    board_name = page.at('.boardTitle')
    board_name.to_s[/<div class="boardTitle">\/(.*?)\//, 1]
  end
end

#ChanScraper.new.save_images(ARGV[0])
