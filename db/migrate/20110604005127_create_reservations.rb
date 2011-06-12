class CreateReservations < ActiveRecord::Migration
  def self.up
    create_table :reservations do |t|
      t.date :date
      t.string :tee_slot
      t.boolean :availability, :default => "true"
      t.integer :golfers
      t.integer :user_id
      t.integer :course_id
      t.timestamps
    end
  end

  def self.down
    drop_table :reservations
  end
end
