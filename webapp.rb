#! /bin/ruby

require 'sinatra'
require 'haml'

require_relative 'stats'

class ImbaGraph < Sinatra::Application
  get '/' do
    haml :index
  end

  get '/stats/:username/?' do
    items = get_items(params[:username])
    unless items
      return haml(:no_user)
    end

    haml :stats, :locals => {
           :beers => items.count,
           :unique_beers => distinct(items).count,
           :this_year => last_days(items, Time.now.yday).count,
           :this_month => last_days(items, Time.now.mday).count,
           :this_week => last_days(items, get_wday).count,
           :most_per_day => most_per_day(items),
           :most_unique_per_day => "-1",
           :avg_abv => avg_abv(items).round(2),
           :max_abv => max_abv(items),
           :min_abv => min_abv(items),
           :countries => distinct(items, column_name="brewery_country").count,
           :breweries => distinct(items, column_name="brewery_name").count,

           :beers_per_yr_day => beers_per_day(items),
           :beers_per_day => beers_per_day(items, yr=false)
         }
  end

  def get_wday
    day = Time.now.wday
    case day
    when 0
      return 7
    else
      return day
    end
  end
end
