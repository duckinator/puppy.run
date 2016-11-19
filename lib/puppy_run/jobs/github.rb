require 'tessellator/fetcher'
require 'json'
require 'puppy_run/github'

class PuppyRun
  class Jobs
    class GitHub
      @@repo = nil
      @@push_time = nil
      @@tag = nil
      @@repo_description = nil

      def initialize
        @fetcher = Tessellator::Fetcher.new
      end

      def self.view
        :code
      end

      def self.tag_push_event
        return nil if @@repo.nil?

        {
          repo: @@repo,
          push_time: @@push_time,
          tag: @@tag,
          repo_description: @@repo_description,
          changelog: @@changelog,
        }
      end

      def self.updated_at
        @@push_time
      end

      def fetch_events!(page = 2)
        req = @fetcher.call('get', 'https://api.github.com/users/duckinator/events?page=' + page.to_s)
        events = JSON.parse(req.body)

        # Handle API Rate limiting. (By doing nothing.)
        return if events['message']

        # Find a tag event. This usually means a release.
        event = events.find { |event|
          event['type'] == 'CreateEvent' &&
            event['payload']['ref_type'] == 'tag'
        }

        # The events API supports pagination for up to ten pages.
        # Go through the first ten pages until an event is found.
        if event.nil? && page < 10
#          return fetch_events!(page + 1)
        end

        # If no tag event is found, leave values at what
        # they currently are.
        # 
        # If there was a tag found previously, it'll remain the
        # latest release. If there wasn't, everything will
        # remain nil.
        return unless event

        @@repo = event['repo']['name']
        @@push_time = DateTime.parse(event['created_at'])
        @@tag = event['payload']['ref']
        @@repo_description = event['payload']['description']
        @@changelog = ::PuppyRun::GitHub.changelog(@@repo, @@tag)
      end

      def update!
        fetch_events!
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
