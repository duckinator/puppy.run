require 'json'
require 'tessellator/fetcher'

class PuppyRun
  class Jobs
    class Hitbox
      # Use the Hitbox API to check if I'm streaming.
      # Set @@is_streaming to the result.
      def is_streaming!
        response = Tessellator::Fetcher.new.call('get', 'https://api.hitbox.tv/user/duckinator')
        is_live = JSON.parse(response.body)['is_live']

        is_live == '1'
      end

      # Check if we're streaming (cached).
      def streaming?
        @@is_streaming
      end

      def updated_at
        if streaming?
          Time.now
        else
          # If not streaming, return a date that'll
          # always be older than everything else.
          Time.new(1900, 1, 1)
        end
      end

      def spawn_loop!
        Thread.new do
          loop do
            @@is_streaming = self.is_streaming!
            sleep 5 * 60 # 5 minutes.
          end
        end
      end
    end
  end
end
