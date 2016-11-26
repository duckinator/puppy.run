require 'json'
require 'date'
require 'tessellator/fetcher'

class PuppyRun
  class Jobs
    class Howamidoing
      @@statuses = {}

      def self.view
        nil
      end

      def self.statuses
        @@statuses
      end

      def self.updated_at
        nil # Returning nil means don't make it the homepage.
      end

      # Use the howamidoing API to check if I'm streaming.
      # Set @@statuses to the result.
      def update!
        response = Tessellator::Fetcher.new.call('get', 'https://howamidoing-duckinator.herokuapp.com/status.json')
        @@statuses = JSON.parse(response.body)['statuses']
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
