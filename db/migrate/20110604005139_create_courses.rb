class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table :courses do |t|
      t.string :name
      t.string :api
      t.string :api_course_id
      t.text :fee_matrix
      t.text :data
      t.timestamps
    end
  end

  def self.down
    drop_table :courses
  end
end
