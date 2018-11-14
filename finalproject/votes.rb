require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")


class Voting
  include DataMapper::Resource
  property :username, String, key:true
  property :first_place, String
  property :second_place, String
  property :third_place, String
end

DataMapper.finalize()