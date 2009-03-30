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

ActiveRecord::Schema.define(:version => 20090330141752) do

  create_table "experiences", :force => true do |t|
    t.integer  "person_id"
    t.string   "title"
    t.integer  "organization_id"
    t.text     "summary"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.integer  "duration"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "experiences", ["person_id", "organization_id", "title"], :name => "index_experiences_on_person_id_and_organization_id_and_title"
  add_index "experiences", ["title"], :name => "index_experiences_on_title"
  add_index "experiences", ["organization_id"], :name => "index_experiences_on_organization_id"
  add_index "experiences", ["person_id"], :name => "index_experiences_on_person_id"

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.text     "details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organizations", ["name"], :name => "index_organizations_on_name"

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
    t.decimal  "latitude",       :precision => 10, :scale => 7
    t.decimal  "longitude",      :precision => 10, :scale => 7
  end

  add_index "people", ["latitude", "longitude"], :name => "index_people_on_latitude_and_longitude"
  add_index "people", ["full_name"], :name => "index_people_on_full_name"
  add_index "people", ["country"], :name => "index_people_on_country"
  add_index "people", ["region"], :name => "index_people_on_region"
  add_index "people", ["locality"], :name => "index_people_on_locality"
  add_index "people", ["given_name", "family_name"], :name => "index_people_on_given_name_and_family_name"

  create_table "qualifications", :force => true do |t|
    t.integer  "person_id"
    t.string   "degree"
    t.integer  "organization_id"
    t.text     "summary"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "qualifications", ["degree"], :name => "index_qualifications_on_degree"
  add_index "qualifications", ["organization_id"], :name => "index_qualifications_on_organization_id"
  add_index "qualifications", ["person_id"], :name => "index_qualifications_on_person_id"

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

  create_table "saved_queries", :force => true do |t|
    t.string   "query"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "search_results", :force => true do |t|
    t.integer  "saved_query_id"
    t.integer  "person_id"
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "search_results", ["saved_query_id", "updated_at"], :name => "index_search_results_on_saved_query_id_and_updated_at"
  add_index "search_results", ["saved_query_id", "score"], :name => "index_search_results_on_saved_query_id_and_score"
  add_index "search_results", ["saved_query_id", "person_id"], :name => "index_search_results_on_saved_query_id_and_person_id"

  create_table "search_weights", :force => true do |t|
    t.integer  "saved_query_id"
    t.integer  "person_id"
    t.string   "keyword"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "search_weights", ["saved_query_id", "keyword"], :name => "index_search_weights_on_saved_query_id_and_keyword"
  add_index "search_weights", ["person_id"], :name => "index_search_weights_on_person_id"
  add_index "search_weights", ["saved_query_id"], :name => "index_search_weights_on_saved_query_id"

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
