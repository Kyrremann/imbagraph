#! /bin/ruby

require 'sinatra'
require 'haml'
require 'securerandom'

require_relative 'stats'
require_relative 'feed_pg'

class ImbaGraph < Sinatra::Application

  enable :sessions

  get '/' do
    get_complete_stats_haml('kyrremann')
  end

  get '/stats/:user/upload' do
    user = params['user']
    return haml(:no_user) unless get_items(user)
    haml(:upload, :locals => {'user' => user})
  end

  get '/stats/:user/:year/?' do
    get_yearly_stats_haml(params['user'], params['year'].to_i)
  end

  get '/stats/:user/?' do
    rows = session[:rows]
    get_complete_stats_haml(params['user'])
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
    haml(:welcome, :locals => {'uuid' => uuid, 'user' => user, 'rows' => rows})
  end

  get '/invalid' do
    haml(:invalid)
  end
end

private
def get_complete_stats_haml(user)
  items = get_items(user)
  unless items
    return haml(:no_user, :locals => {'user' => user})
  end

  stats = generate_yearly_stats(items)
  start_date = items.min(:created_day)
  end_date = Time.now.to_date
  days_in_periode = end_date - start_date
  haml(:yearly_stats, :locals => {
         "beers" => items.count,
         "first_beer" => first_beer(items).to_date,
         "avg_beers" => avg_beers(items, days_in_periode).round(2),
         "user" => user,
         "stats" => stats
       }
      )
end

def get_yearly_stats_haml(user, year)
  items = get_items(user)
  unless items
    return haml(:no_user)
  end
  beers = filter_by_year(items, year)
  stats = generate_monthly_stats(items, year)
  days_in_year = Date.new(year, 12, 31).yday
  haml(:monthly_stats, :locals => {
         "year" => year,
         "beers" => beers.count,
         "first_beer" => first_beer(beers),
         "avg_beers" => avg_beers(beers, days_in_year).round(2),
         "user" => user,
         "stats" => stats
       }
      )
end
