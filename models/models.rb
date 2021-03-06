# -*- coding: utf-8 -*-
module ::Model
  module ModelHelper
    def path(method = nil)
      namespace = self.class.to_s.split('::').last.downcase
      if method
        "/#{namespace}/#{self.id}.#{method}"
      else
        "/#{namespace}/#{self.id}"
      end
    end
  end

  # create database c2 default character set 'utf8';
  class User < Sequel::Model
    include ModelHelper
    set_schema do
      primary_key :id
      String :name, :null => false, :unique => true
      String :password, :null => false
      String :mail#, :null => false
      String :profile
      Boolean :is_alive, :null => false, :default => true
      Boolean :is_admin, :null => false, :default => false
      datetime :created_at
      datetime :updated_at
    end

    def validate
      errors.add(:name, "can't be empty") if name.empty?
      errors.add(:password, "can't be empty") if password.empty?
    end

    one_to_many :files
    one_to_many :notes, :order => :created_at
    create_table unless table_exists?
    plugin :timestamps, :update_on_create => true

    def self.register(name, password)
      self.create(:name => name,:password => password)
    end

    def self.login(name, password)
      self.find(:name => name,:password => password)
    end

    def self.authenticate(name, password)
      self.find(:name => name, :password => password)
    end

    # XXX wardenの仕様に合わせて，find(id)で引けるようにする
    class << self
      alias :_original_find :find
      def find(*args)
        p args
        if args.length == 1 and args.first.kind_of? Integer
          self._original_find(:id => args.first)
        else
          self._original_find(args)
        end
      end
    end
  end

  class File < Sequel::Model
    include ModelHelper
    set_schema do
      primary_key :id
      String :name, :null => false
      Text :body,   :null => false
      foreign_key :user_id, :null => false
      foreign_key :parent_id
      datetime :created_at
      datetime :updated_at
    end
    many_to_one :user
    many_to_one :parent, :key => :parent_id, :class => Model::File
    one_to_many :notes#, :eager => :user
    one_to_many :children, :class => Model::File, :key => :parent_id
    plugin :timestamps, :update_on_create => true
    create_table unless table_exists?

    def copy!(user)
      self.class.create(:name => self.name, :body => self.body, :user => user, :parent => self)
    end

    def add_note(args)
      Note.create(args.update(:file => self))
    end

    def project_name
      ['CodePaste', self.id].join('-')
    end
  end

  class Note < Sequel::Model
    include ModelHelper
    set_schema do
      primary_key :id
      String :name
      Text   :body, :null => false
      foreign_key :user_id, :null => false
      foreign_key :file_id, :null => false
      datetime :created_at
      datetime :updated_at
    end
    many_to_one :user
    many_to_one :file
    plugin :timestamps, :update_on_create => true
    create_table unless table_exists?
  end
end
