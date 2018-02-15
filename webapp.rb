#! /bin/ruby

require 'sinatra'
require 'haml'

require_relative 'stats'

class ImbaGraph < Sinatra::Application

  get '/' do
    items = get_items('kyrremann')
    unless items
      return haml(:no_user)
    end

    yearly_stats = generate_yearly_stats
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
end
