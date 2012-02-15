class CreateDeals < ActiveRecord::Migration
  def self.up
    create_table :deals do |t|
      t.string :title
      t.text :info
      t.text :data
      t.string :code
      t.datetime :starting
      t.datetime :ending
      t.datetime :eta
      t.boolean :valid

      t.timestamps
    end
  end

  def self.down
    drop_table :deals
  end
end
