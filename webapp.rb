#! /bin/ruby

require 'sinatra'
require 'sinatra/flash'
require 'haml'
require 'securerandom'

require_relative 'models/init'
require_relative 'feed_pg'

class ImbaGraph < Sinatra::Application

  enable :sessions

  get '/' do
    'hello world'
  end

  get '/stats/:user/upload' do
    user = params['user']
    return haml(:no_user) unless get_items(user)
    haml(:upload, :locals => {'user' => user})
  end

  get '/stats/:user/:year/?' do
    username = params['user']
    user = User.find(:username => username)
    unless user
      return haml(:no_user, :locals => {'user' => username})
    end
    year = params['year'].to_i

    haml(:monthly_stats, :locals => {"user" => user, 'year' => year})
  end

  get '/stats/:user/?' do
    rows = session[:rows]
    if rows
      flash.now['success'] = "We added #{rows} check-ins"
      session[:rows] = nil
    end

    username = params['user']
    user = User.find(:username => username)
    unless user
      return haml(:no_user, :locals => {'user' => username})
    end

    haml(:yearly_stats, :locals => {"user" => user})
  end

  post '/upload' do
    user = params['username'].downcase
    filename = params['file_ref'][:tempfile]
    uuid = params['uuid']
    if uuid
      unless valid_uuid(uuid, user)
        redirect('/invalid')
      end
    else
      uuid = SecureRandom.uuid
    end
    
    rows = feed_pg(user, filename, uuid)
    session[:rows] = rows
    if params['uuid']
      redirect("/stats/#{user}")
    else
      session[:user] = user
      session[:uuid] = uuid
      redirect('/welcome')
    end
  end

  get '/welcome' do
    user = session[:user]
    uuid = session[:uuid]
    rows = session[:rows]
    session[:rows] = nil
    haml(:welcome, :locals => {'uuid' => uuid, 'user' => user, 'rows' => rows})
  end

  get '/invalid' do
    haml(:invalid)
  end
end

private
$months = ["dummy_month", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
def get_month_name(month)
  return $months[month]
end
