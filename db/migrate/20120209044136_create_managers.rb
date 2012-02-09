class CreateManagers < ActiveRecord::Migration
  def self.up
    create_table :managers do |t|
      t.string :email
      t.string :hashed_password
      t.string :salt
      t.text :courses
      t.text :data
      t.string :acl

      t.timestamps
    end
  end

  def self.down
    drop_table :managers
  end
end
