require 'sinatra'
require 'sinatra/reloader' if development?
require 'slim'
require './user'
require './votes'
require './sites'
require 'bcrypt'
require 'zip'
require 'csv'

configure do
  enable :sessions
end

get '/' do
  @count_sites = Site.count
  @websites = Site.all
  #Randomize the order in which the websites will appear.
  @websites = @websites.shuffle
  slim :home
end

get '/login' do
  @title = "Login"
  slim :login
end

post '/login' do
  @user = User.get(params[:username].downcase)

  if @user
    password = BCrypt::Password.new(@user.password)
    if @user.username && password == params[:password]
      session[:id] = @user
      redirect to('/')
    else
      @invalid_user = "Sorry the username/password is incorrect"
      slim :login
    end
    #If the user does not exist in the database display error message
  else
    @invalid_user = "Sorry the username/password is incorrect"
    slim :login
  end
end

get '/logout' do
  session.clear
  redirect to('/')
end

not_found do
  slim :not_found
end
