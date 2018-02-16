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

def generate_monthly_stats(items, year)
  data = {}
  items = filter_by_year(items, year)

  (1..12).each do | month |
    beers = filter_by_month(items, month)
    month_name = get_month_name(month)
    if beers.count == 0
      data[month_name] = empty_periode
    else
      data[month_name] = {
        "total" => beers.count,
        "total_unique" => distinct(beers).count,
        "max_abv" => max_abv(beers),
        "avg_abv" => avg_abv(beers).round(2),
        "countries" => distinct(beers, column_name="brewery_country").count,
        "breweries" => distinct(beers, column_name="brewery_name").count,
        "most_per_day" => most_per_day(beers),
        "most_unique_per_day" => -1,
        "avg_per_day" => -1
      }
    end
  end

  return data
end

private
def empty_periode
  return {
        "total" => 0,
        "total_unique" => 0,
        "max_abv" => 0,
        "avg_abv" => 0,
        "countries" => 0,
        "breweries" => 0,
        "most_per_day" => 0,
        "most_unique_per_day" => 0,
        "avg_per_day" => 0
  }
end

def get_column_name(yr)
  (yr ? "created_yr_day" : "created_day").to_sym
end

def get_database_url
  ENV['DATABASE_URL'] ? ENV['DATABASE_URL'] : 'postgres://postgres:postgres@localhost:5432/postgres'
end

def get_month_name(month)
  case month
  when 1
    "January"
  when 2
    "February"
  when 3
    "March"
  when 4
    "April"
  when 5
    "May"
  when 6
    "June"
  when 7
    "July"
  when 8
    "August"
  when 9
    "September"
  when 10
    "October"
  when 11
    "November"
  when 12
    "December"
  end
end
