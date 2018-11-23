require 'dm-core'
require 'dm-migrations'
require 'csv'

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
    @sites_users = Site.all
    @sites_count = Site.count
    slim :vote_form
  else
    halt(401, 'Not Authorized')
  end
end

post '/vote' do

  vote = Voting.get(session[:id].username)

  #Check if the current student has already voted
  if vote
    redirect to('/vote')
  else
    # Check that all entries from the drop-down menus are different
    if params[:first_place] != params[:second_place] && params[:first_place] != params[:third_place] && params[:second_place] != params[:third_place]
      #Create a vote for the logged-in user
      Voting.create(username: session[:id].username, first_place: params[:first_place],
                    second_place: params[:second_place], third_place: params[:third_place])

      #Modify vote_bit to be one to indicate that the user has voted
      user = User.get(session[:id].username)
      user.vote_bit = 1
      user.save
      redirect to('/vote')
    else
      @student = User.get(session[:id].username)
      @invalid_votes = "Error: same user can't be chosen more than once."
      @sites_users = Site.all
      @sites_count = Site.count
      slim :vote_form
    end
  end
end

get '/report' do

  if session[:id]
    instructor = User.get(session[:id].username)
    halt(401, 'Not Authorized') unless instructor.role == 'instructor'
    @votes = Voting.all
    @votes_count = Voting.count
    slim :vote_report
  else
    halt(401, 'Not Authorized')
  end
end


post '/report/download' do
  #Get all records in the voting database
  report = Voting.all

  #Set the download file name and type
  content_type 'application/csv'
  attachment 'report.csv'

  #Create a .csv string for download
  CSV.generate do |csv|
    csv << ["Who Voted", "First Place", "Second Place", "Third Place"]
    report.each do |vote|
      csv << [vote.username, vote.first_place, vote.second_place, vote.third_place]
    end
  end
end