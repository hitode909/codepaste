module ::Model
  class User < Sequel::Model
    set_schema do
      primary_key :id
      String :name, :null => false
      String :password, :null => false
      String :mail#, :null => false
      String :profile
      Boolean :is_alive, :null => false, :default => true
      Boolean :is_admin, :null => false, :default => false
      datetime :created_at
      datetime :updated_at
    end
    plugin :timestamps, :update_on_create => true
    one_to_many :files
    one_to_many :notes, :order => :created_at
    create_table unless table_exists?

    def self.register(name, password)
      self.create(:name => name,:password => password)
    end

    def self.login(name, password)
      self.find(:name => name,:password => password)
    end

    def path
      "/user/#{self.id}"
    end

  end

  class File < Sequel::Model
    set_schema do
      primary_key :id
      String :name, :null => false
      String :body, :null => false
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

    def path(method = nil)
      if method
        "/file/#{self.id}.#{method}"
      else
        "/file/#{self.id}"
      end
    end

    def fork!(user)
      self.class.create(:name => self.name, :body => self.body, :user => user, :parent => self)
    end

    def add_note(args)
      Note.create(args.update(:file => self))
    end
  end

  class Note < Sequel::Model
    set_schema do
      primary_key :id
      String :name
      String :body, :null => false
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
