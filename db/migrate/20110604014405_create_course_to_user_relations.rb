class CreateCourseToUserRelations < ActiveRecord::Migration
  def self.up
    create_table :course_to_user_relations do |t|
      t.integer :course_id
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :course_to_user_relations
  end
end
