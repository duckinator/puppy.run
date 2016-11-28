require 'sinatra'

class PuppyRun < Sinatra::Base
  %w[hitbox bandcamp github howamidoing].each { |job|
    require "puppy_run/jobs/#{job}.rb"
  }

  JOBS = Jobs.constants.map(&Jobs.method(:const_get))

  JOBS.each { |job|
    job.new.spawn_update_loop!
  }

  TITLES = {
    stream: 'Live Streams',
    code: 'Code',
    music: 'Music',
  }

  def most_recently_updated
    JOBS.reject { |x| x.updated_at.nil? }.sort_by(&:updated_at).last
  end

  def most_recently_updated_name
    most_recently_updated.to_s.split(':').last.downcase.to_sym
  end

  def generate_kwargs(view, page=nil, title=nil)
    {
      layout: :default,
      locals: {
        title: title || TITLES[view],
        page: page || view.to_s,
        is_streaming: Jobs::Hitbox.streaming?,
        album: Jobs::Bandcamp.album,
        tag_push_event: Jobs::GitHub.tag_push_event,
        statuses: Jobs::Howamidoing.statuses,
        most_recently_updated: most_recently_updated_name,
      }
    }
  end

  set :public_folder, File.dirname(__FILE__) + '/static'

  get '/' do
    erb :index,
      **generate_kwargs(:index)
  end

  get '/stream' do
    erb :stream,
      **generate_kwargs(:stream)
  end

  get '/code' do
    erb :code,
      **generate_kwargs(:code)
  end

  get '/music' do
    erb :music,
      **generate_kwargs(:music)
  end
end

