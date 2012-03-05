class CreateCustomers < ActiveRecord::Migration
  def self.up
    create_table :customers do |t|
      t.string :name
      t.string :password
      t.string :f_name
      t.string :l_name
      t.text :data
      t.text :prefs
      t.text :requests
      t.string :contact_via
      t.string :phone
      t.string :email

      t.timestamps
    end
  end

  def self.down
    drop_table :customers
  end
end
