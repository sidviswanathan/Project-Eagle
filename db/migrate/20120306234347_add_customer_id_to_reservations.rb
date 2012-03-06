class AddCustomerIdToReservations < ActiveRecord::Migration
  def self.up
    add_column :reservations, :customer_id, :integer
  end

  def self.down
    remove_column :reservations, :customer_id
  end
end
