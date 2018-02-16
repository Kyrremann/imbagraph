#! /bin/ruby

require 'sinatra'
require 'haml'

require_relative 'stats'

class ImbaGraph < Sinatra::Application

  get '/' do
    get_complete_stats_haml('kyrremann')
  end

  get '/stats/:user/:year' do
    get_yearly_stats_haml(params['user'], params['year'])
  end

  get '/stats/:user' do
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
  haml :yearly_stats, :locals => {
         "beers" => items.count,
         "first_beer" => first_beer(items).to_date,
         "avg_beers" => avg_beers(items).round(2),
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
  haml :monthly_stats, :locals => {
         "year" => year,
         "beers" => beers.count,
         "first_beer" => first_beer(beers),
         "avg_beers" => avg_beers(beers).round(2),
         "stats" => stats
       }
end
