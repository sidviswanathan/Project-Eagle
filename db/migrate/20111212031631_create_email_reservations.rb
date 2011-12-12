class CreateEmailReservations < ActiveRecord::Migration
  def self.up
    create_table :email_reservations do |t|
      t.date     :date
      t.string   :time
      t.integer  :golfers
      t.integer  :course_id
      t.string   :confirmation_code
      t.timestamps
    end
  end

  def self.down
    drop_table   :email_reservations
  end
end
