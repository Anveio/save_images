require 'mechanize'

class TestMech < Mechanize
  def process
    url= 'http://imgur.com/r/aww'
    get url
    directory = url[/\/r\/(.*?)\//, 1]

    thumbnails = page.images_with(:src => /i.imgur.com\/[[:alnum:]]{4,10}/)
    thumbnails.each do |link|
      begin
        transact do
          agent = Mechanize.new
          page = agent.get(link.to_s.chomp('.jpg')) # use thumbnail URL to go to full image
          image = page.image_with(:src => /i.imgur.com\/[[:alnum:]]{4,10}/).fetch
          save_name = link.to_s.split('/')[-1]
          image.save! "#E:\\Users\\Pictures\\{directory}\\#{save_name}"
        end
      rescue
        $stderr.puts link
      end
    end
  end
end

page = TestMech.new
page.process
