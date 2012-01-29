class AddTotalToReservation < ActiveRecord::Migration
  def self.up
    add_column :reservations, :total, :string
  end

  def self.down
    remove_column :reservations, :total
  end
end
