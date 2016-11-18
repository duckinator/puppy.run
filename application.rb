require 'sinatra'

class PuppyRun < Sinatra::Base
  %w[hitbox].each { |job|
    require "./lib/jobs/#{job}.rb"
  }

  Jobs.constants.map(&Jobs.method(:const_get)).each { |job|
    job.spawn_loop!
  }



  set :public_folder, File.dirname(__FILE__) + '/static'

  get '/' do
    is_streaming = Jobs::Hitbox.streaming?

    erb :index,
      layout: :default,
      locals: {
        title: nil,
        page: 'home',
        is_streaming: is_streaming,
      }
  end

  get '/stream' do
    erb :stream,
      layout: :default,
      locals: {
        title: 'Stream',
        page: 'stream',
      }
  end

  get '/code' do
    erb :code,
      layout: :default,
      locals: {
        title: 'Code',
        page: 'code',
      }
  end

  get '/music' do
    erb :music,
      layout: :default,
      locals: {
        title: 'Music',
        page: 'music',
      }
  end
end

