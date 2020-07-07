class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize name:, breed:, id: nil
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = 'DROP TABLE IF EXISTS dogs'

    DB[:conn].execute(sql)
  end

  def save
    if @id
      update
    else
      sql = 'INSERT INTO dogs (name, breed) VALUES (?, ?)'
      DB[:conn].execute(sql, @name, @breed)
      @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
    end
    self
  end

  def update
    sql = 'UPDATE dogs SET name = ?, breed = ? WHERE id = ?'
    DB[:conn].execute(sql, @name, @breed, @id)
  end

  def self.create new_dog_hash
    new(new_dog_hash).save
  end

  def self.new_from_db row
    new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_id id
    sql = 'SELECT * FROM dogs WHERE id = ?'
    row = DB[:conn].execute(sql, id).first
    new_from_db(row)
  end

  def self.find_by_name name
    sql = 'SELECT * FROM dogs WHERE name = ?'
    row = DB[:conn].execute(sql, name).first
    new_from_db(row)
  end

  def self.find_or_create_by dog_hash
    if find_by_name(dog_hash[:name]) && find_by_name(dog_hash[:name]).breed == dog_hash[:breed]
      find_by_name(dog_hash[:name])
    else
      create(dog_hash)
    end
  end
end
