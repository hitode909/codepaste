require 'sequel'

DB_ENV rescue  DB_ENV = 'app'
Sequel::Model.plugin(:schema)
if DB_ENV == 'test'
  DB = Sequel.sqlite('test.db')
else
  # create database chatlike character set utf8;
  DB = Sequel.mysql 'eclipse', :user => 'nobody', :password => 'nobody', :host => 'localhost', :encoding => 'utf8'
end

require 'models/models'

