require 'pry'
require_relative "../config/environment.rb"

class Dog

attr_accessor :name, :breed, :id
#attr_reader :id

  # def attributes
  # attributes = {
  #   id: "INTEGER PRIMARY KEY AUTOINCREMENT",
  #   name: "TEXT",
  #   breed: "TEXT"}
  # end

  def initialize(attributes = {})
    @id = attributes[:id]
    @name = attributes[:name]
    @breed = attributes[:breed]

  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    breed TEXT)
    SQL
 #   binding.pry
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL
      
      DB[:conn].execute(sql, self.name, self.breed)      
      @id = DB[:conn].execute("select id from dogs").flatten.last
      self
  end

  def self.create(attributes = {})
    dog = Dog.new(attributes)
    dog.save
    dog
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ? WHERE ID = ?
      SQL

    DB[:conn].execute(sql, self.name, self.id)
  end


  def self.dog_from_row(row)
      Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id)
   sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?;
    SQL

    row = DB[:conn].execute(sql, id)
    self.dog_from_row(row.first)
  end

  def self.find_by_name(name)
   sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?;
    SQL

    row = DB[:conn].execute(sql, name)
    self.dog_from_row(row.first)
  end

  def self.find_or_create_by(attributes = {})
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", attributes[:name], attributes[:breed])    
    if !dog.empty?
        dog_data = dog[0]
        dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else      
        dog = self.create(name: attributes[:name], breed: attributes[:breed])
    end 
      dog
  end

  def self.new_from_db(attributes)
    dog = self.dog_from_row(attributes)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
      SQL

      DB[:conn].execute(sql)
  end

end

#Pry.start