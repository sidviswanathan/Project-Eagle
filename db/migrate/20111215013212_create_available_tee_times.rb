class CreateAvailableTeeTimes < ActiveRecord::Migration
  def self.up
    create_table :available_tee_times do |t|
      t.text :data
      t.text :archive

      t.timestamps
    end
  end

  def self.down
    drop_table :available_tee_times
  end
end
