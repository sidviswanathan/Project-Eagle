class CreateAvailableTimes < ActiveRecord::Migration
  def self.up
    create_table :available_times do |t|
      t.text    :data
      t.integer :course_id
      t.timestamps
    end
  end

  def self.down
    drop_table :available_times
  end
end
