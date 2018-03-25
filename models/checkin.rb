class Checkin < Sequel::Model
  many_to_one :user
  many_to_one :beer
  many_to_one :venue
  one_to_many :tagged
end
