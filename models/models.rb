module ::Model
  class User < Sequel::Model
    set_schema do
      primary_key :id
      String :name, :null => false
      String :password, :null => false
      String :profile
      Boolean :is_alive, :null => false, :default => true
      datetime :created_at
      datetime :updated_at
    end
    plugin :timestamps, :update_on_create => true
    one_to_many :projects
    one_to_many :files
    one_to_many :notes
    create_table unless table_exists?
  end

  class Project < Sequel::Model
    set_schema do
      primary_key :id
      String :name, :null => false
      String :description
      foreign_key :user_id, :null => false
      datetime :created_at
      datetime :updated_at
    end
    many_to_one :user
    one_to_many :files
    one_to_many :notes
    plugin :timestamps, :update_on_create => true
    create_table unless table_exists?
  end

  class File < Sequel::Model
    set_schema do
      primary_key :id
      String :name, :null => false
      String :body, :null => false
      foreign_key :user_id, :null => false
      foreign_key :project_id, :null => false
      datetime :created_at
      datetime :updated_at
    end
    many_to_one :user
    many_to_one :project
    one_to_many :notes
    plugin :timestamps, :update_on_create => true
    create_table unless table_exists?
  end

  class Note < Sequel::Model
    set_schema do
      primary_key :id
      String :name
      String :body, :null => false
      foreign_key :user_id, :null => false
      foreign_key :project_id, :null => false
      foreign_key :file_id
      datetime :created_at
      datetime :updated_at
    end
    many_to_one :user
    many_to_one :project
    many_to_one :file
    plugin :timestamps, :update_on_create => true
    create_table unless table_exists?
  end
end
