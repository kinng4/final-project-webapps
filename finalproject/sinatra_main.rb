require 'sinatra'
require 'sinatra/reloader' if development?
require 'slim'
require './user'
require './votes'
require './sites'
require 'bcrypt'

get '/' do
  slim :home
end

