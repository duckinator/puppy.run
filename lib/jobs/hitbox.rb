require 'json'
require 'tessellator/fetcher'

class PuppyRun
  class Jobs
    class Hitbox
      @@is_streaming = false

      def self.view
        :stream
      end

      # Check if we're streaming (cached).
      def self.streaming?
        @@is_streaming
      end

      def self.updated_at
        if Hitbox.streaming?
          Time.now
        else
          # If not streaming, return a date that'll
          # always be older than everything else.
          Time.new(1900, 1, 1)
        end
      end

      # Use the Hitbox API to check if I'm streaming.
      # Set @@is_streaming to the result.
      def update!
        response = Tessellator::Fetcher.new.call('get', 'https://api.hitbox.tv/user/duckinator')
        is_live = JSON.parse(response.body)['is_live']

        @@is_streaming = (is_live == '1')
      end

      def spawn_update_loop!
        Thread.new do
          loop do
            update!
            sleep 5 * 60 # 5 minutes.
          end
        end
      end
    end
  end
end
