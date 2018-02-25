#! /bin/ruby

require 'date'
require 'json'
require 'sequel'

def create_table(db, username)
  unless db.table_exists?(username)
    db.create_table username do
      primary_key :id
      String :beer_name
      String :beer_type
      Float :beer_abv
      Integer :beer_ibu
      String :beer_url
      String :brewery_name
      String :brewery_country
      String :brewery_city
      String :brewery_url
      String :checking_url
      String :comment
      String :flavor_profiles
      String :purchase_venue
      Integer :rating_score
      String :serving_type
      String :venue_name
      String :venue_city
      String :venue_state
      String :venue_country
      Float :venue_lat
      Float :venue_lng
      Date :created_day
      Date :created_yr_day
      Time :created_at
    end
  end
end

def add_data(db, username, untappd_json)
  if db.table_exists?(username)
    items = db[username.to_sym]
    added = 0

    untappd_json.each do | check_in |
      created_at = check_in['created_at']
      next if items.where(created_at: created_at).count != 0

      beer_name = check_in['beer_name']
      beer_type = check_in['beer_type']
      beer_abv  = check_in['beer_abv'].to_f
      beer_ibu  = check_in['beer_ibu'].to_i
      beer_url = check_in['beer_url']
      brewery_name = check_in['brewery_name']
      brewery_country = check_in['brewery_country']
      brewery_city = check_in['brewery_city']
      brewery_url = check_in['brewery_url']
      checking_url = check_in['checking_url']
      comment = check_in['comment']
      flavor_profiles = check_in['flavor_profiles']
      purchase_venue = check_in['purchase_venue']
      rating_score = check_in['rating_score'].to_i
      serving_type = check_in['serving_type']
      venue_name = check_in['venue_name']
      venue_city = check_in['venue_city']
      venue_state = check_in['venue_state']
      venue_country = check_in['venue_country']
      venue_lat = check_in['venye_lat']
      venue_lng = check_in['venue_lng']
      created_yr_day = DateTime.parse(created_at)
      if created_yr_day.hour < 6
        created_yr_day = created_yr_day - 1
      end

      items.insert(:beer_name => beer_name,
                   :beer_type => beer_type,
                   :beer_abv => beer_abv,
                   :beer_ibu => beer_ibu,
                   :beer_url => beer_url,
                   :brewery_name => brewery_name,
                   :brewery_country => brewery_country,
                   :brewery_city => brewery_city,
                   :brewery_url => brewery_url,
                   :checking_url => checking_url,
                   :comment => comment,
                   :flavor_profiles => flavor_profiles,
                   :purchase_venue => purchase_venue,
                   :rating_score => rating_score,
                   :serving_type => serving_type,
                   :venue_name => venue_name,
                   :venue_city => venue_city,
                   :venue_state => venue_state,
                   :venue_country => venue_country,
                   :venue_lat => venue_lat,
                   :venue_lng => venue_lng,
                   :created_day => created_at,
                   :created_yr_day => created_yr_day,
                   :created_at => created_at)
      added += 1
    end

    p "Added #{added} new rows to #{username}"
  else
    p "Can't find table for #{username}"
  end
  return added
end

def populate_db(username, filename)
  file = File.read(filename)
  untappd_json = JSON.parse(file)

  database_url = ENV['DATABASE_URL'] ? ENV['DATABASE_URL'] : 'postgres://postgres:postgres@localhost:5432/postgres'
  db = Sequel.connect(database_url)

  create_table(db, username)
  add_data(db, username, untappd_json)
end

def store_user(username, uuid)
  database_url = ENV['DATABASE_URL'] ? ENV['DATABASE_URL'] : 'postgres://postgres:postgres@localhost:5432/postgres'
  db = Sequel.connect(database_url)
  unless db.table_exists?('users')
    db.create_table 'users' do
      primary_key :id
      String :uuid
      String :user
    end
  end

  items = db['users'.to_sym]
  return if items.where(user: username).count != 0
  items.insert(:user => username, :uuid => uuid)
end

def valid_uuid(uuid, user)
  database_url = ENV['DATABASE_URL'] ? ENV['DATABASE_URL'] : 'postgres://postgres:postgres@localhost:5432/postgres'
  db = Sequel.connect(database_url)
  items = db['users'.to_sym]
  row = items.where(user: user).first
  return false if row.nil?
  return row[:uuid] == uuid
end

def feed_pg(username, filename, uuid)
  store_user(username, uuid)
  populate_db(username, filename)
end

if __FILE__ == $PROGRAM_NAME
  username = ARGV[0]
  filename = ARGV[1]

  unless username and filename
    p "Missing username or file"
    p "ruby feed_pg.rb kyrremann untappd-05-02-2018.json"
    exit(1)
  end

  unless File.exist?(filename)
    p "Can't find #{filename}"
    exit(1)
  end

  populate_db(username, filename)
end
