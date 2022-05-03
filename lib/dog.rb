class Dog

    attr_accessor :breed, :name, :id

    def initialize(name:, breed:, id: nil)
        @id=id
        @name=name
        @breed=breed
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT)        
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end

    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed) 
        VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(name:, breed:)
        self.new(name: name, breed: breed).save
    end

    def self.new_from_db(row)
            self.new(name: row[1], breed: row[2], id: row[0])
    end

    def self.all
        all = []
        
        DB[:conn].execute("SELECT id, name, breed FROM dogs").each do |row|
            all << self.new(name: row[1], breed: row[2], id: row[0])
         end
         all
    end

    def self.find_by_name(name)
        # binding.pry
        self.new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE name = ? LIMIT 1", name)[0])
    end

    def self.find(id)
        # binding.pry
        self.new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE id = ? LIMIT 1", id)[0])
    end

    def self.find_or_create_by(name:, breed: )
        rows = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1", name, breed)
        if rows.length == 0 
            self.create(name: name, breed: breed)
        else 
            self.new_from_db(rows[0])
        end
    end
    def update
        DB[:conn].execute("UPDATE dogs SET name = ? WHERE id = ?",self.name, self.id )
        self
    end
end