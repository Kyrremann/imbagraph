class Beer < Sequel::Model
  many_to_one :brewery
end
