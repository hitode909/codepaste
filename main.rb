require 'sinatra'
require 'haml'
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
      @current_user = Model::User.login(*auth.credentials)
  end

  def authorized_as?(user)
    protected! unless @current_user
    throw(:halt, [400, "You are not #{user.name}."]) unless @current_user == user
  end

  def entity_link(obj)
    # obj must has path and name
    haml '%a{:href => obj.path}= obj.name',
    :locals => {:obj => obj},
    :layout => false
  end
end

set :haml, :escape_html => true

before do
  @errors = []
  @messages = []

  if request.request_method.downcase != 'get'
    protected!
  end

  if authorized?
    @messages.push "authorized as #{@auth.credentials.first}"
  else
    @messages.push "not authorized"
  end
end

get '/' do
  @title = Time.now
  @files = Model::File.all
  haml :index
end

get '/register' do
  haml :register
end

post '/register' do
  begin
    user = Model::User.register params[:name], params[:password]
  rescue => e
    @errors.push(e.message)
    return haml :register
  end
  redirect params[:from] || '/'
end

get '/login' do
  protected!
  redirect params[:from] || '/'
end

get '/file.create' do
  haml :"file.create"
end

post '/file.create' do
  begin
    file = Model::File.create(:name => params[:name], :body => params[:body], :user => @current_user)
  rescue => e
    @errors.push(e.message)
    return haml :"file.create"
  end
  redirect file.path
end

post '/file/*.copy' do
  @file = Model::File.find(:id => params[:splat].first)
  halt 400 unless @file
  begin
    new = @file.copy!(@current_user)
  rescue => e
    @errors.push(e.message)
    return haml :file
  end
  redirect new.path('download')
end

get '/file/*.edit' do
  @file = Model::File.find(:id => params[:splat].first)
  halt 404 unless @file
  authorized_as? @file.user
  haml :"file.edit"
end

post '/file/*.edit' do
  @file = Model::File.find(:id => params[:splat].first)
  halt 400 unless @file and (params[:name] or params[:body])
  authorized_as? @file.user
  begin
    @file.update(:name => params[:name], :body => params[:body])
  rescue => e
    @errors.push(e.message)
    return haml :"file.edit"
  end
  redirect @file.path
end


post '/file/*.note' do
  @file = Model::File.find(:id => params[:splat].first)
  halt 400 unless @file and params[:body]
  begin
    @file.add_note(:name => params[:name], :body => params[:body], :user => @current_user)
  rescue => e
    @errors.push(e.message)
    return haml :"file"
  end
  redirect @file.path
end

get '/file/*.blob' do
  @file = Model::File.find(:id => params[:splat].first)
  response['Content-Type'] = 'text/plain'
  response['Content-Disposition'] = "attachment; filename=\"#{@file.name}\"";
  @file.body
end

get '/file/*.download' do
  @file = Model::File.find(:id => params[:splat].first)
  haml :"file.download"
end

get %r{/file/(\d)\.?(\w+)?} do
  logger.warn "unknown method \"#{params[:captures][1]}\"" if params[:captures][1]
  logger.debug request
  @file = Model::File.find(:id => params[:captures].first)
  haml :file
end

get '/user/*' do
  @user = Model::User.find(:id => params[:splat].first)
  haml :user
end

