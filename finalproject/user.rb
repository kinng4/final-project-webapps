#Code and url paths related to the users table

require 'dm-core'
require 'dm-migrations'
require 'bcrypt'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")

#Users table class
class User
  include DataMapper::Resource
  property :username, String, key:true
  property :password, String
  property :role, String
  property :vote_bit, Integer
end

DataMapper.finalize()

#Register path calls the register form template and creates a User object
get '/register' do
  @title = "Register"
  @user = User.new
  slim :register
end

#Post register path looks if username is already in database. If not, creates a new user in the users database
post '/register' do
  @user = User.get(params[:username])
  @invalid_username = nil

  if @user
    @invalid_username = "Sorry that username is already taken"
    slim :register
  else
    hash_password = BCrypt::Password.create(params[:password]) #store this value in the database
    hash_password = BCrypt::Password.new(hash_password) #use this to hash the value

    user = User.create(username: params[:username], password: hash_password, role: params[:role])
    user.vote_bit = 0
    user.save
    redirect to("/")
  end

end