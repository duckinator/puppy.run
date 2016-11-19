require 'tessellator/fetcher'
require 'json'
require 'kramdown'

class PuppyRun
  class GitHub
    class << self
      def changelog(repo, tag)
        changelog_file = get_changelog_file(repo)

        raw_changelog = get("https://raw.githubusercontent.com/#{repo}/#{tag}/#{changelog_file}")

        separator = /## \[#{tag.gsub(/^v(\d)/, 'v?\1').gsub('.', '\\.')}\]/
        parts = raw_changelog.split(separator)

        if parts.length == 1
          return '<p>No change log found.</p>'
        end

        changelog = parts.last.split("\n## ").first

        Kramdown::Document.new(changelog).to_html
      end

      private
      def get(url)
        Tessellator::Fetcher.new.call('get', url).body
      end

      def get_changelog_file(repo)
        files = JSON.parse(get("https://api.github.com/repos/#{repo}/contents/"))

        files.find { |f| f['name'] =~ /^changelog/i }['name']
      end
    end
  end
end
