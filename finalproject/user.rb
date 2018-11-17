#Code and url paths related to the users table

require 'dm-core'
require 'dm-migrations'
require 'bcrypt'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")

#Users table class
class User
  include DataMapper::Resource
  property :username, String, :key => true, :unique => true
  property :password, String, :required => true
  property :role, String, :required => true
  property :vote_bit, Integer, :default => 0
end

DataMapper.finalize()

#Register path calls the register form template and creates a User object
get '/register' do
  @title = "Register"
  slim :register
end

#Post register path looks if username is already in database. If not, creates a new user in the users database
post '/register' do
  #Search user in database, converts to downcase to make sure username is case-insensitive
  user = User.get(params[:username].downcase)

  #if user is found don't add to database, else create user
  if user
    @invalid_username = "Sorry that username is already taken"
    slim :register
  else
    hash_password = BCrypt::Password.create(params[:password]) #store this value in the database
    #hash_password = BCrypt::Password.new(hash_password) #pass the stored value in this one and use this to make the comparisson

    User.create(username: params[:username].downcase, password: hash_password, role: params[:role])
    redirect to("/login")
  end
end