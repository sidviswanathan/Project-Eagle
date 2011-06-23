class User < ActiveRecord::Base
  has_many :reservations
  belongs_to :course

  validates_presence_of :email
  validates_uniqueness_of :email
  validates_format_of :email,
                      :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
                      :message => "Invalid email format"

end
