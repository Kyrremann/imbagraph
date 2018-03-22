Sequel.migration do
  change do
    create_table(:beers) do
      primary_key :id
      String :name, null: false
      String :type
      Float :abv
      Integer :ibu
      String :untappd_url
      Int :brewery_id, null: false

      Time :created_at, null: false
      Time :updated_at
    end

    create_table(:breweries) do
      primary_key :id
      String :name, null: false
      String :country, null: false
      String :city
      String :untappd_url

      Time :created_at, null: false
      Time :updated_at
    end

    create_table(:venues) do
      primary_key :id
      String :name, null: false
      String :city
      String :state
      String :country, null: false
      Float :lat
      Float :lng

      Time :created_at, null: false
      Time :updated_at
    end

    create_table(:checkins) do
      primary_key :id
      String :untappd_url, null: false
      String :comment
      String :flavor_profiles
      Integer :rating_score, null: false
      String :serving_type
      String :purchase_venue
      Int :beer_id, null: false
      Int :venue_id
      Int :user_id, null: false
      Time :checked_in, null: false
      
      Time :created_at, null: false
      Time :updated_at
    end

    create_table(:users) do
      primary_key :id
      String :untappd_url
      String :username, null: false
      String :uuid

      Time :created_at, null: false
      Time :updated_at
    end
  end
end
