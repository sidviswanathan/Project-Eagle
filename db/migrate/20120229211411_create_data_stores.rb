class CreateDataStores < ActiveRecord::Migration
  def self.up
    create_table :data_stores do |t|
      t.string :name
      t.text :data
      t.integer :counter
      t.integer :course_id

      t.timestamps
    end
  end

  def self.down
    drop_table :data_stores
  end
end
