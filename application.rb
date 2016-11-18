require 'sinatra'

class PuppyRun < Sinatra::Base
  %w[hitbox].each { |job|
    require "./lib/jobs/#{job}.rb"
  }

  Jobs.constants.map(&Jobs.method(:const_get)).each { |job|
    job.new.spawn_loop!
  }

  def streaming?
    Jobs::Hitbox.streaming?
  end

  set :public_folder, File.dirname(__FILE__) + '/static'

  get '/' do
    erb :index,
      layout: :default,
      locals: {
        title: nil,
        page: 'home',
        is_streaming: streaming?,
      }
  end

  get '/stream' do
    erb :stream,
      layout: :default,
      locals: {
        title: 'Stream',
        page: 'stream',
        is_streaming: streaming?,
      }
  end

  get '/code' do
    erb :code,
      layout: :default,
      locals: {
        title: 'Code',
        page: 'code',
        is_streaming: streaming?,
      }
  end

  get '/music' do
    erb :music,
      layout: :default,
      locals: {
        title: 'Music',
        page: 'music',
        is_streaming: streaming?,
      }
  end

  get '/writing' do
    erb :writing,
      layout: :default,
      locals: {
        title: 'Writing',
        page: 'writing',
        is_streaming: streaming?,
      }
  end
end

