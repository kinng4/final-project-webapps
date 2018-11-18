require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")


class Voting
  include DataMapper::Resource
  property :username, String, :key => true, :unique => true
  property :first_place, String, :required => true
  property :second_place, String, :required => true
  property :third_place, String, :required => true
end

DataMapper.finalize()

get '/vote' do
  @title = "Vote"
  if session[:id]
    @student = User.get(session[:id].username)
    halt(401, 'Not Authorized') unless @student.role == 'student'
    slim :vote_form
  else
    halt(401, 'Not Authorized')
  end
end

post '/vote' do

  vote = Voting.get(session[:id].username)

  if vote
    redirect to('/vote')
  else
    Voting.create(username: session[:id].username, first_place: params[:first_place],
                  second_place: params[:second_place], third_place: params[:third_place])

    user = User.get(session[:id].username)
    user.vote_bit = 1
    user.save

    redirect to('/vote')
  end
end