class User < Sequel::Model
  one_to_many :checkins
  many_to_many :beers, join_table: :checkins

  def beers_for_year(year)
    checkins_for_year = Checkin.where(:user_id => self.id, Sequel.extract(:year, :checked_in) => year)
    checkins_for_year.select(:name.as(:beer_name), :abv, :brewery_id, :checked_in).join(:beers, :id => :beer_id)
  end
    
  def first_beer(year=nil)
    return Checkin.where(:user_id => id, Sequel.extract(:year, :checked_in) => year).min(:checked_in) if year
    Checkin.where(:user_id => id).min(:checked_in)
  end

  def avg_beers(year=nil)
    return beers_for_year(year).count / days_drinking(year).to_f if year
    beers.count / days_drinking.to_f
  end

  def years_drinking
    (first_beer.year..Time.now.year)
  end

  def months_drinking(year)
    last_month = year == Time.now.year ? Time.now.month : 12
    (first_beer(year).month..last_month)
  end

  def days_drinking(year=nil)
    start_date = first_beer(year).to_date
    end_date = year.nil? ? Time.now.to_date : Date.new(year, 12, 31)
    end_date - start_date
  end

  def get_stats_for_year(year)
    days_in_year = days_drinking(year)
    checkins_for_year = Checkin.where(:user_id => id, Sequel.extract(:year, :checked_in) => year)
    beer_stats_for_periode(checkins_for_year, days_in_year)
  end

  def get_stats_for_month(year, month)
    days_in_month = Date.new(year, month, -1).day
    checkins_for_month = Checkin.where(:user_id => id, Sequel.extract(:year, :checked_in) => year, Sequel.extract(:month, :checked_in) => month)
    beer_stats_for_periode(checkins_for_month, days_in_month)
  end

  def beer_stats_for_periode(checkins, days_in_periode)
    if checkins.count == 0
      return empty_stats
    else
      beers = checkins.select(:name.as(:beer_name), :abv, :brewery_id, :checked_in).join(:beers, :id => :beer_id)
      venues = checkins.select(:name.as(:venue_name), :country.as(:venue_country)).join(:venues, :id => :venue_id)
      breweries = checkins.select(:brewery_id).join(:beers, :id => :beer_id).select(Sequel.qualify(:breweries, :name).as(:brewery_name), :country.as(:brewery_country)).join(:breweries, :id => :brewery_id)
      
      most_per_day = checkins.group_and_count(Sequel.function(:date, :checked_in)).order(Sequel.desc(:count)).first
      most_unique_per_day = beers.group_and_count(Sequel.function(:date, :checked_in)).order(Sequel.desc(:count)).first
      return {
        "total" => checkins.count,
        "total_unique" => beers.distinct(:beer_name).count,
        "max_abv" => beers.max(:abv).round(2),
        "avg_abv" => beers.avg(:abv).round(2),
        "brewery_countries" => breweries.distinct(:brewery_country).count,
        "breweries" => breweries.distinct(:brewery_name).count,
        "venue_countries" => venues.distinct(:venue_country).count,
        "venues" => venues.distinct(:venue_name).count,
        "most_per_day" => most_per_day,
        "most_unique_per_day" => most_unique_per_day,
        "avg_per_day" => (checkins.count / days_in_periode.to_f).round(2)
      }
    end
  end

  def empty_stats
    {
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
  end
end
