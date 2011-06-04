class User < ActiveRecord::Base
  has_many :course_to_user_relations
  has_many :courses, :through => :course_to_user_relations
  has_many :reservations
end
