class Course < ActiveRecord::Base
  has_many :course_to_user_relations
  has_many :users, :through => :course_to_user_relations
  has_many :reservations
end
