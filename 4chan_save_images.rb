require 'mechanize'

class ChanScraper < Mechanize
  def save_images(input)
    @url = format_url(input.dup)
    @thread = unsecure_page
    @thread = @thread.get(@url)

    @thread_name = thread_name(@thread)
    @board_name = board_name(@thread)
    @directory = "E:\\Users\\Pictures\\#{@board_name}\\#{@thread_name}"
    @dl_count = 0

    puts "Connection Established, downloading thread: \"#{@thread_name}\""

    file_name = @thread.links_with(href: valid_4chan_regex)
    file_name.each do |link|
      if link.to_s =~ /webm/
        file = link.click
        file.save! "#{@directory}\\#{link.to_s}" unless invalid?(link.to_s)
        @dl_count += 1
      end
    end

    puts "Finished downloading #{@dl_count} images from thread: \"#{@thread_name} on /#{@board_name}/"
  end

  private
    def format_url(input)
      url = input.chomp.downcase
      abort("ERROR: URL is not a string.") unless url.is_a?(String)
      abort("ERROR: Invalid 4chan URL.") unless url_has_4chan?(url)

      #Mechanize needs "https://" at beginning of URL. Also make sure "boards." is there too.
      url.sub!(url[/(.*?)4chan.org/,1], "https://boards.")
    end

    # Prevent file name errors when saving
    def invalid?(save_name)
      if save_name.include? "http"
        return true
      end
    end

    # Factory for making Mechanize classes
    def unsecure_page
      a = Mechanize.new
      a.user_agent_alias = 'Mac Safari'
      a.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      return a
    end

    def thread_name(page)
      # Thread title will come after thread ID(some number between 1 and 12 digits)
      title = page.css('link[rel=canonical]').to_s[/\/[[:digit:]]{1,12}\/(.*?)">/, 1]
      # Sometimes the thread has no valid string name, use thread ID number instead.
      title ||= page.css('link[rel=canonical]').to_s[/thread\/(.*?)">/, 1]
    end

    def board_name(page)
      board_name = page.at('.boardTitle')
      board_name.to_s[/<div class="boardTitle">\/(.*?)\//, 1]
    end

    def url_has_4chan?(url)
      url =~ /4chan.org/ ? true : false
    end

    def valid_4chan_regex
      /is.4chan.org\/#{@board_name}\/[[:alnum:]]{11,14}/
    end
end
