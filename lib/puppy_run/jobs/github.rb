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
          changelog: ::PuppyRun::GitHub.changelog(@@repo, @@tag),
        }
      end

      def self.updated_at
        @@push_time
      end

      def fetch_events!
        req = @fetcher.call('get', 'https://api.github.com/users/duckinator/events')
        events = JSON.parse(req.body)
        # Find a tag event. This usually means a release.
        event = events.find { |event|
          event['type'] == 'CreateEvent' &&
            event['payload']['ref_type'] == 'tag'
        }

        # If no tag event is found, leave values at what
        # they currently are.
        # 
        # If there was a tag found previously, it'll remain the
        # latest release. If there wasn't, everything will
        # remain nil.
        return unless event

        @@repo = event['repo']['name']
        @@push_time = DateTime.parse(event['repo']['created_at'])
        @@tag = event['payload']['ref']
        @@repo_description = event['payload']['description']
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
