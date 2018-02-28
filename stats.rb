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

def filter_by_month(items, month)
  items.where(Sequel.extract(:month, :created_at) => month)
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

def avg_beers(items, days_in_periode)
  items.count / (days_in_periode).to_f
end

def generate_yearly_stats(items)
  years = (items.min(:created_at).year..Time.now.year)
  data = {}

  years.each do | year |
    days_in_year = Date.new(year, 12, 31).yday
    if year == Time.now.year
      days_in_year = Time.now.yday
    end

    beers = filter_by_year(items, year)
    data[year.to_s] = create_periode(beers, days_in_year)
  end

  return data
end

def generate_monthly_stats(items, year)
  data = {}
  items = filter_by_year(items, year)

  (1..12).each do | month |
    days_in_month = Date.new(year, month, -1).day
    beers = filter_by_month(items, month)
    data[month] = create_periode(beers, days_in_month)
  end

  return data
end

private
def create_periode(items, days_in_periode)
  if items.count == 0
    return {
      "total" => 0,
      "total_unique" => 0,
      "max_abv" => 0,
      "avg_abv" => 0,
      "countries" => 0,
      "breweries" => 0,
      "venues" => 0,
      "most_per_day" => 0,
      "most_unique_per_day" => 0,
      "avg_per_day" => 0
    }
  else
    return {
      "total" => items.count,
      "total_unique" => distinct(items).count,
      "max_abv" => max_abv(items),
      "avg_abv" => avg_abv(items).round(2),
      "countries" => distinct(items, column_name="brewery_country").count,
      "breweries" => distinct(items, column_name="brewery_name").count,
      "venues" => distinct(items, column_name="venue_name").count,
      "most_per_day" => most_per_day(items),
      "most_unique_per_day" => -1,
      "avg_per_day" => avg_beers(items, days_in_periode).round(2)
    }
  end
end

def get_column_name(yr)
  (yr ? "created_yr_day" : "created_day").to_sym
end

def get_database_url
  ENV['DATABASE_URL'] ? ENV['DATABASE_URL'] : 'postgres://postgres:postgres@localhost:5432/postgres'
end
