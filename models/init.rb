require 'sequel'
require 'logger'

DB_ENV rescue  DB_ENV = 'app'
Sequel::Model.plugin(:schema)
if DB_ENV == 'test'
  DB = Sequel.sqlite('test.db')
else
  DB = Sequel.sqlite('app.db')
  #DB = Sequel.mysql 'codepaste', :user => 'nobody', :password => 'nobody', :host => 'localhost', :encoding => 'utf8', :loggers => [Logger.new($stdout)]
end

require 'models/models'

