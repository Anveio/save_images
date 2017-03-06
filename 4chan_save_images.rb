require 'mechanize'

class ChanScraper < Mechanize

  def initialize(input)
    @url = format_url(input.dup)
    @thread = unsecure_page
    @thread = @thread.get(@url)
    @thread_name = thread_name(@thread)
    @board_name = board_name(@thread)
    @directory = "E:\\Users\\Pictures\\#{@board_name}\\#{@thread_name}"
    @dl_count = 0
  end

  def save_images
    output_success if metadata_found?
    download_links(get_links_in_thread(@thread))
    output_info
  end

  private
    def format_url(input)
      url = input.chomp.downcase
      abort("ERROR: URL is not a string.") unless url.is_a?(String)

      # Mechanize needs "https://" at beginning of URL.
      # Also make sure "boards." is there too.
      url.sub!(url[/(.*?)4chan.org/,1], "https://boards.")
    end

    # Need to bypass HTTPS only websites.
    def unsecure_page
      a = Mechanize.new
      a.user_agent_alias = 'Mac Safari'
      a.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      return a
    end

    def thread_name(page)
      # Thread title will come after thread ID(some number between 1 and 12 digits)
      title = page.css('link[rel=canonical]').to_s[/\/[[:digit:]]{1,12}\/(.*?)">/, 1]
      # Sometimes the thread has no valid string name, use thread ID instead.
      title ||= page.css('link[rel=canonical]').to_s[/thread\/(.*?)">/, 1]
    end

    def board_name(page)
      board_name = page.at('.boardTitle')
      board_name.to_s[/<div class="boardTitle">\/(.*?)\//, 1]
    end

    def metadata_found?
      metadata = [@thread, @thread_name, @board_name]
      metadata.include?(nil)
    end

    def get_links_in_thread(thread)
      image_urls = thread.links_with(href: valid_4chan_regex)
    end

    def desired_file_type
      /webm/
    end

    def download_links(links)
      links.each do |link|
        if link.to_s =~ desired_file_type
          file = link.click
          unless invalid?(link.to_s)
            file.save! "#{@directory}\\#{link.to_s}"
            print(".") and $stdout.flush
            @dl_count += 1
          end
        end
      end
    end

    # Prevent file name errors when saving
    def invalid?(save_name)
      save_name.include?("http")
    end

    def valid_4chan_regex
      /i.4cdn.org\/#{@board_name}\/[[:alnum:]]{11,14}/
    end

    def output_success
      puts "Connection Established. Downloading thread: \"#{@thread_name}\" from /#{@board_name}/ to #{@directory}"
    end

    def output_info
      puts "\nFinished downloading #{@dl_count} images from thread: \"#{@thread_name}\" on /#{@board_name}/."
    end
end
