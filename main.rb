require 'sinatra'
require 'erb'
require 'models/init'
require 'logger'

helpers do
  alias_method :h, :escape_html
  def logger
    @logger ||= Logger.new($stdout)
  end

  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Testing HTTP Auth")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def auth
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
  end
  def authorized?
    auth.provided? &&
      auth.basic? &&
      auth.credentials &&
      Model::User.login(*auth.credentials)
  end
end

before do
  @errors = []
  @messages = []

  if request.request_method.downcase != 'get'
    protected!
  end

  if authorized?
    @messages.push "authorized as #{@auth.credentials.first}"
    @current_user = Model::User.login(*auth.credentials)
  else
    @messages.push "not authorized"
  end
end

get '/' do
  @title = Time.now
  erb :index
end

get '/register' do
  erb :register
end

post '/register' do
  begin
    user = Model::User.register params[:name], params[:password] # TODO
  rescue => e
    @errors.push(e.message)
    return erb :register
  else
    redirect params[:from] || '/'
  end
end

get '/login' do
  protected!
  redirect params[:from] || '/'
end

get '/file.new' do
  erb :"file.new"
end

post '/file.new' do
  begin
    file = Model::File.create(:name => params[:name], :body => params[:body], :user => @current_user)
  rescue => e
    @errors.push(e.message)
    return erb :"file.new"
  end
  redirect file.path
end

post '/file/*.fork' do
  parent = Model::File.find(:id => params[:splat].first)
  halt 400 unless parent
  new = parent.fork!(@current_user)
  redirect new.path
end

get '/file/*.edit' do
  @file = Model::File.find(:id => params[:splat].first)
  halt 404 unless @file
  erb :"file.edit"
end

post '/file/*.edit' do
  file = Model::File.find(:id => params[:splat].first)
  halt 400 unless file
  file.update(:name => params[:name], :body => params[:body])
  redirect file.path
end

get '/file/*' do
  # splat = file.id
  @file = Model::File.find(:id => params[:splat].first)
  p @file
  erb :file
end
