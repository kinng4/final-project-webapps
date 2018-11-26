#Code and url paths related to the users table

require 'dm-core'
require 'dm-migrations'
require 'bcrypt'
require 'csv'

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
    User.create(username: params[:username].downcase, password: hash_password, role: params[:role])
    redirect to("/login")
  end
end

get '/uploadcsv' do
  @title = "Upload CSV"
  if session[:id]
    @instructor = User.get(session[:id].username)
    halt(401, 'Not Authorized') unless @instructor.role == 'instructor'
    slim :upload_csv
  else
    halt(401, 'Not Authorized')
  end
end

post '/uploadcsv' do
  tempfile = params[:file][:tempfile]
  filename = params[:file][:filename]
  target = "public/#{filename}"
  File.open(target, 'wb') {|f| f.write tempfile.read }

  # CSV.open(filename,'r') do |row|
  #   puts row
  # end

  CSV.foreach(target, :headers => true) do |row|
    hash_password = BCrypt::Password.create(row[1])
    User.create(username: row[0].downcase, password: hash_password, role: row[2])


  end

  redirect to('/')
end