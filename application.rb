require 'sinatra'
require 'json'
require 'tessellator/fetcher'

class IsStreamingJob
  # Use the Hitbox API to check if I'm streaming.
  # Set @@is_streaming to the result.
  def self.is_streaming!
    response = Tessellator::Fetcher.new.call('get', 'https://api.hitbox.tv/user/duckinator')
    is_live = JSON.parse(response.body)['is_live']
    @@is_streaming = (is_live == '1')
  end

  # Check if we're streaming (cached).
  def self.streaming?
    @@is_streaming
  end

  def self.is_streaming_loop
    Thread.new do
      loop do
        IsStreamingJob.is_streaming!
        sleep 5 * 60 # 5 minutes.
      end
    end
  end
  is_streaming_loop
end

class PuppyRun < Sinatra::Base
  set :public_folder, File.dirname(__FILE__) + '/static'

  def streaming?
    IsStreamingJob.streaming?
  end

  get '/' do
    erb :index,
      layout: :default,
      locals: {
        title: nil,
        is_streaming: streaming?,
      }
  end
end

