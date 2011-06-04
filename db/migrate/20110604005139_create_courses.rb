class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table :courses do |t|
      t.string :name
      t.integer :player_count
      t.decimal :price, :precision => 8, :scale => 2
      t.text :description
      t.text :contact
      t.timestamps
    end
  end

  def self.down
    drop_table :courses
  end
end
