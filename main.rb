require 'sinatra/base'
require 'haml'
require 'models/init'
require 'logger'
require 'sinatra_more/warden_plugin'

module SinatraMore
  module WardenPlugin
    class PasswordStrategy < Warden::Strategies::Base
      def username
        params['name']
      end
    end
  end
end

class CodePasteApp < Sinatra::Base
  set :sessions, true

  register SinatraMore::WardenPlugin
  SinatraMore::WardenPlugin::PasswordStrategy.user_class = Model::User

  helpers do
    alias_method :h, :escape_html

    def logger
      @logger ||= Logger.new($stdout)
    end

    def entity_link(obj)
      return unless obj.respond_to? :path and obj.respond_to? :name
      haml '%a{:href => obj.path}= obj.name',
      :locals => {:obj => obj},
      :layout => false
    end

    def authorized_as?(user)
      unless current_user == user
        halt 400
      end
    end
  end

  set :haml, :escape_html => true
  set :static, true
  set :public, File.dirname(__FILE__) + '/public'


  before do
    @errors = []
    @messages = []

    if request.request_method.downcase != 'get' and
        request.path_info != '/register' and
        request.path_info != '/login'
      must_be_authorized!
    end
  end

  get '/' do
    @files = Model::File.order(:updated_at.desc).all
    haml :index
  end

  get '/register' do
    haml :register
  end

  post '/register' do
    begin
      user = Model::User.register params[:name], params[:password]
      authenticate_user!
    rescue => e
      @errors.push(e.message)
      return haml :register
    end
    redirect params[:from] || '/'
  end

  get '/login' do
    haml :login
  end

  post '/login' do
    authenticate_user!
    redirect params[:from] || '/'
  end

  get '/logout/?' do
    logout_user!
    redirect '/'
  end


  get '/file.create' do
    haml :"file.create"
  end

  post '/file.create' do
    begin
      file = Model::File.create(:name => params[:name], :body => params[:body], :user => current_user)
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
      new = @file.copy!(current_user)
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

  get '/file/*.upload' do
    @file = Model::File.find(:id => params[:splat].first)
    halt 404 unless @file
    authorized_as? @file.user
    haml :"file.upload"
  end

  post '/file/*.note' do
    @file = Model::File.find(:id => params[:splat].first)
    halt 400 unless @file and params[:body]
    begin
      @file.add_note(:name => params[:name], :body => params[:body], :user => current_user)
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
    @file.body.to_s
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
end
