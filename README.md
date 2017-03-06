# save_images
Ruby command line tool using the Mechanize gem that downloads the images from a given imgur.com/r/* URL or 4chan thread.

### How to use
This requires the Ruby [Mechanize](https://github.com/sparklemotion/mechanize) gem.

```
gem install Mechanize
```

The script accepts valid imgur.com/r/* links and 4chan thread links

```
ruby save_images.rb "imgur.com/r/aww/top/year"
ruby save_images.rb "boards.4chan.org/wg/thread/<thread-id>"
```
