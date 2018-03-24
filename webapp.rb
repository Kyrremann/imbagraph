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

  get '/stats/:username/upload' do
    username = params['username'].downcase
    user = User.find(:username => username)
    return haml(:no_user, :locals => {'username' => username}) unless user
    haml(:upload, :locals => {'username' => username})
  end

  get '/stats/:username/:year/?' do
    username = params['username'].downcase
    user = User.find(:username => username)
    return haml(:no_user, :locals => {'user' => username}) unless user
    year = params['year'].to_i

    haml(:monthly_stats, :locals => {"user" => user, 'year' => year})
  end

  get '/stats/:username/?' do
    username = params['username'].downcase
    user = User.find(:username => username)
    return haml(:no_user, :locals => {'username' => username}) unless user
    haml(:yearly_stats, :locals => {"user" => user})
  end

  post '/upload' do
    username = params['username'].downcase
    filename = params['file_ref'][:tempfile]
    uuid = params['uuid']
    if uuid
      user = User.find(:uuid => uuid, :username => username)
      unless user
        flash.next['error'] = "Not valid uuid for user"
        redirect("/stats/#{username}/upload")
      end
    else
      uuid = SecureRandom.uuid
      user = User.create(:uuid => uuid, :username => username)
    end
    
    rows = populate(user, filename)
    session[:rows] = rows
    if params['uuid']
      flash.next['success'] = "We added #{rows} check-ins"
      redirect("/stats/#{username}")
    else
      session[:username] = username
      session[:uuid] = uuid
      redirect('/welcome')
    end
  end

  get '/welcome' do
    username = session[:username]
    uuid = session[:uuid]
    rows = session[:rows]
    session[:rows] = nil
    haml(:welcome, :locals => {'uuid' => uuid, 'username' => username, 'rows' => rows})
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
