# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'json'

def delete_test_db
  File.delete(File.dirname(__FILE__) + '/../' + 'test.db')
end

def json(str)
  JSON.load(str)
end

delete_test_db
DB_ENV = 'test'
