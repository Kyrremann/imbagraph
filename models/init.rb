require 'sequel'

Sequel::Model.plugin :timestamps
Sequel.extension :symbol_as
Sequel.extension :connection_validator

database_url = ENV['DATABASE_URL'] ? ENV['DATABASE_URL'] : 'postgres://postgres:postgres@localhost:5432/imbagraph'
DB = Sequel.connect(database_url)
DB.pool.connection_validation_timeout = -1

require_relative 'user'
require_relative 'beer'
require_relative 'brewery'
require_relative 'venue'
require_relative 'checkin'
