# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111215013212) do

  create_table "available_tee_times", :force => true do |t|
    t.text     "data"
    t.text     "archive"
    t.string   "courseid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "available_times", :force => true do |t|
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "courses", :force => true do |t|
    t.string   "name"
    t.decimal  "price",       :precision => 8, :scale => 2
    t.text     "description"
    t.text     "contact"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "email_reservations", :force => true do |t|
    t.date     "date"
    t.string   "time"
    t.integer  "golfers"
    t.integer  "course_id"
    t.string   "confirmation_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reservations", :force => true do |t|
    t.date     "date"
    t.string   "time"
    t.integer  "golfers"
    t.integer  "user_id"
    t.integer  "course_id"
    t.string   "booking_type"
    t.string   "confirmation_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.text     "email"
    t.text     "f_name"
    t.text     "l_name"
    t.text     "device_name"
    t.text     "os_version"
    t.text     "app_version"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
