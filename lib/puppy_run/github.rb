require 'tessellator/fetcher'
require 'json'
require 'kramdown'

class PuppyRun
  class GitHub
    class << self
      def changelog(repo, tag)
        changelog_file = get_changelog_file(repo)

        raw_changelog = get("https://raw.githubusercontent.com/#{repo}/#{tag}/#{changelog_file}")

        separator = "## [#{tag}]\n"
        changelog = separator + raw_changelog.split(separator).last.split('## ').first

        Kramdown::Document.new(changelog).to_html
      end

      private
      def get(url)
        Tessellator::Fetcher.new.call('get', url).body
      end

      def get_changelog_file(repo)
        files = JSON.parse(get("https://api.github.com/repos/#{repo}/contents/"))

        files.find { |f| f['name'] =~ /^changelog/i }
      end
    end
  end
end
