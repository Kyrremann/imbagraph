#! /bin/ruby

require 'sinatra'
require 'haml'

require_relative 'stats'

class ImbaGraph < Sinatra::Application

  get '/' do
    get_complete_stats_haml('kyrremann')
  end

  get '/stats/:user/:year/?' do
    get_yearly_stats_haml(params['user'], params['year'].to_i)
  end

  get '/stats/:user/?' do
    get_complete_stats_haml(params['user'])
  end
end

private
def get_complete_stats_haml(user)
  items = get_items(user)
  unless items
    return haml(:no_user)
  end

  stats = generate_yearly_stats(items)
  start_date = items.min(:created_day)
  end_date = Time.now.to_date
  days_in_periode = end_date - start_date
  haml :yearly_stats, :locals => {
         "beers" => items.count,
         "first_beer" => first_beer(items).to_date,
         "avg_beers" => avg_beers(items, days_in_periode).round(2),
         "user" => user,
         "stats" => stats
       }
end

def get_yearly_stats_haml(user, year)
  items = get_items(user)
  unless items
    return haml(:no_user)
  end
  beers = filter_by_year(items, year)
  stats = generate_monthly_stats(items, year)
  days_in_year = Date.new(year, 12, 31).yday
  haml :monthly_stats, :locals => {
         "year" => year,
         "beers" => beers.count,
         "first_beer" => first_beer(beers),
         "avg_beers" => avg_beers(beers, days_in_year).round(2),
         "user" => user,
         "stats" => stats
       }
end
