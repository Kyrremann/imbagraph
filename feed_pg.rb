#! /bin/ruby

require 'date'
require 'json'
require 'sequel'

file = File.read('untappd-05-02-2018.json')
untappd_json = JSON.parse(file)

database_url = ENV['DATABASE_URL'] ? ENV['DATABASE_URL'] : 'postgres://postgres:postgres@localhost:5432/postgres'
DB = Sequel.connect(database_url)

DB.create_table :kyrremann do
  primary_key :id
  String :beer_name
  String :beer_type
  String :brewery_name
  String :brewery_country
  Float :beer_abv
  Integer :beer_ibu
  Integer :rating_score
  Date :created_day
  Date :created_yr_day
  Time :created_at
end

items = DB[:kyrremann]

untappd_json.each do | check_in |
  beer_name = check_in['beer_name']
  beer_type = check_in['beer_type']
  beer_abv  = check_in['beer_abv'].to_f
  beer_ibu  = check_in['beer_ibu'].to_i
  brewery_name = check_in['brewery_name']
  brewery_country = check_in['brewery_country']
  created_at = check_in['created_at']
  created_yr_day = DateTime.parse(created_at)
  if created_yr_day.hour < 6
    created_yr_day = created_yr_day - 1
  end
  rating_score = check_in['rating_score'].to_i

  items.insert(:beer_name => beer_name,
               :beer_type => beer_type,
               :beer_abv => beer_abv,
               :beer_ibu => beer_ibu,
               :brewery_name => brewery_name,
               :brewery_country => brewery_country,
               :created_day => created_at,
               :created_yr_day => created_yr_day,
               :created_at => created_at,
               :rating_score => rating_score)
end
