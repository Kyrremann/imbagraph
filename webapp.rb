#! /bin/ruby

require 'sinatra'
require 'haml'

require_relative 'stats'

class ImbaGraph < Sinatra::Application

  get '/' do
    get_stats_haml('kyrremann')
  end

  get '/stats/:user' do
    get_stats_haml(params['user'])
  end
end

private
def get_stats_haml(user)
  items = get_items(user)
  unless items
    return haml(:no_user)
  end

  yearly_stats = generate_yearly_stats(items)
  haml :stats, :locals => {
         "beers" => items.count,
         "unique_beers" => distinct(items).count,
         "first_beer" => first_beer(items).to_date,
         "avg_beers" => avg_beers(items).round(2),
         "beers_per_yr_day" => beers_per_day(items),
         "beers_per_day" => beers_per_day(items, yr=false),
         "yearly_stats" => yearly_stats
       }
end
