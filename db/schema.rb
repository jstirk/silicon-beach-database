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

ActiveRecord::Schema.define(:version => 20080809112208) do

  create_table "people", :force => true do |t|
    t.string   "given_name"
    t.string   "family_name"
    t.string   "title"
    t.string   "street_address"
    t.string   "locality"
    t.string   "region"
    t.string   "postal_code"
    t.string   "country"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "full_name"
  end

  add_index "people", ["full_name"], :name => "index_people_on_full_name"
  add_index "people", ["country"], :name => "index_people_on_country"
  add_index "people", ["region"], :name => "index_people_on_region"
  add_index "people", ["locality"], :name => "index_people_on_locality"
  add_index "people", ["given_name", "family_name"], :name => "index_people_on_given_name_and_family_name"

  create_table "resumes", :force => true do |t|
    t.string   "uri"
    t.datetime "last_updated_at"
    t.datetime "update_again_at"
    t.text     "last_content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "summary"
    t.integer  "person_id"
  end

  add_index "resumes", ["uri"], :name => "index_resumes_on_uri", :unique => true
  add_index "resumes", ["person_id"], :name => "index_resumes_on_person_id"

  create_table "skills", :force => true do |t|
    t.integer  "person_id"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "skills", ["value"], :name => "index_skills_on_value"
  add_index "skills", ["person_id"], :name => "index_skills_on_person_id"

  create_table "urls", :force => true do |t|
    t.integer  "person_id"
    t.string   "description"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "urls", ["url"], :name => "index_urls_on_url"
  add_index "urls", ["person_id"], :name => "index_urls_on_person_id"

end
