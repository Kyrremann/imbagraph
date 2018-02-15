#! /bin/ruby
# coding: utf-8

require 'sequel'

def get_items(name)
  db = Sequel.connect(get_database_url)
  db.table_exists?(name) ? db[name.to_sym] : nil
end

def distinct(items, column_name="beer_name")
  items.distinct(column_name.to_sym)
end

def filter_by_year(items, year)
  items.where(Sequel.extract(:year, :created_at) => year)
end

def filter_by_brewery_country(items, country)
  items.where(brewery_country: country)
end

def avg_abv(items)
  items.avg(:beer_abv)
end

def max_abv(items)
  items.max(:beer_abv)
end

def min_abv(items)
  items.where(Sequel.lit('beer_abv > 0')).min(:beer_abv)
end

def last_days(items, days, yr=false)
  items.where(get_column_name(yr) => (Date.today - days)..(Date.today))
end

def beers_per_day(items, yr=false)
  column_name = get_column_name(yr)
  items.group_and_count(column_name).order(column_name)
end

def most_per_day(items, yr=false)
  beers_per_day(items, yr).order(Sequel.desc(:count)).first[:count]
end

def first_beer(items)
  items.min(:created_at)
end

def avg_beers(items)
  items.count / (Time.now.to_date - items.min(:created_day)).to_f
end

def generate_yearly_stats(items)
  years = (items.min(:created_at).year..Time.now.year)
  data = {}

  years.each do | year |
    beers = filter_by_year(items, year)
    data[year.to_s] = {
      "total" => beers.count,
      "total_unique" => distinct(beers).count,
      "max_abv" => max_abv(beers),
      "avg_abv" => avg_abv(beers).round(2),
      "countries" => distinct(beers, column_name="brewery_country").count,
      "breweries" => distinct(beers, column_name="brewery_name").count,
      "most_per_day" => most_per_day(beers),
      "most_unique_per_day" => -1
    }
  end

  return data
end


private
def get_column_name(yr)
  (yr ? "created_yr_day" : "created_day").to_sym
end

def get_database_url
  ENV['DATABASE_URL'] ? ENV['DATABASE_URL'] : 'postgres://postgres:postgres@localhost:5432/postgres'
end
