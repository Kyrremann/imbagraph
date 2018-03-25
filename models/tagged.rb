class Tagged < Sequel::Model(:tagged)
  one_to_one :user
end
