require 'json'
require 'tessellator/fetcher'

class PuppyRun
  class Jobs
    class Hitbox
      def initialize
        @fetcher = Tessellator::Fetcher.new
      end

      def newest_album_name
        'Unfinished Thunder'
      end

      def newest_album_slug
        'unfinished-thunder'
      end

      def fetch_newest_album_id
        request = @fetcher.get('https://pupper.bandcamp/album/' + newest_album_slug)
        doc = Nokogiri::HTML(request.body)
        meta_og_video = doc.css('meta[property="og:video"]').first
        video_url = meta_og_video.property('content').value
        album_equals_id = video_url.split('/')[5] # "album=<album id>"
        album_id = album_equals_id.split('=')[1]

        album_id
      end

      def newest_album_id
        @@newest_album_id
      end

      def spawn_loop!
        Thread.new do
          loop do
            @@newest_album_id = fetch_newestalbum_id
            sleep 1 * 60 * 60 # 1 hour.
          end
        end
      end
    end
  end
end
