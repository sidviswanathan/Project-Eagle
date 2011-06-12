class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.text :email
      t.text :f_name
      t.text :l_name
      t.integer :course_id
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
