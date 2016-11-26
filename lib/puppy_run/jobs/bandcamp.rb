require 'tessellator/fetcher'
require 'nokogiri'
require 'date'

class PuppyRun
  class Jobs
    class Bandcamp
      # TODO: Make _name and _slug dynamic.
      @@album_name = 'Unfinished Thunder'
      @@album_slug = 'unfinished-thunder'
      @@album_id = nil
      @@album_date = nil

      def initialize
        @fetcher = Tessellator::Fetcher.new
      end

      def self.view
        :music
      end

      def self.album
        {
          date: @@album_date,
          id: @@album_id,
          slug: @@album_slug,
          name: @album_name,
        }
      end

      def self.updated_at
        @@album_date
      end

      def album_id_from_doc(doc)
        meta_og_video = doc.css('meta[property="og:video"]').first
        video_url = meta_og_video.attribute('content').value
        album_equals_id = video_url.split('/')[5] # "album=<album id>"
        album_id = album_equals_id.split('=')[1]

        album_id
      end

      def date_published_from_doc(doc)
        meta_date_published = doc.css('meta[itemprop="datePublished"]').first
        date_string = meta_date_published.attribute('content').value
        date_parts = date_string.match(/(\d{4})(\d{2})(\d{2})/).captures

        DateTime.new(*date_parts.map(&:to_i))
      end

      def fetch_newest_album!
        req = @fetcher.call('get', 'https://pupper.bandcamp.com/album/' + @@album_slug)
        doc = Nokogiri::HTML(req.body)

        @@album_id = album_id_from_doc(doc)
        @@album_date = date_published_from_doc(doc)
      end

      def update!
        fetch_newest_album!
      end

      def spawn_update_loop!
        Thread.new do
          loop do
            update!
            sleep 1 * 60 * 60 # 1 hour.
          end
        end
      end
    end
  end
end
