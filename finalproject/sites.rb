require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")

class Site
  include DataMapper::Resource
  property :username, String, key:true
  property :site_html, String
  property :site_css, String
end

DataMapper.finalize()