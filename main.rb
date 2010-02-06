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

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? &&
      @auth.basic? &&
      @auth.credentials &&
      Model::User.login(*@auth.credentials)
  end
end

before do
  @errors = []
  @messages = []
  if authorized?
    @messages.push "authorized as #{@auth.credentials.first}"
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
