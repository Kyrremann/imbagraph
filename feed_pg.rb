#! /bin/ruby

require_relative 'models/init'
require 'date'
require 'json'

def populate(user, filename)
  file = File.read(filename)
  untappd_json = JSON.parse(file)

  rows = 0
  untappd_json.each do | check_in |
    checked_in = check_in['created_at']
    next if Checkin.find(:user_id => user.id, :checked_in => checked_in)

    brewery_name = check_in['brewery_name']
    brewery = Brewery.find(:name => brewery_name)
    unless brewery
      brewery = Brewery.create(:name => brewery_name,
                               :country => check_in['brewery_country'],
                               :city => check_in['brewery_city'],
                               :untappd_url => check_in['brewery_url'])
    end

    beer_name = check_in['beer_name']
    beer = Beer.find(:name => beer_name)
    unless beer
      beer = Beer.new(:name => beer_name,
                      :type => check_in['beer_type'],
                      :abv  => check_in['beer_abv'].to_f,
                      :ibu  => check_in['beer_ibu'].to_i,
                      :untappd_url => check_in['beer_url'])
      brewery.add_beer(beer)
      beer.save
    end

    venue_name = check_in['venue_name']
    if venue_name
      venue = Venue.find(:name => venue_name)
      unless venue
        venue = Venue.create(:name => venue_name,
                             :city => check_in['venue_city'],
                             :state => check_in['venue_state'],
                             :country => check_in['venue_country'],
                             :lat => check_in['venue_lat'],
                             :lng => check_in['venue_lng'])
      end
    end

    checkin = Checkin.new(:untappd_url => check_in['checkin_url'],
                          :comment => check_in['comment'],
                          :flavor_profiles => check_in['flavor_profiles'],
                          :purchase_venue => check_in['purchase_venue'],
                          :rating_score => check_in['rating_score'].to_i,
                          :serving_type => check_in['serving_type'],
                          :checked_in => checked_in)
    checkin.beer = beer
    checkin.user = user
    checkin.venue = venue if venue
    checkin.save
    rows += 1
  end
  rows
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

  user = User.find(:username => username)
  unless user
    user = User.create(:username => username)
  end

  populate(user, filename)
end
