require 'dm-core'
require 'dm-migrations'
require 'zip'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")

class Site
  include DataMapper::Resource
  property :username, String, :key => true, :unique => true
  property :site_html, String, :required => true
end

DataMapper.finalize()

get '/uploadzip' do
  @title = "Upload Websites"
  if session[:id]
    @instructor = User.get(session[:id].username)
    halt(401, 'Not Authorized') unless @instructor.role == 'instructor'
    slim :upload_zip
  else
    halt(401, 'Not Authorized')
  end
end

post '/uploadzip' do

  #uploading the zip file and storing it under the public folder
  tempfile = params[:file][:tempfile]
  filename = params[:file][:filename]
  target = "public/#{filename}"
  File.open(target, 'wb') {|f| f.write tempfile.read }

  #unzipping the contents and storing each student directory under public
  Zip::File.open(target) do |zip_file|
    zip_file.each do |entry|
      #If entry ends with .html push to array
      if entry.name.end_with? '.html'
        #Split the path. Now arr[0] contains username and arr[1] contains html
        arr = entry.name.split('/')
        #Add username and html file to the Sites database
        Site.create(username: arr[0], site_html: arr[1])
      end
      target = File.join("public/", entry.name)
      FileUtils::mkdir_p(File.dirname(target))
      zip_file.extract(entry, target) unless File.exist?(target)
    end
  end
  redirect to('/')
end