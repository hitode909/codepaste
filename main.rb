require 'sinatra'
require 'erb'
require 'models/init'

get '/' do
  @title = Time.now
  erb :index
end

