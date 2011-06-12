class User < ActiveRecord::Base
  has_many :reservations
  belongs_to :course
end
