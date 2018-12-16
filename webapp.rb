#! /bin/ruby

require 'sinatra'
require 'sinatra/flash'
require 'haml'
require 'securerandom'

require_relative 'models/init'
require_relative 'routes/init'
require_relative 'feed_pg'

class ImbaGraph < Sinatra::Application
  enable(:sessions)

  get '/' do
    haml(:index)
  end

  post '/upload' do
    username = params['username'].downcase
    filename = params['file_ref'][:tempfile]
    uuid = params['uuid']

    if not uuid.empty?
      user = User.find(:username => username, :uuid => uuid)
      unless user
        flash.next['error'] = "Not valid uuid for user"
        redirect("/stats/#{username}/upload")
      end
    else
      user = User.find(:username => username)
      unless user
        user = User.new(:username => username)
      end
      uuid = SecureRandom.uuid
      user.uuid = uuid
      user.save
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

  get '/welcome/?' do
    username = session[:username]
    uuid = session[:uuid]
    rows = session[:rows]
    session[:rows] = nil
    haml(:welcome, :locals => {uuid: uuid, username: username, rows: rows})
  end

  get '/users/?' do
    haml(:users)
  end

  get '/about/?' do
    haml(:about)
  end
end
