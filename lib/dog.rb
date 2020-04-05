class Dog

  attr_accessor :name, :breed
  attr_reader :id
  
  @@all = []
  
  def self.all
    @@all
  end
  
  def initialize(hash)
    @id = hash[:id]
    @name = hash[:name]
    @breed = hash[:breed]
    
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT)
    SQL
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end
  
  def save
    sql = <<-SQL
    INSERT INTO dogs(name,breed)
    VALUES (?,?) 
    SQL
    DB[:conn].execute(sql,self.name,self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    return self
  end
  
  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?",self.name,self.breed,self.id)
  end
  
  def self.create(name:"",breed:"")
    hash = {:name => name, :breed => breed}
    new_dog = self.new(hash)
    new_dog.save
  end
  
  def self.new_from_db(row)
    hash = {:id => row[0],:name =>row[1],:breed =>row[2]}
    new_dog = self.new(hash)
    new_dog
  end
  
  def self.find_by_id(i)
    self.new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE id = ?",i)[0])
  end
    
  def self.find_or_create_by(name:"",breed:"")
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      self.new_from_db(dog_data[0],dog_data[1],dog_data[2])
    else
      self.create(name: name,breed: breed)
    end
  end
  
end