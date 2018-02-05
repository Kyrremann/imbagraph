#! /bin/ruby
# coding: utf-8

require 'sequel'

def get_items(name="kyrremann")
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

def last_days(items, days, yr=true)
  items.where(get_column_name(yr) => (Date.today - days)..(Date.today))
end

def beers_per_day(items, yr=true)
  column_name = get_column_name(yr)
  items.group_and_count(column_name).order(column_name)
end

def most_per_day(items, yr=true)
  beers_per_day(items, yr).order(Sequel.desc(:count)).first[:count]
end

private
def get_column_name(yr)
  (yr ? "created_yr_day" : "created_day").to_sym
end

def get_database_url
  ENV['DATABASE_URL'] ? ENV['DATABASE_URL'] : 'postgres://postgres:postgres@localhost:5432/postgres'
end
