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
    @dl_count = 0

    file_name = thread.links_with(href: /i.4cdn.org\/#{@board_name}\/[[:alnum:]]{11,14}/)
    file_name.each do |link|
      if link.to_s =~ /gif|jpg|webm|png/
        file = link.click
        file.save! "#{@directory}\\#{link.to_s}" unless invalid?(link.to_s)
        @dl_count += 1
      end
    end

    puts "Finished downloading #{@dl_count} images from thread: #{@thread_name} on /#{@board_name}/"
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
    #thread title will come after thread ID(some number between 1 and 12 digits)
    title = page.css('link[rel=canonical]').to_s[/\/[[:digit:]]{1,12}\/(.*?)">/, 1]
    #sometimes the thread has no valid string name
    title ||= page.css('link[rel=canonical]').to_s[/thread\/(.*?)">/, 1]
  end

  def board_name(page)
    board_name = page.at('.boardTitle')
    board_name.to_s[/<div class="boardTitle">\/(.*?)\//, 1]
  end
end
