class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table :courses do |t|
      t.string :name
      t.string :api
      t.string :api_course_id
      t.string :mobile_domain
      t.string :web_domain
      t.text :fee_matrix
      t.text :available_times
      t.text :info
      t.text :future_dates
      t.timestamps
    end
  end

  def self.down
    drop_table :courses
  end
end
