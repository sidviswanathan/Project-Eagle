class CreateReservations < ActiveRecord::Migration
  def self.up
    create_table :reservations do |t|
      t.date     :date
      t.string   :time
      t.integer  :golfers
      t.integer  :user_id
      t.integer  :course_id
      t.string   :booking_type
      t.string   :confirmation_code
      t.integer  :status_code, :default => 1
      t.string   :total
      t.timestamps
    end
  end

  def self.down
    drop_table   :reservations
  end
end
