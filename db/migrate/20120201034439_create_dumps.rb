class CreateDumps < ActiveRecord::Migration
  def self.up
    create_table :dumps do |t|
      t.text :data
      t.datetime :eta
      t.integer :counter

      t.timestamps
    end
  end

  def self.down
    drop_table :dumps
  end
end
