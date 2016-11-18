require 'json'
require 'tessellator/fetcher'

class PuppyRun
  class Jobs
    class Hitbox
      # Use the Hitbox API to check if I'm streaming.
      # Set @@is_streaming to the result.
      def self.is_streaming!
        response = Tessellator::Fetcher.new.call('get', 'https://api.hitbox.tv/user/duckinator')
        is_live = JSON.parse(response.body)['is_live']

        is_live == '1'
      end

      # Check if we're streaming (cached).
      def self.streaming?
        @@is_streaming
      end

      def self.spawn_loop!
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
