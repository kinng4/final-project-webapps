require 'sinatra'
require 'sinatra/reloader' if development?
require 'slim'
require './user'
require './votes'
require './sites'
require 'bcrypt'

configure do
  enable :sessions
end

get '/' do
  if session[:id]
    @logged_user = User.get(session[:id])
  end
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
      session[:id] = @user.username
      redirect to('/')
    else
      redirect to('/login')
    end
    #In here this means the user does not exist in the database
  else
    redirect to('/login')
  end
end

get '/logout' do
  session.clear
  redirect to('/')
end

not_found do
  if session[:id]
    @logged_user = User.get(session[:id])
  end
  slim :not_found
end
