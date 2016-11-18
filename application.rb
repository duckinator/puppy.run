require 'sinatra'

class PuppyRun < Sinatra::Base
  %w[hitbox bandcamp].each { |job|
    require "./lib/jobs/#{job}.rb"
  }

  Jobs.constants.map(&Jobs.method(:const_get)).each { |job|
    job.new.spawn_update_loop!
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
    bc = Jobs::Bandcamp

    erb :music,
      layout: :default,
      locals: {
        title: 'Music',
        page: 'music',
        is_streaming: streaming?,
        album_date: bc.album_date,
        album_id: bc.album_id,
        album_slug: bc.album_slug,
        album_name: bc.album_name,
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

